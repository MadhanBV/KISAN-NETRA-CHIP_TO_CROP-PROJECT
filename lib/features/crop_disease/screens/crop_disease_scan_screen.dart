import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../l10n/app_localizations.dart';
import '../services/crop_disease_service.dart';
import 'crop_diagnosis_report_screen.dart';

/// Professional, farmer-centric crop & fruit disease scanning interface.
/// Integrates live camera capture and gallery photo selection with Model 3
/// (Banana Anthracnose, Mango Anthracnose, Mango Stem End Rot,
///  Potato Blackspot Bruising, Potato Dry Rot) + RAG Knowledge Engine.
class CropDiseaseScanScreen extends StatefulWidget {
  const CropDiseaseScanScreen({super.key});

  @override
  State<CropDiseaseScanScreen> createState() => _CropDiseaseScanScreenState();
}

class _CropDiseaseScanScreenState extends State<CropDiseaseScanScreen>
    with SingleTickerProviderStateMixin {
  final CropDiseaseService _cropService = CropDiseaseService();
  final ImagePicker _picker = ImagePicker();

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionDenied = false;
  FlashMode _currentFlashMode = FlashMode.off;

  Uint8List? _previewBytes;
  String? _selectedCropHint;
  bool _isAnalyzing = false;

  late final AnimationController _scanAnimationController;

  // Crops supported by Model 3
  final List<String> _cropHints = ['Auto', 'Banana', 'Mango', 'Potato'];

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _initCamera();
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isCameraPermissionDenied = false;
          _isCameraInitialized = false;
        });
        return;
      }

      await _setupCameraController(_cameras[_selectedCameraIndex]);
    } on CameraException catch (e) {
      if (e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt') {
        setState(() => _isCameraPermissionDenied = true);
      } else {
        setState(() => _isCameraInitialized = false);
      }
    } catch (_) {
      setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    final prevController = _cameraController;
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await prevController?.dispose();

    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
        _currentFlashMode = controller.value.flashMode;
      });
    } catch (_) {
      if (mounted) setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final nextMode = _currentFlashMode == FlashMode.off
          ? FlashMode.torch
          : _currentFlashMode == FlashMode.torch
              ? FlashMode.auto
              : FlashMode.off;
      await _cameraController!.setFlashMode(nextMode);
      setState(() => _currentFlashMode = nextMode);
    } catch (_) {}
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final xFile = await _cameraController!.takePicture();
      final bytes = await xFile.readAsBytes();
      setState(() {
        _previewBytes = bytes;
      });
    } catch (e) {
      _showSnackbar('Failed to capture photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _previewBytes = bytes;
        });
      }
    } catch (e) {
      _showSnackbar('Could not open gallery: $e');
    }
  }

  Future<void> _analyzeCrop() async {
    if (_previewBytes == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final l10n = AppLocalizations.of(context);
      final languageCode = l10n?.localeName ?? 'en';
      final cropHint = _selectedCropHint == 'Auto' ? null : _selectedCropHint;

      final diagnosis = await _cropService.diagnoseCropDisease(
        imageBytes: _previewBytes!,
        filename: 'crop_scan.jpg',
        language: languageCode,
        cropHint: cropHint,
      );

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CropDiagnosisReportScreen(
            diagnosis: diagnosis,
            imageBytes: _previewBytes!,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      _showErrorDialog(e.toString());
    }
  }

  void _retakePhoto() {
    setState(() {
      _previewBytes = null;
    });
  }

  void _showSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.error_outline_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Diagnosis Error', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Try Again', style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview or Captured Photo Preview
          Positioned.fill(
            child: _previewBytes != null
                ? Image.memory(
                    _previewBytes!,
                    fit: BoxFit.cover,
                  )
                : (_isCameraInitialized && _cameraController != null)
                    ? CameraPreview(_cameraController!)
                    : _buildCameraUnavailableView(),
          ),

          // 2. Crop Alignment Overlay (when live preview active)
          if (_previewBytes == null && _isCameraInitialized)
            Positioned.fill(
              child: CustomPaint(
                painter: _CropDiseaseReticlePainter(
                  animation: _scanAnimationController,
                ),
              ),
            ),

          // 3. Top Control Bar & Crop Selector
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Bar: Back, Title, Flash, Flip Camera
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n?.diseaseDetection ?? AppStrings.diseaseDetection,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        if (_previewBytes == null && _isCameraInitialized) ...[
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                _currentFlashMode == FlashMode.torch
                                    ? Icons.flash_on_rounded
                                    : _currentFlashMode == FlashMode.auto
                                        ? Icons.flash_auto_rounded
                                        : Icons.flash_off_rounded,
                                color: _currentFlashMode != FlashMode.off ? Colors.amber : Colors.white,
                                size: 20,
                              ),
                              onPressed: _toggleFlash,
                            ),
                          ),
                          if (_cameras.length > 1)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 20),
                                onPressed: _flipCamera,
                              ),
                            ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Crop Selection Horizontal Pills (Banana, Mango, Potato, Auto)
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        itemCount: _cropHints.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final crop = _cropHints[idx];
                          final isSelected = (_selectedCropHint == null && crop == 'Auto') ||
                              _selectedCropHint == crop;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCropHint = crop == 'Auto' ? null : crop;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1B8755)
                                    : Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF34D399)
                                      : Colors.white.withValues(alpha: 0.25),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Text(
                                crop,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Bottom Controls: Capture or Retake/Analyze
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: _previewBytes != null
                  ? _buildPreviewActions()
                  : _buildCaptureControls(),
            ),
          ),

          // 5. Clean, Minimal Loading Overlay
          if (_isAnalyzing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.65),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13221C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1B8755).withValues(alpha: 0.4), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B8755).withValues(alpha: 0.25),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                          ),
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Analyzing Crop Disease...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaptureControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Gallery Button
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 24),
            onPressed: _pickFromGallery,
            tooltip: 'Pick from gallery',
          ),
        ),

        // Shutter Button
        GestureDetector(
          onTap: _capturePhoto,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              color: const Color(0xFF1B8755),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B8755).withValues(alpha: 0.45),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 34),
            ),
          ),
        ),

        // Help Tips Button
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 24),
            onPressed: _showTipsDialog,
            tooltip: 'Scanning tips',
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewActions() {
    return Row(
      children: [
        // Retake Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isAnalyzing ? null : _retakePhoto,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            label: const Text('Retake', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white38, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Run AI Diagnosis Button
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _analyzeCrop,
            icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
            label: const Text(
              'Diagnose Crop',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B8755),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraUnavailableView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isCameraPermissionDenied ? Icons.camera_alt_outlined : Icons.videocam_off_rounded,
            size: 64,
            color: Colors.white38,
          ),
          const SizedBox(height: 16),
          Text(
            _isCameraPermissionDenied ? 'Camera permission is required' : 'Camera is initializing...',
            style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _pickFromGallery,
            icon: const Icon(Icons.photo_library_outlined, size: 20),
            label: const Text('Pick Image from Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B8755),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showTipsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.tips_and_updates_rounded, color: Color(0xFF1B8755)),
            SizedBox(width: 8),
            Text('Best Scan Practices', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _TipRow(icon: Icons.wb_sunny_outlined, text: 'Ensure ample natural daylight on the crop surface.'),
            SizedBox(height: 10),
            _TipRow(icon: Icons.center_focus_strong_rounded, text: 'Hold camera 15-25cm away directly facing the disease lesion or blemish.'),
            SizedBox(height: 10),
            _TipRow(icon: Icons.filter_alt_outlined, text: 'Select crop pill (Banana, Mango, Potato) for optimized accuracy.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it', style: TextStyle(color: Color(0xFF1B8755), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1B8755)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, height: 1.35, color: Colors.black87)),
        ),
      ],
    );
  }
}

