import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../l10n/app_localizations.dart';
import '../../features/home/home_screen.dart';
import '../../features/community/community_screen.dart';
import '../../features/crop_selling/crop_selling_screen.dart';
import '../../features/marketplace/marketplace_screen.dart';
import '../../features/profile/profile_screen.dart';

/// Main application shell directly featuring the iconic bottom navigation
/// from the reference design:
/// - Prominent center deep-green stadium pill for the primary Home action
/// - Clean, minimal icon + label layout for all secondary tabs
class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0;

  // Preserve tab state with IndexedStack
  final List<Widget> _screens = const [
    HomeScreen(),
    CommunityScreen(),
    CropSellingScreen(),
    MarketplaceScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Community Tab
                _NavTextItem(
                  icon: Icons.forum_outlined,
                  activeIcon: Icons.forum_rounded,
                  label: l10n?.navCommunity ?? AppStrings.navCommunity,
                  isActive: _currentIndex == 1,
                  onTap: () => _onTabTapped(1),
                ),

                // 2. Marketplace Tab
                _NavTextItem(
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag_rounded,
                  label: l10n?.navMarketplace ?? AppStrings.navMarketplace,
                  isActive: _currentIndex == 3,
                  onTap: () => _onTabTapped(3),
                ),

                // 3. CENTER HOME PILL (From reference design)
                _CenterHomePill(
                  label: l10n?.navHome ?? AppStrings.navHome,
                  isActive: _currentIndex == 0,
                  onTap: () => _onTabTapped(0),
                ),

                // 4. Sell Tab
                _NavTextItem(
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront_rounded,
                  label: l10n?.navSell ?? AppStrings.navSell,
                  isActive: _currentIndex == 2,
                  onTap: () => _onTabTapped(2),
                ),

                // 5. Profile Tab
                _NavTextItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: l10n?.navProfile ?? AppStrings.navProfile,
                  isActive: _currentIndex == 4,
                  onTap: () => _onTabTapped(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The prominent dark green stadium pill for the Home tab,
/// modeled directly on the reference design.
class _CenterHomePill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CenterHomePill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F4D33) : const Color(0xFFEBF1EC),
          borderRadius: BorderRadius.circular(28),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F4D33).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_rounded,
              size: 22,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standard bottom navigation icon + label item
class _NavTextItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTextItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF0F4D33) : AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
