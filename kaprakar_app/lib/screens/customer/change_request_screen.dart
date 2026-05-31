import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_radius.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../routes/app_routes.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class ChangeRequestScreen extends StatefulWidget {
  const ChangeRequestScreen({super.key});

  @override
  State<ChangeRequestScreen> createState() => _ChangeRequestScreenState();
}

class _ChangeRequestScreenState extends State<ChangeRequestScreen> {
  late final String orderId;
  bool _didInit = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'Fitting Issue';
  final List<String> _categories = [
    'Fitting Issue',
    'Length Issue',
    'Embroidery Issue',
    'Style Change',
    'Other',
  ];

  File? _referenceImage;
  bool _submitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      orderId = args?['orderId'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _referenceImage = File(picked.path));
    }
  }

  Future<String?> _uploadReferenceImage(String token) async {
    if (_referenceImage == null) return null;
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://172.23.181.1:5000/api/orders/$orderId/revision-image'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath('image', _referenceImage!.path),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['imageUrl'] as String?;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken() ?? '';

      String? revisionImageUrl;
      if (_referenceImage != null) {
        revisionImageUrl = await _uploadReferenceImage(token);
      }

      final response = await http.put(
        Uri.parse('http://172.23.181.1:5000/api/orders/$orderId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': 'revision-requested',
          'revisionNote': _descriptionController.text.trim(),
          'revisionCategory': _selectedCategory,
          'revisionImageUrl': revisionImageUrl,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.revisionSent),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.trackOrder,
          (route) => route.settings.name == AppRoutes.customerHome,
        );
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _categories.map((cat) {
        final bool selected = cat == _selectedCategory;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.surface,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
              borderRadius: AppRadius.pillRadius,
            ),
            child: Text(
              cat,
              style: AppTextStyles.labelSmall.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(l.changeRequestTitle), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category
              Text(l.changeCategory, style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              _buildCategoryChips(),
              const SizedBox(height: AppSpacing.lg),

              // Description
              Text(l.describeChanges, style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 500,
                style: AppTextStyles.bodyMedium,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please describe the changes needed'
                    : null,
                decoration: InputDecoration(
                  hintText: 'E.g. The kameez is too tight around the chest...',
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
                  counterStyle: AppTextStyles.labelSmall,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Reference photo picker
              Text(
                'Reference Photo (Optional)',
                style: AppTextStyles.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: _referenceImage != null ? 180 : 100,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.cardRadius,
                    border: Border.all(
                      color: _referenceImage != null
                          ? AppColors.primary
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: _referenceImage != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: AppRadius.cardRadius,
                              child: Image.file(
                                _referenceImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: AppSpacing.sm,
                              right: AppSpacing.sm,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _referenceImage = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              color: AppColors.textSecondary,
                              size: 32,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l.chooseFromGallery,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                text: l.submitRevision,
                isLoading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                text: l.cancel,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
