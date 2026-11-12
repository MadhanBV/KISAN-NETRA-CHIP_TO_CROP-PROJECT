import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Reusable animated page indicator dots for the onboarding flow.
/// Highlights the active page with an elongated pill and smooth transitions.
class OnboardingIndicator extends StatelessWidget {
  final int totalCount;
  final int currentIndex;

  const OnboardingIndicator({
    super.key,
    required this.totalCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: isActive ? 24.0 : 7.0,
          height: 7.0,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.indicatorActive
                : AppColors.indicatorInactive,
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      }),
    );
  }
}

