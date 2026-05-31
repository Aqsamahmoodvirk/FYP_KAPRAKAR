import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';
import '../../theme/app_spacing.dart';
import '../../routes/app_routes.dart';
import '../../services/journey_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  bool _isPlacingOrder = false;
  String? _selectedCategory;
  num _estimatedPrice = 1500;
  List<String> _availableCategories = [];
  Map<String, dynamic> _categoryPrices = {};
  final _notesController = TextEditingController();

  bool _isUrgent = false;
  Map<String, dynamic> _categoryTurnarounds = {};
  Map<String, dynamic> _urgentCategoryEnabled = {};
  Map<String, dynamic> _urgentCategoryTurnarounds = {};
  Map<String, dynamic> _urgentCategoryPrices = {};

  @override
  void initState() {
    super.initState();
    final tailor = JourneyService().selectedTailor;
    if (tailor != null) {
      final specialties =
          (tailor['specialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      _categoryPrices = tailor['categoryPrices'] as Map<String, dynamic>? ?? {};
      _categoryTurnarounds =
          tailor['categoryTurnaround'] as Map<String, dynamic>? ?? {};
      _urgentCategoryEnabled =
          tailor['urgentCategoryEnabled'] as Map<String, dynamic>? ?? {};
      _urgentCategoryTurnarounds =
          tailor['urgentCategoryTurnaround'] as Map<String, dynamic>? ?? {};
      _urgentCategoryPrices =
          tailor['urgentCategoryPrices'] as Map<String, dynamic>? ?? {};

      if (specialties.isNotEmpty) {
        _availableCategories = specialties;
        _selectedCategory = specialties.first;
        _updatePrice();
      } else {
        _availableCategories = ['Custom Dress'];
        _selectedCategory = 'Custom Dress';
      }
    }
  }

  void _updatePrice() {
    if (_selectedCategory != null) {
      _estimatedPrice =
          num.tryParse(_categoryPrices[_selectedCategory]?.toString() ?? '') ??
          1500;
      final bool urgentEnabled =
          _urgentCategoryEnabled[_selectedCategory] ?? false;
      if (_isUrgent && urgentEnabled) {
        _estimatedPrice +=
            num.tryParse(
              _urgentCategoryPrices[_selectedCategory]?.toString() ?? '',
            ) ??
            500;
      } else if (_isUrgent && !urgentEnabled) {
        _isUrgent = false; // Reset if urgent is not available
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _confirmOrder() async {
    setState(() => _isPlacingOrder = true);

    try {
      // 1. Place Order in Service
      await JourneyService().placeOrder(
        dressType: _selectedCategory ?? 'Custom Dress',
        amount: _estimatedPrice.toDouble(),
        notes: _notesController.text.trim(),
        isUrgent: _isUrgent,
      );

      if (!mounted) return;

      // 2. Show Success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.orderPlacedSuccessfully),
        ),
      );

      // 3. Navigate back to Customer Hub
      Navigator.popUntil(context, ModalRoute.withName(AppRoutes.customerHome));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to place order: $e")));
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tailor = JourneyService().selectedTailor;

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
            // --- Tailor Section --- //
            Text(
              AppLocalizations.of(context)!.selectedTailor,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              elevation: 0,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: const Icon(Icons.person, color: AppColors.primary),
                title: Text(
                  tailor?['shopName'] ?? tailor?['name'] ?? 'Unknown Tailor',
                ),
                subtitle: Text(
                  "ID: ${tailor?['_id'] ?? tailor?['id'] ?? 'N/A'}",
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- Inspiration Image --- //
            if (JourneyService().suggestedImageUrl != null) ...[
              const Text(
                'Inspiration',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () async {
                  final String imageUrl = JourneyService().suggestedImageUrl!.startsWith('http')
                      ? JourneyService().suggestedImageUrl!
                      : 'http://172.23.181.1:5000${JourneyService().suggestedImageUrl!}';

                  final Uri url = Uri.parse(imageUrl);
                  if (imageUrl.startsWith('http') && !imageUrl.contains('172.23.181.1')) {
                     // It's likely an external link, try to launch it directly
                     if (await canLaunchUrl(url)) {
                       await launchUrl(url, mode: LaunchMode.externalApplication);
                       return;
                     }
                  }

                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.zero,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.link, color: Colors.white, size: 40),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url, mode: LaunchMode.externalApplication);
                                        }
                                      },
                                      child: const Text('Open Link'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 40,
                            right: 20,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 30),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          JourneyService().suggestedImageUrl!.startsWith('http')
                              ? JourneyService().suggestedImageUrl!
                              : 'http://172.23.181.1:5000${JourneyService().suggestedImageUrl!}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.link, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Tap to open external link',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.open_in_new, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // --- Category Selection --- //
            const Text(
              'Dress Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
                color: Theme.of(context).cardColor,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: _availableCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                      _updatePrice();
                    });
                  },
                ),
              ),
            ),
            // --- Notes Section --- //
            const Text(
              'Additional Notes for Tailor',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any specific changes or details about your dress?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- Delivery Pipeline --- //
            Builder(
              builder: (context) {
                final int currentTurnaround =
                    num.tryParse(
                      _categoryTurnarounds[_selectedCategory]?.toString() ?? '',
                    )?.toInt() ??
                    7;
                final bool currentUrgentEnabled =
                    _urgentCategoryEnabled[_selectedCategory] ?? false;
                final int currentUrgentTurnaround =
                    num.tryParse(
                      _urgentCategoryTurnarounds[_selectedCategory]
                              ?.toString() ??
                          '',
                    )?.toInt() ??
                    3;
                final num currentUrgentFee =
                    num.tryParse(
                      _urgentCategoryPrices[_selectedCategory]?.toString() ??
                          '',
                    ) ??
                    500;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Options',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: !_isUrgent
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: RadioListTile<bool>(
                        title: const Text('Standard Delivery'),
                        subtitle: Text(
                          'Estimated delivery in $currentTurnaround days',
                        ),
                        value: false,
                        groupValue: _isUrgent,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _isUrgent = false;
                            _updatePrice();
                          });
                        },
                      ),
                    ),
                    if (currentUrgentEnabled) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _isUrgent
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: RadioListTile<bool>(
                          title: const Text('Urgent Delivery'),
                          subtitle: Text(
                            'Estimated delivery in $currentUrgentTurnaround days (+PKR $currentUrgentFee)',
                          ),
                          value: true,
                          groupValue: _isUrgent,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _isUrgent = true;
                              _updatePrice();
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- Payment & Total --- //
            Text(
              AppLocalizations.of(context)!.paymentDetails,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.stitchingCharges),
                Text('PKR $_estimatedPrice'),
              ],
            ),

            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.totalEstimated,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'PKR $_estimatedPrice',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            _isPlacingOrder
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    text: AppLocalizations.of(context)!.confirmPlaceOrder,
                    onPressed: _confirmOrder,
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
            AppLocalizations.of(context)!.orderSummary,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
