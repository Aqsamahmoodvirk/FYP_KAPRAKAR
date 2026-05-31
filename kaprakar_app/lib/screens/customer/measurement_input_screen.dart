import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/primary_button.dart';
import '../../routes/app_routes.dart';
import '../../services/journey_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class MeasurementInputScreen extends StatefulWidget {
  const MeasurementInputScreen({super.key});

  @override
  State<MeasurementInputScreen> createState() => _MeasurementInputScreenState();
}

class _MeasurementInputScreenState extends State<MeasurementInputScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for realistic measurements
  final _shoulderController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();
  final _sleeveController = TextEditingController();
  final _armholeController = TextEditingController();
  final _lengthController = TextEditingController();
  final _neckController = TextEditingController();
  final _trouserLengthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final m = JourneyService().measurements;
    if (m != null) {
      if (m['Shoulder'] != null) _shoulderController.text = m['Shoulder'].toString();
      if (m['Chest'] != null) _chestController.text = m['Chest'].toString();
      if (m['Waist'] != null) _waistController.text = m['Waist'].toString();
      if (m['Hip'] != null) _hipController.text = m['Hip'].toString();
      if (m['Sleeve'] != null) _sleeveController.text = m['Sleeve'].toString();
      if (m['Armhole'] != null) _armholeController.text = m['Armhole'].toString();
      if (m['Length'] != null) _lengthController.text = m['Length'].toString();
      if (m['Neck'] != null) _neckController.text = m['Neck'].toString();
      if (m['Trouser'] != null) _trouserLengthController.text = m['Trouser'].toString();
    }
  }

  @override
  void dispose() {
    _shoulderController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    _sleeveController.dispose();
    _armholeController.dispose();
    _lengthController.dispose();
    _neckController.dispose();
    _trouserLengthController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.requiredToProceed;
    }
    return null;
  }

  void _saveAndContinue() {
    if (_formKey.currentState!.validate()) {
      // Save to Service
      double parse(String text) => double.tryParse(text) ?? 0.0;

      final measurements = {
        'Shoulder': parse(_shoulderController.text),
        'Chest': parse(_chestController.text),
        'Waist': parse(_waistController.text),
        'Hip': parse(_hipController.text),
        'Sleeve': parse(_sleeveController.text),
        'Armhole': parse(_armholeController.text),
        'Length': parse(_lengthController.text),
        'Neck': parse(_neckController.text),
        'Trouser': parse(_trouserLengthController.text),
      };
      
      JourneyService().saveMeasurements(measurements);

      // Navigate to Dashboard (Journey View) while preserving the Hub route
      Navigator.pushNamedAndRemoveUntil(
        context, 
        AppRoutes.home, 
        ModalRoute.withName(AppRoutes.customerHome),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.enterYourDetails,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppLocalizations.of(context)!.pleaseProvideAccurateMeasureme,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Realistic Fields
              _buildSectionHeader(AppLocalizations.of(context)!.upperBody),
              AppInputField(
                label: AppLocalizations.of(context)!.shoulder,
                hint: AppLocalizations.of(context)!.eg14,
                controller: _shoulderController,
                keyboardType: TextInputType.number,
                validator: _validateRequired,
              ),
              const SizedBox(height: AppSpacing.md),
              AppInputField(
                label: AppLocalizations.of(context)!.chestBust,
                hint: AppLocalizations.of(context)!.eg36,
                controller: _chestController,
                keyboardType: TextInputType.number,
                validator: _validateRequired,
              ),
              const SizedBox(height: AppSpacing.md),
              AppInputField(
                label: AppLocalizations.of(context)!.waist,
                hint: AppLocalizations.of(context)!.eg30,
                controller: _waistController,
                keyboardType: TextInputType.number,
                validator: _validateRequired,
              ),
              const SizedBox(height: AppSpacing.md),
              AppInputField(
                label: AppLocalizations.of(context)!.hip,
                hint: AppLocalizations.of(context)!.eg38,
                controller: _hipController,
                keyboardType: TextInputType.number,
                validator: _validateRequired,
              ),
              const SizedBox(height: AppSpacing.md),
              AppInputField(
                label: AppLocalizations.of(context)!.neck,
                hint: AppLocalizations.of(context)!.eg15,
                controller: _neckController,
                keyboardType: TextInputType.number,
                validator: _validateRequired,
              ),

              const SizedBox(height: AppSpacing.lg),
              _buildSectionHeader(AppLocalizations.of(context)!.sleevesAndLengths),
              AppInputField(
                label: AppLocalizations.of(context)!.sleeveLength,
                hint: AppLocalizations.of(context)!.eg22,
                controller: _sleeveController,
                keyboardType: TextInputType.number,
                validator: _validateRequired,
              ),
              const SizedBox(height: AppSpacing.md),
              AppInputField(
                label: AppLocalizations.of(context)!.armhole,
                hint: AppLocalizations.of(context)!.eg16,
                controller: _armholeController,
                keyboardType: TextInputType.number,
                validator: _validateRequired,
              ),
              const SizedBox(height: AppSpacing.md),
              AppInputField(
                label: AppLocalizations.of(context)!.shirtKameezLength,
                hint: AppLocalizations.of(context)!.eg38,
                controller: _lengthController,
                keyboardType: TextInputType.number,
                validator: _validateRequired,
              ),

              const SizedBox(height: AppSpacing.lg),
              _buildSectionHeader(AppLocalizations.of(context)!.lowerBody),
              AppInputField(
                label: AppLocalizations.of(context)!.trouserShalwarLength,
                hint: AppLocalizations.of(context)!.eg38,
                controller: _trouserLengthController,
                keyboardType: TextInputType.number,
                validator: _validateRequired,
              ),

              const SizedBox(height: AppSpacing.xxl),
              
              PrimaryButton(
                text: AppLocalizations.of(context)!.saveContinue,
                onPressed: _saveAndContinue,
              ),
              
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.measurementGuide);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.needMeasurementGuidance,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    ),
  ],
),
);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: AppSpacing.sm, 
        right: AppSpacing.lg, 
        top: MediaQuery.of(context).padding.top + AppSpacing.sm, 
        bottom: AppSpacing.xl
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF004D54)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.measurements,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
