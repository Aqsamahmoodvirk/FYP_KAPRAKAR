import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../routes/app_routes.dart';
import '../../services/journey_service.dart';
import '../../services/tailor_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class FindTailorScreen extends StatefulWidget {
  const FindTailorScreen({super.key});

  @override
  State<FindTailorScreen> createState() => _FindTailorScreenState();
}

class _FindTailorScreenState extends State<FindTailorScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Filters state
  String _searchQuery = '';
  double _minRating = 0;
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 10000);
  final TextEditingController _locationController = TextEditingController();

  final List<String> _categories = ['Bridal Wear', 'Casual', 'Formal', 'Party Wear'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTailors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      _fetchTailors();
    });
  }

  void _fetchTailors() {
    context.read<TailorService>().fetchAllTailors(
          search: _searchQuery,
          minRating: _minRating > 0 ? _minRating : null,
          category: _selectedCategory,
          minPrice: _selectedCategory != null ? _priceRange.start : null,
          maxPrice: _selectedCategory != null ? _priceRange.end : null,
          location: _locationController.text.isNotEmpty ? _locationController.text : null,
        );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filters', style: AppTextStyles.headlineMedium),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Rating Filter
                    Text('Minimum Rating', style: AppTextStyles.headlineSmall),
                    Slider(
                      value: _minRating,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      activeColor: AppColors.primary,
                      label: _minRating.toString(),
                      onChanged: (val) => setModalState(() => _minRating = val),
                    ),
                    
                    // Location Filter
                    Text('Location (City)', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Islamabad',
                        border: OutlineInputBorder(borderRadius: AppRadius.inputRadius),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Category Filter
                    Text('Category', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          onSelected: (selected) {
                            setModalState(() {
                              _selectedCategory = selected ? cat : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Price Filter (Only show if category selected)
                    if (_selectedCategory != null) ...[
                      Text('Price Range', style: AppTextStyles.headlineSmall),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 50000,
                        divisions: 50,
                        activeColor: AppColors.primary,
                        labels: RangeLabels(
                          '\$${_priceRange.start.round()}',
                          '\$${_priceRange.end.round()}',
                        ),
                        onChanged: (val) => setModalState(() => _priceRange = val),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                          _fetchTailors();
                        },
                        child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tailorService = context.watch<TailorService>();
    final tailors = tailorService.allTailors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search tailors by name...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.inputRadius,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.inputRadius,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: _showFilterBottomSheet,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: tailorService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : tailors.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: tailors.length,
                        itemBuilder: (context, index) {
                          final tailor = tailors[index];
                          final shopName = tailor['shopName'] ?? 'Unknown Tailor';
                          final rating = tailor['rating']?.toString() ?? '5.0';

                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.cardRadius,
                              side: const BorderSide(color: AppColors.border),
                            ),
                            elevation: 0,
                            color: Theme.of(context).cardColor,
                            child: InkWell(
                              borderRadius: AppRadius.cardRadius,
                              onTap: () {
                                Navigator.pushNamed(
                                  context, 
                                  AppRoutes.tailorPublicProfile,
                                  arguments: tailor,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: AppColors.secondary.withValues(alpha: 0.1), 
                                      child: Text(
                                        shopName.isNotEmpty ? shopName.substring(0, 1).toUpperCase() : 'T', 
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 20),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            shopName, 
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            tailor['city'] ?? 'Unknown Location', 
                                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.star, size: 16, color: Colors.amber),
                                              const SizedBox(width: 4),
                                              Text(rating, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No Tailors Found',
            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Try adjusting your exact filters to find more results.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _minRating = 0;
                _selectedCategory = null;
                _locationController.clear();
              });
              _fetchTailors();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              elevation: 0,
            ),
          )
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
            AppLocalizations.of(context)!.findATailor,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
