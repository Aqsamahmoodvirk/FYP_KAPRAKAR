import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_radius.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../routes/app_routes.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class OrderCompletionScreen extends StatefulWidget {
  const OrderCompletionScreen({super.key});

  @override
  State<OrderCompletionScreen> createState() => _OrderCompletionScreenState();
}

class _OrderCompletionScreenState extends State<OrderCompletionScreen>
    with SingleTickerProviderStateMixin {
  late final String orderId;
  late final String userRole;
  bool _didInit = false;

  // Animation
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  // Rating
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _submittingFeedback = false;

  // Tailor earnings
  String? _earnings;
  bool _loadingEarnings = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      orderId = args?['orderId'] as String? ?? '';
      userRole = args?['userRole'] as String? ?? 'customer';
      _markComplete();
    }
  }

  Future<void> _markComplete() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      await http.put(
        Uri.parse('http://172.23.181.1:5000/api/orders/$orderId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': 'completed'}),
      );
    } catch (_) {}
    _animController.forward();
    if (userRole == 'tailor') _fetchEarnings();
  }

  Future<void> _fetchEarnings() async {
    setState(() => _loadingEarnings = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      final response = await http.get(
        Uri.parse('http://172.23.181.1:5000/api/payments/order/$orderId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() => _earnings = 'PKR ${data['amount'] ?? '--'}');
      }
    } catch (_) {
      setState(() => _earnings = 'PKR --');
    } finally {
      if (mounted) setState(() => _loadingEarnings = false);
    }
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }
    setState(() => _submittingFeedback = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      await http.post(
        Uri.parse('http://172.23.181.1:5000/api/orders/$orderId/feedback'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'rating': _rating,
          'comment': _commentController.text.trim(),
        }),
      );
    } catch (_) {}
    if (mounted) {
      setState(() => _submittingFeedback = false);
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.customerHome,
        (route) => false,
      );
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return GestureDetector(
          onTap: () => setState(() => _rating = i + 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 42,
              color: i < _rating ? AppColors.accentGold : AppColors.border,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSuccessIcon() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.primary,
            size: 60,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerView(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSuccessIcon(),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l.orderCompleteCustomer,
          style: AppTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l.rateExperience,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildStarRating(),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _commentController,
          maxLines: 3,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: l.shareYourDetailedExperienceOpt,
            hintStyle: AppTextStyles.bodySmall,
            filled: true,
            fillColor: AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: AppRadius.inputRadius,
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputRadius,
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputRadius,
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          text: l.submitReview,
          isLoading: _submittingFeedback,
          onPressed: _submittingFeedback ? null : _submitFeedback,
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          text: l.skip,
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.customerHome,
            (route) => false,
          ),
        ),
      ],
    );
  }

  Widget _buildTailorView(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSuccessIcon(),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l.orderCompleteTailor,
          style: AppTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.accentGold.withValues(alpha: 0.1),
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              Text('Earnings for this order', style: AppTextStyles.bodySmall),
              const SizedBox(height: AppSpacing.sm),
              _loadingEarnings
                  ? const CircularProgressIndicator(color: AppColors.accentGold)
                  : Text(
                      _earnings ?? 'PKR --',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.accentGold,
                      ),
                    ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          text: l.viewWallet,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.tailorWallet),
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          text: 'Go to Dashboard',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.tailorDashboard,
            (route) => false,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bool isCustomer = userRole == 'customer';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isCustomer ? l.orderCompleteCustomer : l.orderCompleteTailor,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: isCustomer ? _buildCustomerView(l) : _buildTailorView(l),
      ),
    );
  }
}
