import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../models/auth_models.dart';
import '../widgets/phone_input_field.dart';
import 'face_capture_screen.dart';
import 'login_phone_screen.dart';

/// Screen allowing a farmer to register with their 10-digit Indian mobile number.
class RegisterPhoneScreen extends StatefulWidget {
  const RegisterPhoneScreen({super.key});

  @override
  State<RegisterPhoneScreen> createState() => _RegisterPhoneScreenState();
}

class _RegisterPhoneScreenState extends State<RegisterPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validateAndProceed() {
    final rawInput = _phoneController.text.trim();

    if (rawInput.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your 10-digit mobile number';
      });
      return;
    }

    // Clean any spaces, hyphens
    final cleanDigits = rawInput.replaceAll(RegExp(r'\D'), '');

    if (cleanDigits.length != 10) {
      setState(() {
        _errorMessage = 'Mobile number must be exactly 10 digits';
      });
      return;
    }

    if (!RegExp(r'^[6-9]').hasMatch(cleanDigits)) {
      setState(() {
        _errorMessage =
            'Please enter a valid Indian mobile number starting with 6-9';
      });
      return;
    }

    // Clear any previous error and navigate to Face Capture
    setState(() {
      _errorMessage = null;
    });

    final normalizedPhone = '+91$cleanDigits';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FaceCaptureScreen(
          mode: FaceCaptureMode.register,
          phoneNumber: normalizedPhone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        const SizedBox(height: 8),

                        // Title badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreenTint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n?.farmerRegistration ?? 'FARMER REGISTRATION',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          l10n?.enterMobileNumber ?? 'Enter your mobile number',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          l10n?.registerMobileSubtitle ??
                              'Your mobile number is your farmer account ID. Face authentication will protect your account.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Mobile number input field
                        PhoneInputField(
                          controller: _phoneController,
                          errorText: _errorMessage,
                          hintText: l10n?.enter10DigitMobile,
                          onChanged: (val) {
                            if (_errorMessage != null) {
                              setState(() => _errorMessage = null);
                            }
                          },
                        ),

                        const SizedBox(height: 24),

                        // Continue Button with FittedBox to prevent any horizontal overflow
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _validateAndProceed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n?.continueWithFace ?? 'CONTINUE WITH FACE REGISTRATION',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        const SizedBox(height: 16),

                        // Switch to Login option
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n?.alreadyRegistered ?? 'Already registered? ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPhoneScreen(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    l10n?.loginHere ?? 'Login here',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
