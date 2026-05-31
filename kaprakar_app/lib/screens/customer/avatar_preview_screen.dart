import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_radius.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../routes/app_routes.dart';
import '../../services/journey_service.dart';
import '../../services/auth_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class AvatarPreviewScreen extends StatefulWidget {
  final File? localDressImage;
  final String? dressImageUrl;
  final String? tailorName;
  final String? orderId;

  const AvatarPreviewScreen({
    super.key,
    this.localDressImage,
    this.dressImageUrl,
    this.tailorName,
    this.orderId,
  });

  @override
  State<AvatarPreviewScreen> createState() => _AvatarPreviewScreenState();
}

class _AvatarPreviewScreenState extends State<AvatarPreviewScreen>
    with SingleTickerProviderStateMixin {
  String get orderId => widget.orderId ?? '';
  String get tailorName => widget.tailorName ?? '';

  bool _loading = true;
  bool _showOriginal = false;
  // ignore: unused_field
  String? _errorMessage;
  Uint8List? _renderedImageBytes;
  String _selectedBodyType = 'average';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _loadSavedBodyType();
  }

  Future<void> _loadSavedBodyType() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      final bodyType = prefs.getString('selected_body_type') ?? 'average';
      setState(() {
        _selectedBodyType = bodyType;
      });
      Provider.of<JourneyService>(context, listen: false).setBodyType(bodyType);
    }
  }

  Future<void> _saveBodyType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_body_type', type);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _generate3DPreview();
  }

  Future<void> _generate3DPreview() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _renderedImageBytes = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');
      final token = await user.getIdToken();

      Uint8List fileBytes;
      if (widget.localDressImage != null) {
        fileBytes = await widget.localDressImage!.readAsBytes();
      } else if (widget.dressImageUrl != null) {
        final imageResponse = await http.get(Uri.parse(widget.dressImageUrl!));
        if (imageResponse.statusCode != 200) throw Exception('Failed to fetch dress image');
        fileBytes = imageResponse.bodyBytes;
      } else {
        throw Exception('No image provided');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AuthService.baseUrl}/api/preview'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        http.MultipartFile.fromBytes(
          'dressImage',
          fileBytes,
          filename: 'dress.jpg',
        )
      );

      final streamed = await request.send();
      final responseBytes = await streamed.stream.toBytes();

      if (streamed.statusCode == 200 &&
          responseBytes.isNotEmpty) {
        setState(() {
          _renderedImageBytes = responseBytes;
          _loading = false;
        });
        _fadeController.forward();
      } else {
        throw Exception('Preview generation failed');
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.uploadFailedLabel,
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildBodyTypeSelector(AppLocalizations l) {
    final types = [
      {'key': 'petite', 'label': 'Petite'},
      {'key': 'average', 'label': 'Average'},
      {'key': 'curvy', 'label': 'Curvy'},
      {'key': 'plus', 'label': 'Plus Size'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: types.map((type) {
        final bool isSelected = _selectedBodyType == type['key'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedBodyType = type['key']!;
            });
            _saveBodyType(type['key']!);
            Provider.of<JourneyService>(context, listen: false)
                .setBodyType(type['key']!);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.surface,
              borderRadius: AppRadius.pillRadius,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.border,
              ),
            ),
            child: Text(
              type['label']!,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImageDisplay() {
    final journeyService = context.watch<JourneyService>();
    final mannequinAsset =
      journeyService.getBodyTypeMannequinAsset();

    if (_loading) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppLocalizations.of(context)!.generatingPreview,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    if (_showOriginal || _renderedImageBytes == null) {
      return Expanded(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ClipRRect(
            borderRadius: AppRadius.cardRadius,
            child: widget.localDressImage != null
                ? Image.file(
                    widget.localDressImage!,
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    widget.dressImageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                      Container(
                        color: AppColors.border,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ),
          ),
        ),
      );
    }

    return Expanded(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: AppRadius.cardRadius,
              child: Image.asset(
                mannequinAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                  Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 120,
                        color: AppColors.border,
                      ),
                    ),
                  ),
              ),
            ),
            ClipRRect(
              borderRadius: AppRadius.cardRadius,
              child: Image.memory(
                _renderedImageBytes!,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: _ToggleBadge(
                isOriginal: _showOriginal,
                onToggle: () => setState(
                  () => _showOriginal = !_showOriginal
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l.avatarPreviewTitle),
        centerTitle: true,
        bottom: tailorName.isNotEmpty
            ? PreferredSize(
                preferredSize: const Size.fromHeight(20),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'By $tailorName',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _buildImageDisplay(),
            _buildBodyTypeSelector(l),
            const SizedBox(height: AppSpacing.sm),
            // View Original toggle (only when render is available)
            if (!_loading && _renderedImageBytes != null)
              GestureDetector(
                onTap: () => setState(() => _showOriginal = !_showOriginal),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showOriginal
                          ? Icons.view_in_ar
                          : Icons.photo_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _showOriginal
                          ? 'View 3D Avatar'
                          : l.viewOriginalPhoto,
                      style: AppTextStyles.linkText,
                    ),
                  ],
                ),
              ),
            if (!_loading && _renderedImageBytes != null)
              const SizedBox(height: AppSpacing.lg),
            if (!_loading) ...[
              PrimaryButton(
                text: l.satisfiedButton,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.orderCompletion,
                    arguments: {
                      'orderId': orderId,
                      'userRole': 'customer',
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                text: l.requestChangesButton,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.changeRequest,
                    arguments: {'orderId': orderId},
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToggleBadge extends StatelessWidget {
  final bool isOriginal;
  final VoidCallback onToggle;

  const _ToggleBadge({required this.isOriginal, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.85),
          borderRadius: AppRadius.pillRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOriginal ? Icons.view_in_ar : Icons.photo_outlined,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              isOriginal ? '3D' : 'Original',
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
