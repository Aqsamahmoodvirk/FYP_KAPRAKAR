import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../routes/app_routes.dart';
import '../../services/journey_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Listen to service changes to update UI
  void _onServiceUpdate() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    JourneyService().addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    JourneyService().removeListener(_onServiceUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = JourneyService();
    final hasMeasurements = service.hasMeasurements;
    final isTailorSelected = service.isTailorSelected;
    final hasActiveOrder = service.hasActiveOrder;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header --- //
              Text(
                AppLocalizations.of(context)!.stitchingProcess,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppLocalizations.of(context)!.completeTheseStepsToCustomizeY,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // --- Step 1: Measurements (Required) --- //
              _JourneyStepCard(
                stepNumber: 1,
                title: AppLocalizations.of(context)!.measurements,
                subtitle: hasMeasurements 
                    ? AppLocalizations.of(context)!.completedReady 
                    : AppLocalizations.of(context)!.requiredToProceed,
                icon: Icons.straighten,
                isCompleted: hasMeasurements,
                isLocked: false,
                onTap: () {
                  // Always viewable/editable
                  Navigator.pushNamed(context, AppRoutes.measurement);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // --- Step 2: AI Style Suggestions (Optional) --- //
              _JourneyStepCard(
                stepNumber: 2,
                title: "Style Suggestions",
                subtitle: service.aiSuggestionDone 
                    ? AppLocalizations.of(context)!.completed 
                    : AppLocalizations.of(context)!.optionalGetFabricStyleIdeas,
                icon: Icons.auto_awesome,
                isCompleted: service.aiSuggestionDone,
                isLocked: !hasMeasurements,
                onTap: () {
                  if (hasMeasurements) {
                    Navigator.pushNamed(context, AppRoutes.uploadFabric);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // --- Step 3: Find Tailor (Required) --- //
              _JourneyStepCard(
                stepNumber: 3,
                title: AppLocalizations.of(context)!.findTailor,
                subtitle: isTailorSelected
                    ? AppLocalizations.of(context)!.tailorSelected
                    : AppLocalizations.of(context)!.chooseATailorForYourOrder,
                icon: Icons.person_search,
                isCompleted: isTailorSelected,
                isLocked: !hasMeasurements,
                onTap: () {
                  if (hasMeasurements) {
                    Navigator.pushNamed(context, AppRoutes.findTailor);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // --- Step 4: Place Order (Required) --- //
              _JourneyStepCard(
                stepNumber: 4,
                title: AppLocalizations.of(context)!.placeOrder,
                subtitle: hasActiveOrder 
                    ? AppLocalizations.of(context)!.orderPlaced 
                    : AppLocalizations.of(context)!.finalizeMeasurementsPayment,
                icon: Icons.shopping_bag_outlined,
                isCompleted: hasActiveOrder,
                isLocked: !isTailorSelected, // Locked until tailor selected
                onTap: () {
                  if (isTailorSelected && !hasActiveOrder) {
                    Navigator.pushNamed(context, AppRoutes.placeOrder);
                  }
                },
              ),
            ],
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
        right: AppSpacing.md, 
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.newOrder,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}

class _JourneyStepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback onTap;

  const _JourneyStepCard({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine visuals based on state
    final Color borderColor = isCompleted 
        ? AppColors.primary 
        : (isLocked ? AppColors.border : AppColors.secondary);
    
    final Color iconColor = isCompleted
        ? Colors.white
        : (isLocked ? AppColors.textSecondary : AppColors.primary);
        
    final Color iconBg = isCompleted
        ? AppColors.primary
        : (isLocked ? AppColors.background : AppColors.surface);

    return InkWell(
      onTap: isLocked ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isCompleted ? 1.5 : 1),
          // Dim locked cards slightly
        ),
        child: Opacity(
          opacity: isLocked ? 0.6 : 1.0,
          child: Row(
            children: [
              // Step Indicator / Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                ),
                child: Icon(
                  isCompleted ? Icons.check : icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${AppLocalizations.of(context)!.step} $stepNumber: $title",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Locked/Arrow Icon
              if (isLocked)
                const Icon(Icons.lock_outline, color: AppColors.textSecondary)
              else if (!isCompleted)
                const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
