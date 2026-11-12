import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

enum ProcessingStep {
  capturing,
  preparing,
  processing,
  success,
  failure,
}

/// A multi-stage animated processing dialog for registration and verification.
class AuthProcessingDialog extends StatelessWidget {
  final ProcessingStep currentStep;
  final bool isRegistration;
  final String? errorMessage;
  final int? remainingAttempts;
  final VoidCallback? onRetry;

  const AuthProcessingDialog({
    super.key,
    required this.currentStep,
    required this.isRegistration,
    this.errorMessage,
    this.remainingAttempts,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Icon
            _buildIcon(),

            const SizedBox(height: 20),

            // Title
            Text(
              _getTitle(l10n),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle / message
            Text(
              _getMessage(l10n),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            // Step timeline for ongoing states
            if (currentStep != ProcessingStep.failure) ...[
              _buildStepItem(
                label: 'Image Captured',
                isDone: true,
                isActive: false,
              ),
              const SizedBox(height: 10),
              _buildStepItem(
                label: 'Preparing Biometric Template',
                isDone: currentStep.index >= ProcessingStep.processing.index,
                isActive: currentStep == ProcessingStep.preparing,
              ),
              const SizedBox(height: 10),
              _buildStepItem(
                label: isRegistration
                    ? 'Saving to Encrypted Storage'
                    : 'Face++ 1:1 Biometric Comparison',
                isDone: currentStep == ProcessingStep.success,
                isActive: currentStep == ProcessingStep.processing,
              ),
            ],

            // Actions for failure
            if (currentStep == ProcessingStep.failure) ...[
              const SizedBox(height: 10),
              if (onRetry != null)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n?.tryAgain ?? 'Try Again',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (currentStep) {
      case ProcessingStep.capturing:
      case ProcessingStep.preparing:
      case ProcessingStep.processing:
        return const SizedBox(
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
            strokeWidth: 3.5,
          ),
        );
      case ProcessingStep.success:
        return Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: AppColors.lightGreenTint,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 34,
            color: AppColors.accentGreen,
          ),
        );
      case ProcessingStep.failure:
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.softRed.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 34,
            color: AppColors.softRed,
          ),
        );
    }
  }

  String _getTitle(AppLocalizations? l10n) {
    switch (currentStep) {
      case ProcessingStep.capturing:
        return 'Capturing Photograph';
      case ProcessingStep.preparing:
        return l10n?.preparingBiometricScan ?? 'Preparing Verification';
      case ProcessingStep.processing:
        return isRegistration
            ? (l10n?.storingEncryptedRecord ?? 'Saving Registration')
            : (l10n?.matchingFacialBiometric ?? 'Verifying Identity');
      case ProcessingStep.success:
        return l10n?.authSuccessful ?? (isRegistration ? 'Registration Complete!' : 'Identity Verified!');
      case ProcessingStep.failure:
        return l10n?.verificationFailed ?? 'Verification Unsuccessful';
    }
  }

  String _getMessage(AppLocalizations? l10n) {
    if (errorMessage != null) {
      if (remainingAttempts != null) {
        final countStr = l10n?.remainingAttempts(remainingAttempts!) ??
            '($remainingAttempts attempt${remainingAttempts == 1 ? '' : 's'} remaining)';
        return '$errorMessage\n$countStr';
      }
      return errorMessage!;
    }
    switch (currentStep) {
      case ProcessingStep.capturing:
        return 'Securing photo preview...';
      case ProcessingStep.preparing:
        return l10n?.encryptingFaceTemplate ?? 'Validating image quality and lighting...';
      case ProcessingStep.processing:
        return isRegistration
            ? (l10n?.storingEncryptedRecord ?? 'Encrypting reference photograph and profile...')
            : (l10n?.matchingFacialBiometric ?? 'Performing 1:1 facial biometric matching...');
      case ProcessingStep.success:
        return isRegistration
            ? 'Your farmer account is now secured with Face ID.'
            : 'Welcome back to CHIP TO CROP!';
      case ProcessingStep.failure:
        return 'Please ensure adequate lighting and align your face inside the frame.';
    }
  }

  Widget _buildStepItem({
    required String label,
    required bool isDone,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.primaryGreen
                : isActive
                    ? AppColors.accentGreen.withValues(alpha: 0.2)
                    : AppColors.borderLight,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : isActive
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accentGreen,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isDone || isActive ? FontWeight.w600 : FontWeight.w400,
              color: isDone || isActive
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

