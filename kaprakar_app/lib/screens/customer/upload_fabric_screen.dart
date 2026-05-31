import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import '../../theme/app_spacing.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';
import '../../routes/app_routes.dart';
import '../../services/journey_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';
import '../../widgets/ai_stylist_note_card.dart';

class UploadFabricScreen extends StatefulWidget {
  const UploadFabricScreen({super.key});

  @override
  State<UploadFabricScreen> createState() => _UploadFabricScreenState();
}

class _UploadFabricScreenState extends State<UploadFabricScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _urlController = TextEditingController();

  String selectedOccasion = "eid";
  String selectedSeason = "summer";
  String selectedFabric = "lawn";
  String selectedColor = "black";

  bool loading = false;
  File? _uploadedImageFile; // Used for thumbnail preview

  Future<void> getSuggestions() async {
    final String query =
        "pakistani $selectedOccasion $selectedSeason $selectedFabric $selectedColor dress";
    final Uri url = Uri.parse(
      "https://www.pinterest.com/search/pins/?q=${Uri.encodeComponent(query)}",
    );

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open Pinterest. Please check your connection.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _uploadCustomImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _uploadedImageFile = File(image.path); // Set for thumbnail
      loading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://172.23.181.1:5000/api/upload/suggested'),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);

        JourneyService().setSuggestedImageUrl(data['imageUrl']);
        JourneyService().completeAiSuggestions();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to upload image. Status: ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error uploading image.')));
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void _showPasteUrlDialog() {
    _urlController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Paste Image URL",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: "https://...",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                if (_urlController.text.isNotEmpty) {
                  JourneyService().setSuggestedImageUrl(_urlController.text);
                  JourneyService().completeAiSuggestions();
                  Navigator.pop(context);

                  if (mounted) {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'URL added successfully! Press Next to continue.',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text("Use URL"),
            ),
          ],
        );
      },
    );
  }

  void _onSkip(BuildContext context) {
    JourneyService().skipAiSuggestions();
    Navigator.pushReplacementNamed(context, AppRoutes.findTailor);
  }

  void _onNext() {
    JourneyService().completeAiSuggestions();
    Navigator.pushReplacementNamed(context, AppRoutes.findTailor);
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item.toLowerCase(),
                child: Text(
                  item,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA), // Very subtle off-white/grey

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _onSkip(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.grey.shade600,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.skip,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.describeYourDesiredOutfit,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.getAiPoweredPakistaniFashionSu,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              _buildDropdown(
                AppLocalizations.of(context)!.selectOccasion,
                selectedOccasion,
                ["Eid", "Wedding", "Party", "Formal", "Casual"],
                (val) => setState(() => selectedOccasion = val),
              ),
              _buildDropdown(
                AppLocalizations.of(context)!.selectSeason,
                selectedSeason,
                ["Summer", "Winter"],
                (val) => setState(() => selectedSeason = val),
              ),
              _buildDropdown(
                AppLocalizations.of(context)!.selectFabric,
                selectedFabric,
                ["Lawn", "Cotton", "Organza", "Velvet", "Chiffon"],
                (val) => setState(() => selectedFabric = val),
              ),
              _buildDropdown(
                AppLocalizations.of(context)!.selectColor,
                selectedColor,
                ["Black", "White", "Maroon", "Pink", "Blue", "Green"],
                (val) => setState(() => selectedColor = val),
              ),

              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: "Get Suggestions",
                      onPressed: getSuggestions,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        JourneyService().fetchAiStylistNote(
                          occasion: selectedOccasion,
                          season: selectedSeason,
                          fabric: selectedFabric,
                          color: selectedColor,
                        );
                      },
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text("AI Stylist Note"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        foregroundColor: primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const AiStylistNoteCard(),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Provide your inspiration",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else ...[
                      if (_uploadedImageFile != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _uploadedImageFile!,
                                height: 140,
                                width: 140,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      else if (JourneyService().suggestedImageUrl != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                JourneyService().suggestedImageUrl!.startsWith(
                                      'http',
                                    )
                                    ? JourneyService().suggestedImageUrl!
                                    : 'http://172.23.181.1:5000${JourneyService().suggestedImageUrl!}',
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 140,
                                      width: double.infinity,
                                      color: Colors.grey.shade200,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.link,
                                            color: Colors.grey,
                                            size: 40,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            JourneyService()
                                                        .suggestedImageUrl!
                                                        .length >
                                                    30
                                                ? '${JourneyService().suggestedImageUrl!.substring(0, 30)}...'
                                                : JourneyService()
                                                      .suggestedImageUrl!,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.upload_file, size: 20),
                              label: const Text("Upload Image"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                foregroundColor: primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _uploadCustomImage,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.link, size: 20),
                              label: const Text("Paste URL"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                foregroundColor: primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _showPasteUrlDialog,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32), // Bottom padding before nav bar
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
          colors: [Color(0xFF006D77), Color(0xFF004D54)], // Use raw colors for const
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
          const Text(
            "Style Suggestions",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
