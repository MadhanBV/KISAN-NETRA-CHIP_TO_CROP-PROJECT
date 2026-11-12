import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Supported-crop tile matching the circular icon aesthetic from the reference design.
class CropTile extends StatelessWidget {
  final String name;
  final String emoji;
  final VoidCallback? onTap;

  const CropTile({
    super.key,
    required this.name,
    required this.emoji,
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
          // Circular icon button from reference design
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFEBF1EC), // Soft grey/mint circular background from reference
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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
