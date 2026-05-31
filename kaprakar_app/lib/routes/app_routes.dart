import 'dart:io';
import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/booking_screen.dart';

// Onboarding
import '../screens/onboarding/language_selection_screen.dart';
import '../screens/onboarding/role_selection_screen.dart';

// Customer
import '../screens/customer/measurement_input_screen.dart';
import '../screens/customer/customer_home_hub.dart';
import '../screens/customer/measurement_guide_screen.dart';
import '../screens/customer/upload_fabric_screen.dart';
import '../screens/customer/find_tailor_screen.dart';
import '../screens/customer/tailor_public_profile_screen.dart';
import '../screens/customer/accessory_vendors_screen.dart';
import '../screens/customer/place_order_screen.dart';
import '../screens/customer/track_order_screen.dart';
import '../screens/customer/preview_stitched_dress_screen.dart';
import '../screens/customer/payment_screen.dart';
import '../screens/customer/feedback_screen.dart';

import '../screens/customer/order_history_screen.dart';

// Tailor
import '../screens/tailor/tailor_dashboard_screen.dart';
import '../screens/tailor/order_inbox_screen.dart';
import '../screens/tailor/active_orders_screen.dart';
import '../screens/tailor/order_detail_screen.dart';
import '../screens/tailor/order_status_updater.dart';
import '../screens/tailor/final_photo_upload_screen.dart';
import '../screens/tailor/wallet_screen.dart';
import '../screens/tailor/tailor_profile_manage_screen.dart';
import '../screens/tailor/tailor_reviews_screen.dart';
import '../screens/tailor/tailor_setup_wizard.dart';
import '../screens/tailor/tailor_notifications_screen.dart';

// Shared
import '../screens/shared/profile_screen.dart';
import '../screens/shared/settings_screen.dart';
import '../screens/shared/help_support_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/shared/chat/chats_list_screen.dart';
import '../screens/shared/chat/chat_detail_screen.dart';

// Newly added workflow and AI suggestion screens
import '../screens/customer/avatar_preview_screen.dart';
import '../screens/customer/order_review_screen.dart';
import '../screens/customer/change_request_screen.dart';
import '../screens/tailor/revision_inbox_screen.dart';
import '../screens/shared/order_completion_screen.dart';
import '../screens/shared/notification_screen.dart';
import '../screens/customer/ai_suggestion_result_screen.dart';
import '../screens/shared/static_content_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String booking = '/booking';
  
  static const String roleSelection = '/role';
  static const String forgotPassword = '/forgot_password';

  // Customer
  static const String customerHome = '/customer_home';
  static const String languageSelection = '/language'; 
  static const String measurement = '/measurement';
  static const String uploadFabric = '/upload_fabric';
  static const String tailorPublicProfile = '/tailor_public_profile';
  static const String aiSuggestion = '/ai_suggestion';
  static const String findTailor = '/find_tailor';
  static const String accessories = '/accessories';
  static const String placeOrder = '/place_order';
  static const String trackOrder = '/track_order';
  static const String preview = '/preview';
  static const String payment = '/payment';
  static const String feedback = '/feedback';

  static const String measurementGuide = '/measurement_guide';

  static const String orderHistory = '/order_history';

  // Tailor
  static const String tailorDashboard = '/tailor_dashboard';
  static const String tailorSetup = '/tailor_setup';
  static const String orderInbox = '/order_inbox';
  static const String activeOrders = '/active_orders';
  static const String orderDetail = '/order_detail';
  static const String orderStatusUpdater = '/order_status_updater';
  static const String finalPhotoUpload = '/final_photo_upload';
  static const String tailorWallet = '/tailor_wallet';
  static const String tailorProfile = '/tailorProfile';
  static const String tailorReviews = '/tailorReviews';
  static const String customerProfile = '/customerProfile';
  static const String tailorNotifications = '/tailor_notifications';

  // Shared
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String chatsList = '/chats_list';
  static const String chatDetail = '/chat_detail';
  static const String staticContent = '/static_content';

  // New Workflow Routes
  static const String avatarPreview = '/avatar_preview';
  static const String orderReview = '/order_review';
  static const String changeRequest = '/change_request';
  static const String revisionInbox = '/revision_inbox';
  static const String orderCompletion = '/order_completion';
  static const String notifications = '/notifications';
  static const String aiSuggestionResult = '/ai_suggestion_result';

  static final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    home: (_) => const HomeScreen(),
    booking: (_) => const BookingScreen(),

    roleSelection: (_) => const RoleSelectionScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),

    // Customer
    customerHome: (_) => const CustomerHomeHub(),
    languageSelection: (_) => const LanguageSelectionScreen(),
    measurement: (_) => const MeasurementInputScreen(),
    uploadFabric: (_) => const UploadFabricScreen(),
    tailorPublicProfile: (context) => const TailorPublicProfileScreen(),
    aiSuggestion: (context) => const AISuggestionResultScreen(),
    findTailor: (_) => const FindTailorScreen(),
    accessories: (_) => const AccessoryVendorsScreen(),
    placeOrder: (_) => const PlaceOrderScreen(),
    trackOrder: (_) => const TrackOrderScreen(),
    preview: (_) => const PreviewStitchedDressScreen(),
    payment: (_) => const PaymentScreen(),
    feedback: (_) => const FeedbackScreen(),
    measurementGuide: (_) => const MeasurementGuideScreen(),

    orderHistory: (_) => const OrderHistoryScreen(),

    // Tailor
    tailorDashboard: (_) => const TailorDashboardScreen(),
    tailorSetup: (_) => const TailorSetupWizard(),
    orderInbox: (_) => const OrderInboxScreen(),
    activeOrders: (_) => const ActiveOrdersScreen(),
    orderDetail: (_) => const OrderDetailScreen(),
    orderStatusUpdater: (_) => const OrderStatusUpdaterScreen(),
    finalPhotoUpload: (_) => const FinalPhotoUploadScreen(),
    tailorWallet: (_) => const WalletScreen(),
    tailorProfile: (_) => const TailorProfileManageScreen(),
    tailorReviews: (_) => const TailorReviewsScreen(),
    tailorNotifications: (_) => const TailorNotificationsScreen(),

    // Shared
    profile: (_) => const ProfileScreen(),
    settings: (_) => const SettingsScreen(),
    help: (_) => const HelpSupportScreen(),
    chatsList: (_) => const ChatsListScreen(),
    chatDetail: (_) => const ChatDetailScreen(),
    staticContent: (_) => const StaticContentScreen(),

    // New Workflow Routes
    avatarPreview: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return AvatarPreviewScreen(
        localDressImage: args?['localDressImage'] as File?,
        dressImageUrl: args?['dressImageUrl'] as String?,
        tailorName: args?['tailorName'] as String?,
        orderId: args?['orderId'] as String?,
      );
    },
    orderReview: (_) => const OrderReviewScreen(),
    changeRequest: (_) => const ChangeRequestScreen(),
    revisionInbox: (_) => const RevisionInboxScreen(),
    orderCompletion: (_) => const OrderCompletionScreen(),
    notifications: (_) => const NotificationScreen(),
    aiSuggestionResult: (_) => const AISuggestionResultScreen(),
  };
}
