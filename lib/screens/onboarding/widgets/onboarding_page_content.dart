import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/onboarding_item.dart';

/// Content widget for a single onboarding page.
/// Occupies the upper 55-60% with a realistic visual, followed by
/// clean, high-contrast, farmer-friendly typography.
class OnboardingPageContent extends StatelessWidget {
  final OnboardingItem item;
  final bool showScanOverlay;

  const OnboardingPageContent({
    super.key,
    required this.item,
    this.showScanOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final visualHeight = screenHeight * 0.56;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Upper 55-60% visual section
          SizedBox(
            height: visualHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Photographic image with softly rounded bottom corners
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32.0),
                    bottomRight: Radius.circular(32.0),
                  ),
                  child: Image.asset(
                    item.imagePath,
                    fit: BoxFit.cover,
                    semanticLabel: item.imageSemanticLabel,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.lightGreenTint,
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 64,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Subtle natural gradient overlay for a seamless transition
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32.0),
                        bottomRight: Radius.circular(32.0),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.12),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.18),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Subtle professional crop-scanning visual bracket for Screen 1
                if (showScanOverlay)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.85),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            // Subtle corner indicator lines
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                width: 20,
                                height: 3,
                                color: AppColors.accentGreen,
                              ),
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                width: 3,
                                height: 20,
                                color: AppColors.accentGreen,
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                width: 20,
                                height: 3,
                                color: AppColors.accentGreen,
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                width: 3,
                                height: 20,
                                color: AppColors.accentGreen,
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

          const SizedBox(height: 28.0),

          // Typography section: Large, clear and uncluttered
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              children: [
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                        fontSize: 16.0,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
