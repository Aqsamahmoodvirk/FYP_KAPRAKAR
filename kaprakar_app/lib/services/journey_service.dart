import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/order_repository.dart';

class JourneyService extends ChangeNotifier {
  // Singleton pattern (will be phased out in future refactoring)
  static final JourneyService _instance = JourneyService._internal();
  factory JourneyService() => _instance;
  JourneyService._internal();

  OrderRepository? _orderRepository;
  bool _isLoading = false;

  void injectRepository(OrderRepository repository) {
    _orderRepository = repository;
  }

  // --- State Variables (In-Memory) ---
  String? _currentUserId;
  bool _hasMeasurements = false;
  String? _measurementId;
  Map<String, double>? _measurements;
  bool _aiSuggestionDone = false;
  Map<String, dynamic>? _selectedTailor;
  String? _suggestedImageUrl;
  String? _aiStylistNote;
  bool _isFetchingStylistNote = false;

  List<Map<String, dynamic>> _orderHistory = [];
  Map<String, dynamic>? _activeOrder;

  String _userRole = "Customer";
  String _userCity = "Lahore";
  String _userName = "";
  String _userEmail = "";
  String _userPhone = "";
  String _userRating = "5.0";

  // --- Getters ---
  String? get currentUserId => _currentUserId;
  bool get isLoading => _isLoading;
  bool get hasMeasurements => _hasMeasurements;
  Map<String, double>? get measurements => _measurements;
  bool get aiSuggestionDone => _aiSuggestionDone;
  bool get isTailorSelected => _selectedTailor != null;
  Map<String, dynamic>? get selectedTailor => _selectedTailor;
  String? get suggestedImageUrl => _suggestedImageUrl;
  String? get aiStylistNote => _aiStylistNote;
  bool get isFetchingStylistNote => _isFetchingStylistNote;

  bool get hasActiveOrder => _activeOrder != null;
  String? get activeOrderId => _activeOrder?['_id'];
  Map<String, dynamic>? get activeOrder => _activeOrder;
  List<Map<String, dynamic>> get orderHistory => _orderHistory;

  String get userRole => _userRole;
  String get userCity => _userCity;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userRating => _userRating;

  bool get isPreviewReady => _activeOrder?['status'] == 'ready';
  bool get isOrderDelivered => _activeOrder?['status'] == 'completed';

  // --- Actions ---

