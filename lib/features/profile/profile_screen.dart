import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/locale_controller.dart';
import '../language/screens/language_selection_screen.dart';
import 'screens/my_ai_reports_screen.dart';
import 'screens/my_conversations_screen.dart';
import 'screens/system_status_screen.dart';

/// Placeholder Profile tab screen.
/// Will be replaced with full farmer profile and settings.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Profile header
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.lightGreenTint,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderLight, width: 1.5),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 36,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Farmer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Set up your profile',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 28),

              // Menu items
              _buildMenuItem(
                icon: Icons.person_outline_rounded,
                title: 'My Profile',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.article_outlined,
                title: 'My AI Reports',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MyAiReportsScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.storefront_outlined,
                title: 'My Listings',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.bookmark_outline_rounded,
                title: 'Saved Products',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.chat_outlined,
                title: 'My Conversations',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MyConversationsScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.translate_rounded,
                title: 'Language',
                subtitle: '${LocaleController.instance.currentLanguage.name} (${LocaleController.instance.currentLanguage.nativeName})',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LanguageSelectionScreen(isFirstLaunch: false),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.terminal_rounded,
                title: 'Server Commands & Status',
                subtitle: 'Dev commands & ports',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SystemStatusScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                onTap: () {},
              ),

              const SizedBox(height: 24),

              // App branding
              Opacity(
                opacity: 0.3,
                child: Image.asset(
                  AppAssets.appLogo,
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'CHIP TO CROP v1.0.0',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreenTint,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 19, color: AppColors.primaryGreen),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

