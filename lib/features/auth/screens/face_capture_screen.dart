import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../app/main_app_shell.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../widgets/auth_processing_dialog.dart';
import '../widgets/face_reticle_painter.dart';

/// Professional, fintech-grade camera capture & review interface for Phone + Face authentication.
/// Features dual-layer biometric reticle, scanning animation after capture,
/// and responsive mobile layout with ample negative space.
class FaceCaptureScreen extends StatefulWidget {
  final FaceCaptureMode mode;
  final String phoneNumber;
  final AuthService? authService;

  const FaceCaptureScreen({
    super.key,
    required this.mode,
    required this.phoneNumber,
    this.authService,
  });

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen>
    with TickerProviderStateMixin {
  late final AuthService _authService;
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionDenied = false;

  Uint8List? _capturedBytes;
  bool _biometricConsent = true;
  bool _isScanning = false;

  late final AnimationController _pulseController;
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isCameraInitialized = false;
        });
        return;
      }

      // Default to front-facing camera for face capture
      int frontCameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      _selectedCameraIndex = frontCameraIndex != -1 ? frontCameraIndex : 0;

      await _setupCameraController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      if (e.toString().contains('permissionDenied') ||
          e.toString().contains('cameraPermission')) {
        setState(() => _isCameraPermissionDenied = true);
      } else {
        setState(() => _isCameraInitialized = false);
      }
    }
  }

  Future<void> _setupCameraController(CameraDescription description) async {
    const candidatePresets = [
      ResolutionPreset.medium,
      ResolutionPreset.high,
      ResolutionPreset.low,
    ];

    for (final preset in candidatePresets) {
      final controller = CameraController(
        description,
        preset,
        enableAudio: false,
      );

      try {
        await controller.initialize();
        if (!mounted) {
          await controller.dispose();
          return;
        }
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
        });
        return;
      } catch (_) {
        await controller.dispose();
      }
    }

    if (mounted) {
      setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _cameraController?.dispose();
    await _setupCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _takePicture() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final xFile = await _cameraController!.takePicture();
        final bytes = await xFile.readAsBytes();
        setState(() {
          _capturedBytes = bytes;
          _isScanning = true;
        });
        _scanController.repeat(reverse: true);
      } catch (e) {
        _showErrorSnackBar('Failed to capture photograph: $e');
      }
    } else {
      // Simulated capture for desktop/emulator/testing environments
      _simulateCapture();
    }
  }

  void _simulateCapture() {
    // 1x1 green pixel JPEG dummy for simulation
    final mockBytes = Uint8List.fromList([
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
      0x00, 0x03, 0x02, 0x02, 0x03, 0x02, 0x02, 0x03, 0x03, 0x03, 0x03, 0x04,
      0x03, 0x03, 0x04, 0x05, 0x08, 0x05, 0x05, 0x04, 0x04, 0x05, 0x0A, 0x07,
      0x07, 0x06, 0x08, 0x0C, 0x0A, 0x0C, 0x0C, 0x0B, 0x0A, 0x0B, 0x0B, 0x0D,
      0x0E, 0x12, 0x10, 0x0D, 0x0E, 0x11, 0x0E, 0x0B, 0x0B, 0x10, 0x16, 0x10,
      0x11, 0x13, 0x14, 0x15, 0x15, 0x15, 0x0C, 0x0F, 0x17, 0x18, 0x16, 0x14,
      0x18, 0x12, 0x14, 0x15, 0x14, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01,
      0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x14, 0x00, 0x01,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00,
      0x3F, 0x00, 0x37, 0xFF, 0xD9
    ]);
    setState(() {
      _capturedBytes = mockBytes;
      _isScanning = true;
    });
    _scanController.repeat(reverse: true);
  }

  void _retake() {
    _scanController.stop();
    setState(() {
      _capturedBytes = null;
      _isScanning = false;
    });
  }

  Future<void> _submitVerification() async {
    if (_capturedBytes == null) return;

    if (widget.mode == FaceCaptureMode.register && !_biometricConsent) {
      _showErrorSnackBar('Please provide explicit consent to register.');
      return;
    }

    // Show processing dialog
    ProcessingStep step = ProcessingStep.preparing;
    String? errorMsg;
    int? remainingAttempts;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AuthProcessingDialog(
              currentStep: step,
              isRegistration: widget.mode == FaceCaptureMode.register,
              errorMessage: errorMsg,
              remainingAttempts: remainingAttempts,
              onRetry: () {
                Navigator.of(dialogContext).pop();
                _retake();
              },
            );
          },
        );
      },
    );

    await Future.delayed(const Duration(milliseconds: 700));

    AuthResult result;
    if (widget.mode == FaceCaptureMode.register) {
      result = await _authService.register(
        phoneNumber: widget.phoneNumber,
        imageBytes: _capturedBytes!,
        filename: 'reference.jpg',
        consent: _biometricConsent,
      );
    } else {
      result = await _authService.login(
        phoneNumber: widget.phoneNumber,
        imageBytes: _capturedBytes!,
        filename: 'login.jpg',
      );
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Close initial dialog

    if (result.success) {
      // Show success step dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AuthProcessingDialog(
          currentStep: ProcessingStep.success,
          isRegistration: widget.mode == FaceCaptureMode.register,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _navigateToHome();
    } else {
      // Show failure step dialog with detailed reason
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AuthProcessingDialog(
          currentStep: ProcessingStep.failure,
          isRegistration: widget.mode == FaceCaptureMode.register,
          errorMessage: result.message,
          remainingAttempts: result.remainingAttempts,
          onRetry: () {
            Navigator.of(dialogCtx).pop();
            _retake();
          },
        ),
      );
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainAppShell()),
      (route) => false,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.softRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRegister = widget.mode == FaceCaptureMode.register;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera live preview OR review image OR black warmup
          if (_capturedBytes != null)
            _buildReviewImage()
          else if (_isCameraInitialized && _cameraController != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? 1,
                  height: _cameraController!.value.previewSize?.width ?? 1,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            _buildCameraFallback(),

          // 2. Animated biometric oval reticle overlay
          AnimatedBuilder(
            animation: Listenable.merge([_pulseController, _scanController]),
            builder: (context, child) {
              return CustomPaint(
                painter: FaceReticlePainter(
                  borderColor: AppColors.primaryGreen,
                  pulseValue: _pulseController.value,
                  scanProgress: _scanController.value,
                  isScanning: _isScanning,
                ),
              );
            },
          ),

          // 3. Clean Integrated Top Bar & Guidance Section (Zero Collision)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button in frosted glass circle
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.50),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ),

                        // Title badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isRegister
                                    ? Icons.badge_outlined
                                    : Icons.face_unlock_rounded,
                                color: AppColors.accentGreen,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isRegister
                                    ? (l10n?.faceRegistration ?? 'Face Registration')
                                    : (l10n?.faceVerification ?? 'Face Verification'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Camera Switch button
                        if (_cameras.length > 1 && _capturedBytes == null)
                          GestureDetector(
                            onTap: _switchCamera,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.50),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.flip_camera_ios_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 42),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Guidance Pill (Positioned cleanly with 40px+ clearance above the reticle)
                    if (_capturedBytes == null)
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 48,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.accentGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                l10n?.positionFaceInFrame ?? 'Position your face inside the green frame',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Post-capture quality status pill
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 48,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l10n?.faceCapturedSuccess ?? 'Face Captured • AI Scanning Complete',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
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

          // 4. Bottom action panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: _capturedBytes == null
                  ? _buildCaptureControls(l10n)
                  : _buildReviewControls(isRegister, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewImage() {
    return Center(
      child: Image.memory(
        _capturedBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  /// Clean, silent camera fallback during warmup - NO flashing text!
  Widget _buildCameraFallback() {
    return Container(
      color: Colors.black,
      child: Center(
        child: _isCameraPermissionDenied
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.videocam_off_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Camera Permission Required',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please enable camera access in your device settings to scan your face.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(), // Pure clean black transition during warmup
      ),
    );
  }

  Widget _buildCaptureControls(AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.95),
            Colors.black.withValues(alpha: 0.60),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n?.keepHeadStraight ?? 'Keep head straight & ensure even lighting',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          // Shutter button with glowing outer ring
          GestureDetector(
            onTap: _takePicture,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.5),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.25),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primaryGreen,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewControls(bool isRegister, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.lightGreenTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.accentGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isRegister
                    ? (l10n?.reviewFacePhoto ?? 'Review Face Photograph')
                    : (l10n?.confirmFaceForLogin ?? 'Confirm Face for Login'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            l10n?.ensureFaceVisible ?? 'Ensure your face is clearly visible.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),

          if (isRegister) ...[
            const SizedBox(height: 12),

            // Explicit Biometric Consent statement
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGreenTint,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _biometricConsent,
                      activeColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _biometricConsent = val ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n?.biometricConsentText ??
                          'I consent to using my face scan for secure authentication.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Primary Submit Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isRegister
                          ? Icons.fingerprint_rounded
                          : Icons.verified_user_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isRegister
                          ? (l10n?.confirmAndRegister ?? 'CONFIRM & REGISTER')
                          : (l10n?.verifyFace ?? 'VERIFY FACE'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Retake Button
          Center(
            child: TextButton.icon(
              onPressed: _retake,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                l10n?.retake ?? 'Retake',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
