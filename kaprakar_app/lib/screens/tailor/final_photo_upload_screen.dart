import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_radius.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';
import '../../main.dart';

class FinalPhotoUploadScreen extends StatefulWidget {
  const FinalPhotoUploadScreen({super.key});

  @override
  State<FinalPhotoUploadScreen> createState() =>
      _FinalPhotoUploadScreenState();
}

class _FinalPhotoUploadScreenState extends State<FinalPhotoUploadScreen> {
  File? _capturedDressImage;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1080,
      );
      if (photo != null && mounted) {
        setState(() => _capturedDressImage = File(photo.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _uploadAndSendToCustomer(String orderId) async {
    if (_capturedDressImage == null || orderId.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isUploading = false);
        return;
      }
      final token = await user.getIdToken();

      final uri = Uri.parse(
        '${AuthService.baseUrl}/api/orders/$orderId/final-image',
      );
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'dressImage',
          _capturedDressImage!.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // After the async gap, NEVER touch context/scaffold/localizations.
      // Only use globalNavigatorKey for navigation.
      if (response.statusCode == 200) {
        // Success — navigate to dashboard immediately via global key
        globalNavigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.tailorDashboard,
          (route) => false,
        );
        return; // skip finally setState since widget is gone
      } else {
        debugPrint('Upload failed: ${response.statusCode} ${response.body}');
        if (mounted) setState(() => _isUploading = false);
      }
    } catch (e) {
      debugPrint('Upload exception: $e');
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments
        as Map<String, dynamic>? ??
            {};
    final String orderId = args['orderId'] ?? '';
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l.finalProductCapture),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              l.alignTheDressWithinTheOutlines,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Main display area — shows 3D model or uploaded dress
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.cardRadius,
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _capturedDressImage == null
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.cardRadius,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.1),
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 64,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'No Photo Selected',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                              child: Text(
                                'Take a photo or choose from gallery to upload the final stitched dress.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                // Show uploaded dress photo when photo is selected
                    : Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.cardRadius,
                      child: Image.file(
                        _capturedDressImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: CircleAvatar(
                        backgroundColor:
                        AppColors.surface.withValues(alpha: 0.8),
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          onPressed: () =>
                              _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ),
                    // Reset button to go back to 3D model view
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: CircleAvatar(
                        backgroundColor:
                        AppColors.surface.withValues(alpha: 0.8),
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.error,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(
                                  () => _capturedDressImage = null,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Helper text
            Text(
              _capturedDressImage == null
                  ? 'Upload a photo to proceed'
                  : 'Tap the X icon to remove the photo',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.md),

            // Camera and Gallery buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: l.takePhotoLabel,
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SecondaryButton(
                    text: l.chooseFromGalleryLabel,
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Upload button
            PrimaryButton(
              text: 'Upload & Send to Customer',
              isLoading: _isUploading,
              onPressed: (_capturedDressImage != null && !_isUploading)
                  ? () => _uploadAndSendToCustomer(orderId)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}