import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/primary_button.dart';
import '../../services/journey_service.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock editing controllers - populated from MockData initially
  // Read from service
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late String _selectedCity;
  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(AppLocalizations.of(context)!.changeProfilePhoto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: Text(AppLocalizations.of(context)!.takeAPhoto),
                onTap: () {
                  Navigator.pop(ctx);
                  // Placeholder for image picker
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: Text(AppLocalizations.of(context)!.chooseFromGallery),
                onTap: () {
                  Navigator.pop(ctx);
                  // Placeholder for image picker
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final service = context.read<JourneyService>();
    final String myUserId = service.currentUserId ?? "";

    _nameController = TextEditingController(text: service.userName);
    _emailController = TextEditingController(text: service.userEmail);
    _phoneController = TextEditingController(text: service.userPhone);
    _selectedCity = service.userCity;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await service.fetchUserProfile(myUserId);
      if (mounted) {
        setState(() {
          _nameController.text = service.userName;
          _emailController.text = service.userEmail;
          _phoneController.text = service.userPhone;
          if (service.userCity.isNotEmpty) {
            _selectedCity = service.userCity;
          }
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileSettings, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white)),
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
              height: 240,
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
                // Avatar
                 GestureDetector(
                   onTap: _showImagePickerSheet,
                   child: Center(
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
                              child: Text(
                                JourneyService().userName.isNotEmpty ? JourneyService().userName.substring(0, 1).toUpperCase() : "U",
                                style: const TextStyle(color: AppColors.primary, fontSize: 36, fontWeight: FontWeight.bold),
                              ),
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
                 ),
                 
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.stretch,
                     children: [
                       const Text('Personal Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                       const SizedBox(height: 16),

                       // Form Style Fields
                       _buildTextField(AppLocalizations.of(context)!.fullName, _nameController, Icons.person_rounded),
                       const SizedBox(height: 16),
                       _buildTextField(AppLocalizations.of(context)!.email, _emailController, Icons.email_rounded, keyboardType: TextInputType.emailAddress),
                       const SizedBox(height: 16),
                       _buildCityRow(context),
                       const SizedBox(height: 16),
                       _buildTextField(AppLocalizations.of(context)!.phoneNumber, _phoneController, Icons.phone_rounded, keyboardType: TextInputType.phone),

                       const SizedBox(height: 40),

                       // Save Button
                       SizedBox(
                         width: double.infinity,
                         height: 52,
                         child: ElevatedButton(
                           style: ElevatedButton.styleFrom(
                             backgroundColor: AppColors.primary,
                             foregroundColor: Colors.white,
                             elevation: 0,
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           ),
                           onPressed: () async {
                             if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                   content: Text(AppLocalizations.of(context)!.nameAndPhoneAreRequired),
                                   backgroundColor: AppColors.error,
                                   behavior: SnackBarBehavior.floating,
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                 ),
                               );
                               return;
                             }

                             final authService = AuthService();
                             final journeyService = JourneyService();
                             final userId = journeyService.currentUserId;

                             if (userId != null && userId.isNotEmpty) {
                               try {
                                 await authService.updateProfile(userId, {
                                   "name": _nameController.text.trim(),
                                   "email": _emailController.text.trim(),
                                   "phone": _phoneController.text.trim(),
                                   "city": _selectedCity,
                                 });
                               } catch (e) {
                                 if (!context.mounted) return;
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   const SnackBar(
                                     content: Text("Failed to update profile"),
                                     backgroundColor: AppColors.error,
                                   ),
                                 );
                                 return;
                               }
                             }

                             journeyService.updateUserProfile(
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                phone: _phoneController.text.trim(),
                                city: _selectedCity,
                             );
                             
                             if (!context.mounted) return;
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: Text(AppLocalizations.of(context)!.profileSavedSuccessfully),
                                 backgroundColor: AppColors.primary,
                                 behavior: SnackBarBehavior.floating,
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                 duration: const Duration(seconds: 2),
                               ),
                             );
                             Navigator.pop(context);
                           },
                           child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
             prefixIcon: Icon(icon, color: AppColors.primary.withValues(alpha: 0.7), size: 20),
             filled: true,
             fillColor: AppColors.surface,
             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
             focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }


  Widget _buildCityRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.city, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.location_city_rounded, color: AppColors.primary.withValues(alpha: 0.7), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCity,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                    style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                    items: ['Lahore', 'Karachi', 'Islamabad', 'Rawalpindi', 'Faisalabad'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        if (newValue != null) _selectedCity = newValue;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
