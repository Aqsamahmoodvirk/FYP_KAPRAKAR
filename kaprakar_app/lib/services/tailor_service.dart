import 'package:flutter/foundation.dart';
import '../repositories/tailor_repository.dart';

class TailorService extends ChangeNotifier {
  final TailorRepository _tailorRepository;
  
  TailorService(this._tailorRepository);

  bool _isLoading = false;
  List<Map<String, dynamic>> _orders = [];
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _walletTransactions = [];
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _allTailors = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get orders => _orders;
  Map<String, dynamic>? get stats => _stats;
  List<Map<String, dynamic>> get walletTransactions => _walletTransactions;
  Map<String, dynamic>? get profile => _profile;
  List<Map<String, dynamic>> get allTailors => _allTailors;

  // Derived getters for UI
  List<Map<String, dynamic>> get activeOrders => 
      _orders.where((o) => o['status'] != 'pending' && o['status'] != 'completed' && o['status'] != 'cancelled').toList();

  List<Map<String, dynamic>> get pendingOrders => 
      _orders.where((o) => o['status'] == 'pending').toList();

  Future<void> fetchTailorOrders(String tailorId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _tailorRepository.getTailorOrders(tailorId);
    } catch (e) {
      if (kDebugMode) print("Error fetching tailor orders: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTailorStats(String tailorId) async {
    try {
      _stats = await _tailorRepository.getTailorStats(tailorId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error fetching tailor stats: $e");
    }
  }

  Future<void> fetchTailorWallet(String tailorId) async {
    try {
      _walletTransactions = await _tailorRepository.getTailorWallet(tailorId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error fetching wallet: $e");
    }
  }

  Future<void> fetchTailorProfile(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _tailorRepository.getTailorByUserId(userId);
    } catch (e) {
      if (kDebugMode) print("Error fetching tailor profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllTailors({
    String? search,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? location,
    String? category,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _allTailors = await _tailorRepository.getAllTailors(
        search: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        location: location,
        category: category,
      );
    } catch (e) {
      if (kDebugMode) print("Error fetching all tailors: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTailorProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _tailorRepository.createTailorProfile(data);
      _profile = response['tailor'];
    } catch (e) {
      if (kDebugMode) print("Error creating tailor profile: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTailorProfile(String tailorId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _tailorRepository.updateTailorProfile(tailorId, data);
      _profile = response['tailor'];
    } catch (e) {
      if (kDebugMode) print("Error updating tailor profile: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadProfileImage(String tailorId, String imagePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      final profileImageUrl = await _tailorRepository.uploadProfileImage(tailorId, imagePath);
      if (_profile != null) {
        _profile!['profileImage'] = profileImageUrl;
      }
    } catch (e) {
      if (kDebugMode) print("Error uploading profile image: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
