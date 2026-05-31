import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_input_field.dart';
import '../../routes/app_routes.dart';
import '../../services/tailor_service.dart';
import '../../services/journey_service.dart';
import 'package:provider/provider.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class TailorSetupWizard extends StatefulWidget {
  const TailorSetupWizard({super.key});

  @override
  State<TailorSetupWizard> createState() => _TailorSetupWizardState();
}

class _TailorSetupWizardState extends State<TailorSetupWizard> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Step 1 Controllers
  final _shopNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  // Step 2 Data
  final List<Map<String, dynamic>> _specialties = [
    {'name': 'Casual Wear', 'selected': false, 'price': '', 'turnaround': '7', 'urgentEnabled': false, 'urgentTurnaround': '3', 'urgentPrice': '500'},
    {'name': 'Formal Wear', 'selected': false, 'price': '', 'turnaround': '7', 'urgentEnabled': false, 'urgentTurnaround': '3', 'urgentPrice': '500'},
    {'name': 'Bridal Wear', 'selected': false, 'price': '', 'turnaround': '7', 'urgentEnabled': false, 'urgentTurnaround': '3', 'urgentPrice': '500'},
    {'name': 'Party Wear', 'selected': false, 'price': '', 'turnaround': '7', 'urgentEnabled': false, 'urgentTurnaround': '3', 'urgentPrice': '500'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _shopNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _nextStep() async {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Finalize Setup - Call backend
      if (_shopNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shop Name is required')));
        return;
      }

      setState(() => _isLoading = true);
      try {
        final userId = JourneyService().currentUserId;
        if (userId == null) throw Exception("User ID not found. Please log in again.");

        final selectedSpecialties = _specialties
            .where((s) => s['selected'] == true)
            .map((s) => s['name'] as String)
            .toList();

        final data = {
          "userId": userId,
          "shopName": _shopNameController.text.trim(),
          "fullName": _fullNameController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": _phoneController.text.trim(),
          "address": _addressController.text.trim(),
          "bio": _bioController.text.trim(),
          "city": _addressController.text.trim(), // Keep city for backward compatibility
          "specialties": selectedSpecialties,
          "categoryPrices": Map.fromEntries(_specialties.where((s) => s['selected'] == true).map((s) => MapEntry(s['name'] as String, num.tryParse(s['price']?.toString() ?? '') ?? 1500))),
          "categoryTurnaround": Map.fromEntries(_specialties.where((s) => s['selected'] == true).map((s) => MapEntry(s['name'] as String, num.tryParse(s['turnaround']?.toString() ?? '') ?? 7))),
          "urgentCategoryEnabled": Map.fromEntries(_specialties.where((s) => s['selected'] == true).map((s) => MapEntry(s['name'] as String, s['urgentEnabled'] as bool))),
          "urgentCategoryTurnaround": Map.fromEntries(_specialties.where((s) => s['selected'] == true).map((s) => MapEntry(s['name'] as String, num.tryParse(s['urgentTurnaround']?.toString() ?? '') ?? 3))),
          "urgentCategoryPrices": Map.fromEntries(_specialties.where((s) => s['selected'] == true).map((s) => MapEntry(s['name'] as String, num.tryParse(s['urgentPrice']?.toString() ?? '') ?? 500))),
        };

        await context.read<TailorService>().createTailorProfile(data);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.tailorDashboard);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.shopSetup),
        centerTitle: true,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: Column(
        children: [
          // Step Indicator
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1BasicInfo(),
                _buildStep2Expertise(),
              ],
            ),
          ),
          // Bottom Buttons
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : PrimaryButton(
                    text: _currentStep == 1 ? 'Create Profile' : 'Next Step',
                    onPressed: _nextStep,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(2, (index) {
          bool isActive = index <= _currentStep;
          return Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.tellUsAboutYourShop, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(AppLocalizations.of(context)!.thisInformationWillBeVisibleTo, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          AppInputField(
            label: AppLocalizations.of(context)!.shopName,
            hint: 'e.g. Elegant Stitches',
            controller: _shopNameController,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppInputField(
            label: AppLocalizations.of(context)!.fullName,
            hint: 'e.g. John Doe',
            controller: _fullNameController,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppInputField(
            label: AppLocalizations.of(context)!.email,
            hint: 'e.g. john@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppInputField(
            label: AppLocalizations.of(context)!.phoneNumber,
            hint: 'e.g. 0300 1234567',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppInputField(
            label: 'Address',
            hint: 'e.g. 123 Main St, Lahore',
            controller: _addressController,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(AppLocalizations.of(context)!.aboutYou, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _bioController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.brieflyDescribeYourExperience,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Expertise() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.expertisePricing, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(AppLocalizations.of(context)!.selectWhatYouSewAndSetYourStar, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          ..._specialties.map((specialty) {
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              elevation: specialty['selected'] ? 4 : 0,
              shadowColor: AppColors.primary.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: specialty['selected'] ? AppColors.primary : AppColors.border, width: specialty['selected'] ? 1.5 : 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(specialty['name'], style: TextStyle(fontWeight: specialty['selected'] ? FontWeight.bold : FontWeight.normal)),
                  leading: Checkbox(
                    value: specialty['selected'],
                    onChanged: (val) {
                      setState(() => specialty['selected'] = val ?? false);
                    },
                    activeColor: AppColors.primary,
                  ),
                  children: specialty['selected'] ? [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildInlineTextField('Base Price', specialty, 'price')),
                              const SizedBox(width: 16),
                              Expanded(child: _buildInlineTextField('Standard (Days)', specialty, 'turnaround')),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Offer Urgent Delivery", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            value: specialty['urgentEnabled'] as bool,
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => specialty['urgentEnabled'] = val),
                          ),
                          if (specialty['urgentEnabled'] as bool) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(child: _buildInlineTextField('Urgent Price', specialty, 'urgentPrice')),
                                const SizedBox(width: 16),
                                Expanded(child: _buildInlineTextField('Urgent (Days)', specialty, 'urgentTurnaround')),
                              ],
                            ),
                          ]
                        ],
                      ),
                    )
                  ] : [],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInlineTextField(String label, Map<String, dynamic> data, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          controller: TextEditingController(text: data[key])..selection = TextSelection.collapsed(offset: data[key].toString().length),
          onChanged: (val) => data[key] = val,
        ),
      ],
    );
  }
}