  // Live Data Integration
  Future<void> fetchUserProfile(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('https://fypkaprakar-production-4896.up.railway.app/api/auth/user/$userId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profile = data['profile'];
        final user = data['user'];
        final String fullName = profile?['fullName'] == 'No Name' ? '' : (profile?['fullName'] ?? '');
        final String shopName = profile?['shopName'] == 'No Name' ? '' : (profile?['shopName'] ?? '');
        _userName = fullName.isNotEmpty ? fullName : shopName;
        _userEmail = user?['email'] ?? '';
        _userPhone = profile?['phone'] ?? '';
        final String city = profile?['city'] ?? '';
        _userCity = city.isNotEmpty ? city : 'Lahore';
        if (profile?['rating'] != null) {
          _userRating = (profile!['rating'] as num).toStringAsFixed(1);
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching user profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Also fetch measurements for the customer
    await fetchMeasurements();
  }

  Future<void> fetchMeasurements() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        final response = await http.get(
          Uri.parse('https://fypkaprakar-production-4896.up.railway.app/api/measurements/me'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _measurementId = data['_id'];
          _measurements = {
            'Shoulder': (data['shoulder'] ?? 0).toDouble(),
            'Chest': (data['chest'] ?? 0).toDouble(),
            'Waist': (data['waist'] ?? 0).toDouble(),
            'Hip': (data['hips'] ?? 0).toDouble(),
            'Sleeve': (data['sleeve'] ?? 0).toDouble(),
            'Armhole': (data['armhole'] ?? 0).toDouble(),
            'Length': (data['length'] ?? 0).toDouble(),
            'Neck': (data['neck'] ?? 0).toDouble(),
            'Trouser': (data['trouser'] ?? 0).toDouble(),
          };
          _hasMeasurements = true;
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching measurements: $e');
    }
  }

  Future<void> fetchCustomerOrders(String customerId) async {
    if (_orderRepository == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _orderHistory = await _orderRepository!.getCustomerOrders(customerId);
      // For now, if there's an active/pending order, set it as _activeOrder
      _activeOrder = _orderHistory.cast<Map<String, dynamic>?>().firstWhere(
        (order) =>
            order?['status'] != 'completed' && order?['status'] != 'cancelled',
        orElse: () => null,
      );
    } catch (e) {
      if (kDebugMode) print("Error fetching orders: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    if (_orderRepository == null) return;
    try {
      await _orderRepository!.updateOrderStatus(orderId, status);
      // Update local state optimistically
      if (_activeOrder != null && _activeOrder!['_id'] == orderId) {
        _activeOrder!['status'] = status;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print("Error updating order status: $e");
      rethrow;
    }
  }

  Future<void> completeOrder(String orderId, String imagePath) async {
    if (_orderRepository == null) return;
    try {
      await _orderRepository!.completeOrder(orderId, imagePath);
      if (_activeOrder != null && _activeOrder!['_id'] == orderId) {
        _activeOrder!['status'] = 'pending_customer_review';
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print("Error completing order: $e");
      rethrow;
    }
  }

  Future<String?> generateCheckout(String orderId, double amount, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('https://fypkaprakar-production-4896.up.railway.app/api/payments/safepay/generate-checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId, 'amount': amount, 'userId': userId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['checkoutUrl'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("Error init safepay checkout: $e");
      return null;
    }
  }

  Future<String?> getPaymentStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('https://fypkaprakar-production-4896.up.railway.app/api/payments/$orderId/status'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("Error fetching payment status: $e");
      return null;
    }
  }

  // Directly confirms payment on the backend (used by in-app payment screen)
  Future<void> confirmPaymentDirectly(String orderId, String userId, double amount) async {
    try {
      // First init payment to create the payment record
      final initResponse = await http.post(
        Uri.parse('https://fypkaprakar-production-4896.up.railway.app/api/payments/safepay/generate-checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId, 'amount': amount, 'userId': userId}),
      );
      if (kDebugMode) print("Init response: ${initResponse.body}");

      // Then mark payment as paid and order as ready via the success endpoint
      final successResponse = await http.get(
        Uri.parse('https://fypkaprakar-production-4896.up.railway.app/api/payments/safepay/success?orderId=$orderId'),
      );
      if (kDebugMode) print("Success response: ${successResponse.statusCode}");

      if (successResponse.statusCode != 200) {
        throw Exception('Failed to confirm payment on server');
      }
    } catch (e) {
      if (kDebugMode) print("Error confirming payment: $e");
      rethrow;
    }
  }


  Future<void> submitFeedback(
    String orderId,
    int rating,
    String comment,
  ) async {
    if (_orderRepository == null) return;
    try {
      await _orderRepository!.submitFeedback(orderId, rating, comment);
    } catch (e) {
      if (kDebugMode) print("Error submitting feedback: $e");
      rethrow;
    }
  }

  // Local State Modifiers
  Future<void> saveMeasurements(Map<String, double> data) async {
    _measurements = data;
    _hasMeasurements = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();

        // Map to backend schema
        final mappedData = {
          'shoulder': data['Shoulder'],
          'chest': data['Chest'],
          'waist': data['Waist'],
          'hips': data['Hip'],
          'sleeve': data['Sleeve'],
          'armhole': data['Armhole'],
          'length': data['Length'],
          'neck': data['Neck'],
          'trouser': data['Trouser'],
        };

        final response = await http.post(
          Uri.parse('https://fypkaprakar-production-4896.up.railway.app/api/measurements'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(mappedData),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final body = jsonDecode(response.body);
          _measurementId = body['measurements']['_id'];
        } else {
          if (kDebugMode)
            print('Failed to sync measurements: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error syncing measurements to backend: $e');
    }
  }

  void completeAiSuggestions() {
    _aiSuggestionDone = true;
    notifyListeners();
  }

  void skipAiSuggestions() {
    _aiSuggestionDone = true;
    notifyListeners();
  }

  void setSuggestedImageUrl(String? url) {
    _suggestedImageUrl = url;
    notifyListeners();
  }

  Future<void> fetchAiStylistNote({
    required String occasion,
    required String season,
    required String fabric,
    required String color,
  }) async {
    _isFetchingStylistNote = true;
    _aiStylistNote = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://fypkaprakar-production.up.railway.app/style-note'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'occasion': occasion,
          'season': season,
          'fabric': fabric,
          'color': color,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _aiStylistNote = data['note'];
      } else {
        _aiStylistNote = "Sorry, I couldn't generate a note at this time.";
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching stylist note: $e");
      _aiStylistNote = "Error reaching the AI service. Please try again.";
    } finally {
      _isFetchingStylistNote = false;
      notifyListeners();
    }
  }

  void selectTailor(Map<String, dynamic> tailor) {
    _selectedTailor = tailor;
    notifyListeners();
  }

  void startNewOrder() {
    _aiSuggestionDone = false;
    _selectedTailor = null;
    notifyListeners();
  }

  Future<void> placeOrder({
    String dressType = 'Custom Dress',
    double amount = 1500,
    String notes = '',
    bool isUrgent = false,
  }) async {
    if (_selectedTailor == null ||
        _currentUserId == null ||
        _orderRepository == null)
      return;

    _isLoading = true;
    notifyListeners();

    try {
      final tailorDocId = _selectedTailor!['_id'] ?? _selectedTailor!['id'];

      final orderData = {
        'customerId': _currentUserId,
        'tailorId': tailorDocId,
        'dressType': dressType,
        'measurementId': _measurementId,
        'notes': notes,
        'amount': amount,
        'isUrgent': isUrgent,
        'suggestedImageUrl': _suggestedImageUrl,
      };

      final realOrder = await _orderRepository!.createOrder(orderData);

      _activeOrder = realOrder;
      _orderHistory.insert(0, realOrder);
    } catch (e) {
      if (kDebugMode) print("Error placing order: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCustomerOrder(String orderId) async {
    if (_orderRepository == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _orderRepository!.deleteOrder(orderId);

      // Remove from local state
      _orderHistory.removeWhere((order) => order['_id'] == orderId);

      // If the active order is the one being deleted, clear it
      if (_activeOrder != null && _activeOrder!['_id'] == orderId) {
        _activeOrder = null;
      }
    } catch (e) {
      if (kDebugMode) print("Error deleting order: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetJourney() {
    _hasMeasurements = false;
    _measurements = null;
    _aiSuggestionDone = false;
    _aiStylistNote = null;
    _isFetchingStylistNote = false;
    _selectedTailor = null;
    _activeOrder = null;
    _orderHistory = [];
    _userCity = "Lahore";
    _userName = "";
    _userEmail = "";
    _userPhone = "";
    notifyListeners();
  }

  void updateUserCity(String city) {
    _userCity = city;
    notifyListeners();
  }

  void setUserRole(String role) {
    _userRole = role;
    notifyListeners();
  }

  void setCurrentUserId(String id) {
    _currentUserId = id;
    notifyListeners();
  }

  void updateUserProfile({
    required String name,
    required String email,
    required String phone,
    required String city,
  }) {
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    _userCity = city;
    notifyListeners();
  }

  String? selectedAiStyle;
  Map<String, dynamic>? currentOrderDetails;
  List<Map<String, dynamic>> notifications = [];
  int unreadNotificationCount = 0;

  void setSelectedAiStyle(Map<String, dynamic> style) {
    selectedAiStyle = style['style'];
    notifyListeners();
  }

  void setCurrentOrderDetails(Map<String, dynamic> order) {
    currentOrderDetails = order;
    notifyListeners();
  }

  void updateUnreadCount(int count) {
    unreadNotificationCount = count;
    notifyListeners();
  }

  String _bodyType = 'average';
  String get bodyType => _bodyType;

  void setBodyType(String type) {
    _bodyType = type;
    notifyListeners();
  }

  String getBodyTypeMannequinAsset() {
    switch (_bodyType) {
      case 'petite':
        return 'assets/images/mannequin_petite.png';
      case 'curvy':
        return 'assets/images/mannequin_curvy.png';
      case 'plus':
        return 'assets/images/mannequin_plus.png';
      case 'average':
      default:
        return 'assets/images/mannequin_average.png';
    }
  }
}
