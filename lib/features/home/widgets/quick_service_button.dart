import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Quick service button matching the clean, circular icon button aesthetic from reference design.
class QuickServiceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const QuickServiceButton({
    super.key,
    required this.label,
    required this.icon,
    this.iconColor = AppColors.primaryGreen,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFEBF1EC), // Soft grey/mint circle from reference
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 26,
              color: const Color(0xFF0F4D33), // Deep green icon from reference
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
