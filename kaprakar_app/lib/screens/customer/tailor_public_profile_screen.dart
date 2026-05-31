import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../routes/app_routes.dart';
import '../../services/journey_service.dart';
import '../../services/chat_service.dart';

class TailorPublicProfileScreen extends StatelessWidget {
  const TailorPublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The tailor object should be passed as an argument
    final tailor = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (tailor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Tailor details not found.')),
      );
    }

    final shopName = tailor['shopName'] ?? 'Unknown Tailor';
    final fullName = tailor['fullName'] ?? '';
    final city = tailor['city'] ?? 'Unknown City';
    final bio = tailor['bio'] ?? 'No bio provided.';
    final rating = tailor['rating']?.toString() ?? '5.0';
    final reviewCount = tailor['reviewCount']?.toString() ?? '0';
    final specialties = tailor['specialties'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context, shopName, tailor),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header / Cover
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      shopName.isNotEmpty ? shopName.substring(0, 1).toUpperCase() : 'T',
                      style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    shopName,
                    style: AppTextStyles.headlineMedium,
                  ),
                  if (fullName.isNotEmpty)
                    Text(
                      fullName,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Rating', '$rating / 5.0', Icons.star, Colors.amber),
                      _buildStatColumn('Reviews', reviewCount, Icons.rate_review, AppColors.primary),
                      _buildStatColumn('Location', city, Icons.location_on, AppColors.secondary),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Bio
                  Text('About', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    bio,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Specialties
                  if (specialties.isNotEmpty) ...[
                    Text('Specialties', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: specialties.map((s) => Chip(
                        label: Text(s.toString()),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                        side: BorderSide.none,
                      )).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ],
),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ElevatedButton(
            onPressed: () {
              // 1. Persist the tailor ID securely in state
              JourneyService().selectTailor(tailor);
              // 2. Route to checkout
              Navigator.pushNamed(context, AppRoutes.placeOrder);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.pillRadius,
              ),
            ),
            child: const Text(
              'Select This Tailor',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.headlineSmall),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String shopName, Map<String, dynamic> tailor) {
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
                shopName,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined, color: Colors.white),
            onPressed: () async {
              final chatService = context.read<ChatService>();
              final myUserId = JourneyService().currentUserId ?? "";
              final tailorUserId = tailor['userId']['_id'] ?? tailor['userId'];
              
              try {
                final chat = await chatService.accessChat(myUserId, tailorUserId);
                if (!context.mounted) return;
                Navigator.pushNamed(
                  context, 
                  AppRoutes.chatDetail,
                  arguments: {
                    'chatId': chat['_id'],
                    'otherUserName': shopName,
                    'myUserId': myUserId,
                    'otherUserId': tailorUserId,
                  },
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error starting chat: $e')));
              }
            },
          ),
        ],
      ),
    );
  }
}
