import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../l10n/app_localizations.dart';

/// Minimal, clean card for Leaf Disease Detection.
/// Matches the exact aesthetic and styling of AiServiceCard:
/// - Soft neutral rounded card background (#F1F4F1)
/// - Bold title at top-left
/// - Clean concise subtitle below
/// - Custom organic shape and leaf icon embedded in the bottom-right corner
class LeafDiseaseCard extends StatelessWidget {
  final VoidCallback? onTap;

  const LeafDiseaseCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n?.leafDiseaseDetection ?? AppStrings.leafDiseaseDetection;
    final description =
        l10n?.leafDiseaseDetectionDesc ?? AppStrings.leafDiseaseDetectionDesc;

    return Container(
      height: 104,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F1), // Soft neutral off-white
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Stack(
              children: [
                // Organic background shape & illustration in bottom-right corner
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4EBD9).withValues(alpha: 0.8),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(55),
                        bottomLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 8.0, left: 8.0),
                      child: Icon(
                        Icons.energy_savings_leaf_rounded,
                        size: 34,
                        color: Color(0xFF2E6B47),
                      ),
                    ),
                  ),
                ),

                // Card text content
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: Text(
                          description,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
