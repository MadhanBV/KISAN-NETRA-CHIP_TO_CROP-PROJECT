import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../l10n/app_localizations.dart';
import '../../models/onboarding_item.dart';
import '../../features/auth/screens/auth_choice_screen.dart';
import 'widgets/onboarding_indicator.dart';
import 'widgets/onboarding_page_content.dart';

/// The shared onboarding flow for CHIP TO CROP.
/// Houses 3 onboarding screens with unified structure, responsive layout,
/// clear page indicator, prominent Next/Get Started button, Skip logic,
/// and natural back navigation.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingItem> _getItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      OnboardingItem(
        title: l10n?.onboarding1Title ?? AppStrings.onboarding1Title,
        description: l10n?.onboarding1Desc ?? AppStrings.onboarding1Description,
        imagePath: AppAssets.onboardingCropHealth,
        imageSemanticLabel:
            'Farmer inspecting healthy crop with a smartphone scanner',
      ),
      OnboardingItem(
        title: l10n?.onboarding2Title ?? AppStrings.onboarding2Title,
        description: l10n?.onboarding2Desc ?? AppStrings.onboarding2Description,
        imagePath: AppAssets.onboardingCommunity,
        imageSemanticLabel: 'Farmers collaborating and trading produce together',
      ),
      OnboardingItem(
        title: l10n?.onboarding3Title ?? AppStrings.onboarding3Title,
        description: l10n?.onboarding3Desc ?? AppStrings.onboarding3Description,
        imagePath: AppAssets.onboardingWeather,
        imageSemanticLabel:
            'Vast agricultural field under weather clouds and morning sunlight',
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _onGetStarted();
    }
  }

  void _onSkip() {
    // Navigates directly to the final onboarding screen (index 2)
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onGetStarted() {
    // Navigate to the authentication choice screen
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthChoiceScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = _getItems(context);
    final isLastPage = _currentPage == items.length - 1;

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentPage > 0) {
          _onPrevious();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Main PageView with full scrollable content
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: items.length,
                onPageChanged: _onPageChanged,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  return OnboardingPageContent(
                    item: items[index],
                    showScanOverlay: index == 0,
                  );
                },
              ),
            ),

            // Top Navigation Bar: Back & Skip options
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Natural back navigation button for pages > 0
                      AnimatedOpacity(
                        opacity: _currentPage > 0 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: _currentPage == 0,
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.85),
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: AppColors.primaryGreen,
                              ),
                              tooltip: 'Back',
                              onPressed: _onPrevious,
                            ),
                          ),
                        ),
                      ),

                      // Clear Skip button on the first two screens
                      AnimatedOpacity(
                        opacity: isLastPage ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: isLastPage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: _onSkip,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Text(
                                    l10n?.skip ?? AppStrings.skip,
                                    style: const TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom section: Indicators & Prominent Action Button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Three small page indicators
                      OnboardingIndicator(
                        totalCount: items.length,
                        currentIndex: _currentPage,
                      ),
                      const SizedBox(height: 20.0),

                      // Prominent Next / Get Started button
                      SizedBox(
                        width: double.infinity,
                        height: 56.0,
                        child: ElevatedButton(
                          onPressed: isLastPage ? _onGetStarted : _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.2),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Row(
                              key: ValueKey<bool>(isLastPage),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLastPage
                                      ? (l10n?.getStarted ?? AppStrings.getStarted)
                                      : (l10n?.next ?? AppStrings.next),
                                  style: const TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
