import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/primary_button.dart';
import '../../routes/app_routes.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/tailor_service.dart';
import '../../services/journey_service.dart';
import '../../services/auth_service.dart';

class TailorProfileManageScreen extends StatefulWidget {
  const TailorProfileManageScreen({super.key});

  @override
  State<TailorProfileManageScreen> createState() => _TailorProfileManageScreenState();
}

class _TailorProfileManageScreenState extends State<TailorProfileManageScreen> {
  late final String myUserId;
  bool _isAcceptingOrders = true;

  final _shopNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  final List<Map<String, dynamic>> _specialties = [
    {'name': 'Casual Wear', 'selected': false, 'price': '', 'turnaround': '7', 'urgentEnabled': false, 'urgentTurnaround': '3', 'urgentPrice': '500'},
    {'name': 'Formal Wear', 'selected': false, 'price': '', 'turnaround': '7', 'urgentEnabled': false, 'urgentTurnaround': '3', 'urgentPrice': '500'},
    {'name': 'Bridal Wear', 'selected': false, 'price': '', 'turnaround': '7', 'urgentEnabled': false, 'urgentTurnaround': '3', 'urgentPrice': '500'},
    {'name': 'Party Wear', 'selected': false, 'price': '', 'turnaround': '7', 'urgentEnabled': false, 'urgentTurnaround': '3', 'urgentPrice': '500'},
  ];

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    myUserId = JourneyService().currentUserId ?? "";
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ts = context.read<TailorService>();
      await ts.fetchTailorProfile(myUserId);
      if (ts.profile != null) {
        ts.fetchTailorOrders(ts.profile!['_id']);
      }
    });
  }

  Future<void> _pickAndUploadImage() async {
    final tailorService = context.read<TailorService>();
    final tailorId = tailorService.profile?['_id'];
    if (tailorId == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      try {
        await tailorService.uploadProfileImage(tailorId, pickedFile.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update picture: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tailorService = context.watch<TailorService>();
    final profile = tailorService.profile;

    if (tailorService.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isInitialized && profile != null) {
      _shopNameController.text = profile['shopName'] ?? '';
      _fullNameController.text = profile['fullName'] ?? '';
      _emailController.text = profile['email'] ?? '';
      _phoneController.text = profile['phone'] ?? '';
      _addressController.text = profile['address'] ?? '';
      _bioController.text = profile['bio'] ?? '';
      
      final dbSpecialties = (profile['specialties'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      final dbPrices = profile['categoryPrices'] as Map<String, dynamic>? ?? {};
      final dbTurnarounds = profile['categoryTurnaround'] as Map<String, dynamic>? ?? {};
      final dbUrgentEnabled = profile['urgentCategoryEnabled'] as Map<String, dynamic>? ?? {};
      final dbUrgentTurnarounds = profile['urgentCategoryTurnaround'] as Map<String, dynamic>? ?? {};
      final dbUrgentPrices = profile['urgentCategoryPrices'] as Map<String, dynamic>? ?? {};

      for (var s in _specialties) {
        if (dbSpecialties.contains(s['name'])) {
          s['selected'] = true;
          s['price'] = dbPrices[s['name']]?.toString() ?? '';
          s['turnaround'] = dbTurnarounds[s['name']]?.toString() ?? '7';
          s['urgentEnabled'] = dbUrgentEnabled[s['name']] ?? false;
          s['urgentTurnaround'] = dbUrgentTurnarounds[s['name']]?.toString() ?? '3';
          s['urgentPrice'] = dbUrgentPrices[s['name']]?.toString() ?? '500';
        }
      }
      _isInitialized = true;
    }
    
    final shopName = _shopNameController.text.isNotEmpty ? _shopNameController.text : "T";

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manageProfile, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Decent Header Background
            Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    Color(0xFF004D54), // Deeper shade of primary for elegant gradient
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 120), // Push avatar down to overlap border
                // Header Image/Avatar
                Center(
                   child: Column(
                     children: [
                       GestureDetector(
                         onTap: _pickAndUploadImage,
                         child: Stack(
                           children: [
                             Container(
                               decoration: BoxDecoration(
                                 shape: BoxShape.circle,
                                 border: Border.all(color: AppColors.background, width: 4),
                               ),
                               child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.surface,
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                                  backgroundImage: profile != null && profile['profileImage'] != null && profile['profileImage'].toString().isNotEmpty
                                      ? NetworkImage('${AuthService.baseUrl}${profile['profileImage']}')
                                      : null,
                                  child: profile == null || profile['profileImage'] == null || profile['profileImage'].toString().isEmpty
                                      ? Text(
                                          shopName.isNotEmpty ? shopName.substring(0, 1).toUpperCase() : "T",
                                          style: const TextStyle(color: AppColors.primary, fontSize: 36, fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                 ),
                               ),
                             ),
                             Positioned(
                               bottom: 0,
                               right: 0,
                               child: Container(
                                 padding: const EdgeInsets.all(8),
                                 decoration: BoxDecoration(
                                   color: AppColors.secondary,
                                   shape: BoxShape.circle,
                                   border: Border.all(color: AppColors.background, width: 3),
                                 ),
                                 child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                               ),
                             ),
                           ],
                         ),
                       ),
                       const SizedBox(height: 16),
                       if (profile != null)
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                           decoration: BoxDecoration(
                             color: AppColors.secondary.withValues(alpha: 0.1),
                             borderRadius: BorderRadius.circular(20),
                             border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               const Icon(Icons.star_rounded, color: AppColors.secondary, size: 16),
                               const SizedBox(width: 6),
                               Text(
                                 "${((profile['rating'] ?? 0) as num).toStringAsFixed(1)} (${profile['reviewCount'] ?? 0} Reviews)",
                                 style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.secondary, fontSize: 13),
                               ),
                             ],
                           ),
                         ),
                     ],
                   ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 50, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Availability Toggle
            Container(
              decoration: BoxDecoration(
                color: _isAcceptingOrders ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isAcceptingOrders ? AppColors.primary.withValues(alpha: 0.3) : Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: SwitchListTile(
                 contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                 title: Text(AppLocalizations.of(context)!.acceptingNewOrders, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 subtitle: Text(
                   _isAcceptingOrders ? "You are visible to customers." : "Your profile is hidden.",
                   style: TextStyle(fontSize: 13, color: _isAcceptingOrders ? AppColors.primary : Colors.grey.shade600),
                 ),
                 value: _isAcceptingOrders,
                 activeColor: AppColors.primary,
                 activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                 onChanged: (val) => setState(() => _isAcceptingOrders = val),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 32),

            const Text('Personal Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 16),

            // Form Fields
            _buildTextField('Shop Name', _shopNameController, Icons.storefront_rounded),
            const SizedBox(height: 16),
            _buildTextField('Full Name (Owner)', _fullNameController, Icons.person_rounded),
            const SizedBox(height: 16),
            _buildTextField('Email', _emailController, Icons.email_rounded),
            const SizedBox(height: 16),
            _buildTextField('Phone Number', _phoneController, Icons.phone_rounded),
            const SizedBox(height: 16),
            _buildTextField('Address', _addressController, Icons.location_on_rounded, maxLines: 2),
            const SizedBox(height: 16),
            _buildTextField('Description', _bioController, Icons.description_rounded, maxLines: 3),
            const SizedBox(height: 32),

            const Text('Expertise & Pricing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            
            ..._specialties.map((specialty) {
              final isSelected = specialty['selected'] as bool;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200, width: isSelected ? 2.0 : 1.0),
                  boxShadow: [
                    if (isSelected) BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    title: Text(
                      specialty['name'],
                      style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, fontSize: 16),
                    ),
                    leading: GestureDetector(
                      onTap: () => setState(() => specialty['selected'] = !isSelected),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.grey.shade100,
                          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    ),
                    children: isSelected ? [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 1, color: Colors.grey.shade100, margin: const EdgeInsets.only(bottom: 16)),
                            Row(
                              children: [
                                Expanded(child: _buildInlineTextField('Base Price (PKR)', specialty, 'price')),
                                const SizedBox(width: 16),
                                Expanded(child: _buildInlineTextField('Standard (Days)', specialty, 'turnaround')),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SwitchListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                title: const Text("Offer Urgent Delivery", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                value: specialty['urgentEnabled'] as bool,
                                activeColor: AppColors.primary,
                                onChanged: (val) => setState(() => specialty['urgentEnabled'] = val),
                              ),
                            ),
                            if (specialty['urgentEnabled'] as bool) ...[
                              const SizedBox(height: 16),
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
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: AppColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                   final tailorId = profile?['_id'];
                   if (tailorId != null) {
                     try {
                       await context.read<TailorService>().updateTailorProfile(tailorId, {
                         "shopName": _shopNameController.text.trim(),
                         "fullName": _fullNameController.text.trim(),
                         "email": _emailController.text.trim(),
                         "phone": _phoneController.text.trim(),
                         "address": _addressController.text.trim(),
                         "bio": _bioController.text.trim(),
                         "specialties": _specialties.where((s) => s['selected'] == true).map((s) => s['name']).toList(),
                         "categoryPrices": Map.fromEntries(_specialties.where((s) => s['selected'] == true).map((s) => MapEntry(s['name'] as String, num.tryParse(s['price']?.toString() ?? '') ?? 1500))),
                         "categoryTurnaround": Map.fromEntries(_specialties.where((s) => s['selected'] == true).map((s) => MapEntry(s['name'] as String, num.tryParse(s['turnaround']?.toString() ?? '') ?? 7))),
                         "urgentCategoryEnabled": Map.fromEntries(_specialties.where((s) => s['selected'] == true).map((s) => MapEntry(s['name'] as String, s['urgentEnabled'] as bool))),
                         "urgentCategoryTurnaround": Map.fromEntries(_specialties.where((s) => s['selected'] == true).map((s) => MapEntry(s['name'] as String, num.tryParse(s['urgentTurnaround']?.toString() ?? '') ?? 3))),
                         "urgentCategoryPrices": Map.fromEntries(_specialties.where((s) => s['selected'] == true).map((s) => MapEntry(s['name'] as String, num.tryParse(s['urgentPrice']?.toString() ?? '') ?? 500))),
                       });
                       if (!context.mounted) return;
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully)));
                       Navigator.pop(context);
                     } catch (e) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update profile: $e"), backgroundColor: Colors.red));
                     }
                   }
                },
                child: Text(AppLocalizations.of(context)!.saveChanges, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
             prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey.shade400, size: 20) : null,
             filled: true,
             fillColor: Colors.white,
             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
             focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildInlineTextField(String label, Map<String, dynamic> data, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          keyboardType: TextInputType.number,
          initialValue: data[key].toString(),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (val) => data[key] = val,
        ),
      ],
    );
  }
}
