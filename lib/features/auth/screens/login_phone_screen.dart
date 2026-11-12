import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../widgets/phone_input_field.dart';
import 'face_capture_screen.dart';
import 'register_phone_screen.dart';

/// Screen allowing registered farmers to enter their mobile number
/// before proceeding to 1:1 facial biometric verification.
class LoginPhoneScreen extends StatefulWidget {
  final AuthService? authService;

  const LoginPhoneScreen({super.key, this.authService});

  @override
  State<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _validateAndProceed() async {
    final rawInput = _phoneController.text.trim();

    if (rawInput.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your registered mobile number';
      });
      return;
    }

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

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final normalizedPhone = '+91$cleanDigits';

    // Optional quick check to inform user if number is definitely not found
    try {
      await _authService.checkPhoneExists(normalizedPhone);
    } catch (_) {
      // Ignore network errors here; login face verification will handle it
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FaceCaptureScreen(
          mode: FaceCaptureMode.login,
          phoneNumber: normalizedPhone,
          authService: _authService,
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

                        // Small App Logo
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(AppAssets.appLogo,
                                fit: BoxFit.contain),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          l10n?.welcomeBack ?? 'Welcome Back',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          l10n?.loginMobileSubtitle ??
                              'Enter your registered mobile number to verify your identity with face scan.',
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

                        // Primary Button: "VERIFY WITH FACE"
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _validateAndProceed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.face_unlock_rounded, size: 20),
                                        const SizedBox(width: 10),
                                        Text(
                                          l10n?.verifyWithFace ?? 'VERIFY WITH FACE',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),

                        const Spacer(),

                        const SizedBox(height: 16),

                        // Switch to Register option
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n?.newToKisanNetra ?? 'New to Kisan Netra? ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPhoneScreen(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    l10n?.registerNow ?? 'Register now',
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