class _CropDiseaseReticlePainter extends CustomPainter {
  final Animation<double> animation;

  _CropDiseaseReticlePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final double boxSize = size.width * 0.76;
    final double left = (size.width - boxSize) / 2;
    final double top = (size.height - boxSize) / 2.3;
    final rect = Rect.fromLTWH(left, top, boxSize, boxSize);

    // Darkened vignette outside framing box
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.35);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(20)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, bgPaint);

    // Corner targeting brackets
    final cornerPaint = Paint()
      ..color = const Color(0xFF34D399)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 32.0;

    // Top-left
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top + 16), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(left, top, 32, 32), 3.14159, 1.57079, false, cornerPaint);
    canvas.drawLine(Offset(left + 16, top), Offset(left + cornerLength, top), cornerPaint);

    // Top-right
    final right = left + boxSize;
    canvas.drawLine(Offset(right - cornerLength, top), Offset(right - 16, top), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(right - 32, top, 32, 32), -1.57079, 1.57079, false, cornerPaint);
    canvas.drawLine(Offset(right, top + 16), Offset(right, top + cornerLength), cornerPaint);

    // Bottom-left
    final bottom = top + boxSize;
    canvas.drawLine(Offset(left, bottom - cornerLength), Offset(left, bottom - 16), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(left, bottom - 32, 32, 32), 1.57079, 1.57079, false, cornerPaint);
    canvas.drawLine(Offset(left + 16, bottom), Offset(left + cornerLength, bottom), cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(right - cornerLength, bottom), Offset(right - 16, bottom), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(right - 32, bottom - 32, 32, 32), 0, 1.57079, false, cornerPaint);
    canvas.drawLine(Offset(right, bottom - 16), Offset(right, bottom - cornerLength), cornerPaint);

    // Animated scanning laser beam
    final scanY = top + (boxSize * animation.value);
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF34D399).withValues(alpha: 0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(left, scanY, boxSize, 2.5))
      ..strokeWidth = 2.5;

    canvas.drawLine(Offset(left + 10, scanY), Offset(right - 10, scanY), scanPaint);
  }

  @override
  bool shouldRepaint(covariant _CropDiseaseReticlePainter oldDelegate) => true;
}
