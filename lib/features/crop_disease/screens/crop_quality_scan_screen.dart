import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../services/crop_disease_service.dart';
import 'crop_quality_report_screen.dart';

/// Professional, farmer-centric Produce Quality & Freshness scanning interface.
/// Integrates live camera capture and gallery photo selection with the Quality YOLO model + RAG.
class CropQualityScanScreen extends StatefulWidget {
  const CropQualityScanScreen({super.key});

  @override
  State<CropQualityScanScreen> createState() => _CropQualityScanScreenState();
}

class _CropQualityScanScreenState extends State<CropQualityScanScreen>
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

  final List<String> _cropHints = ['Auto', 'Tomato', 'Mango', 'Potato', 'Banana'];

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
        setState(() => _isCameraInitialized = false);
        return;
      }

      int backCameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _selectedCameraIndex = backCameraIndex != -1 ? backCameraIndex : 0;

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
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      await controller.setFlashMode(_currentFlashMode);
      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
          _isCameraPermissionDenied = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    final nextMode = _currentFlashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    try {
      await _cameraController!.setFlashMode(nextMode);
      setState(() => _currentFlashMode = nextMode);
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _cameraController?.dispose();
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

  Future<void> _analyzeQuality() async {
    if (_previewBytes == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final l10n = AppLocalizations.of(context);
      final languageCode = l10n?.localeName ?? 'en';
      final cropHint = _selectedCropHint == 'Auto' ? null : _selectedCropHint;

      final qualityResponse = await _cropService.analyzeCropQuality(
        imageBytes: _previewBytes!,
        filename: 'quality_scan.jpg',
        language: languageCode,
        cropHint: cropHint,
      );

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CropQualityReportScreen(
            qualityResponse: qualityResponse,
            imageBytes: _previewBytes!,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 26),
            SizedBox(width: 10),
            Text('Quality Assessment Error', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          error,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Viewfinder or Frozen Image Preview
          if (_previewBytes != null)
            Image.memory(
              _previewBytes!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          else if (_isCameraInitialized && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            _buildCameraUnavailableView(),

          // 2. Reticle / Targeting Frame Overlay
          if (_previewBytes == null && _isCameraInitialized)
            CustomPaint(
              painter: _ProduceReticlePainter(animation: _scanAnimationController),
            ),

          // 3. Top Header Bar (Safe Area)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Quality Detection',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Freshness & APMC Market Grading',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Flash Toggle
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Icon(
                          _currentFlashMode == FlashMode.torch
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          color: _currentFlashMode == FlashMode.torch
                              ? const Color(0xFFFFD54F)
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: _toggleFlash,
                    ),

                    // Camera Switch
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.flip_camera_android_rounded, color: Colors.white, size: 20),
                      ),
                      onPressed: _switchCamera,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Crop Filter Chips (Horizontal Scroll)
          if (_previewBytes == null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 68,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _cropHints.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = _cropHints[index];
                    final isSel = (_selectedCropHint == null && item == 'Auto') ||
                        _selectedCropHint == item;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCropHint = item == 'Auto' ? null : item;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF0F4D33) : Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel ? const Color(0xFF5AB688) : Colors.white24,
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            color: isSel ? Colors.white : Colors.white70,
                            fontSize: 12.5,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // 5. Bottom Action Controls (Brought up comfortably above Android 3-button navigation bar)
          Positioned(
            bottom: 52,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: _previewBytes == null
                    ? _buildCameraBottomControls()
                    : _buildPreviewBottomControls(),
              ),
            ),
          ),

          // 6. Analyzing Overlay Modal (Clean, Organic, Natural Animation)
          if (_isAnalyzing)
            Container(
              color: Colors.black.withValues(alpha: 0.82),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F4D33).withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5AB688).withValues(alpha: 0.45),
                              blurRadius: 36,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 82,
                        height: 82,
                        child: CircularProgressIndicator(
                          color: Color(0xFF5AB688),
                          strokeWidth: 3.0,
                        ),
                      ),
                      const Icon(
                        Icons.verified_outlined,
                        color: Color(0xFF5AB688),
                        size: 38,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Assessing Produce Quality...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Evaluating Freshness, Market Grade & Storage RAG',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraBottomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Gallery Button
        GestureDetector(
          onTap: _pickFromGallery,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 24),
          ),
        ),

        // Shutter Button
        GestureDetector(
          onTap: _capturePhoto,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              color: Colors.transparent,
            ),
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF5AB688),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 36),
            ),
          ),
        ),

        // Help / Tips Button
        GestureDetector(
          onTap: _showGuidanceBottomSheet,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewBottomControls() {
    return Row(
      children: [
        // Retake Button
        Expanded(
          flex: 1,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.white70),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => setState(() {
              _previewBytes = null;
            }),
            child: const Text('Retake', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 14),

        // Analyze Quality Button
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4D33),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            onPressed: _analyzeQuality,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.verified_rounded, size: 20, color: Color(0xFF5AB688)),
                SizedBox(width: 8),
                Text(
                  'Assess Quality Now',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraUnavailableView() {
    return Container(
      color: const Color(0xFF1B231F),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_outlined, size: 64, color: Color(0xFF5AB688)),
            const SizedBox(height: 18),
            Text(
              _isCameraPermissionDenied ? 'Camera Access Required' : 'Starting Camera...',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a produce image from your gallery to evaluate freshness and quality.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4D33),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
              label: const Text('Pick From Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuidanceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Tips for Produce Quality Scanning',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            _tipRow(Icons.center_focus_strong_rounded, 'Frame harvested fruits/tubers clearly in the center.'),
            _tipRow(Icons.wb_sunny_outlined, 'Ensure good natural lighting to detect discoloration or soft rot.'),
            _tipRow(Icons.straighten_rounded, 'Hold phone 20 to 30 cm from produce for sharp focus.'),
            _tipRow(Icons.eco_outlined, 'Supports Mango, Tomato, Potato, and Banana produce.'),
          ],
        ),
      ),
    );
  }

  Widget _tipRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accentGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProduceReticlePainter extends CustomPainter {
  final Animation<double> animation;

  _ProduceReticlePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 40);
    final width = size.width * 0.78;
    final height = width * 1.05;
    final rect = Rect.fromCenter(center: center, width: width, height: height);

    // Darkened vignette background outside the frame
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.45);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(24)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, bgPaint);

    // Corner brackets
    final cornerPaint = Paint()
      ..color = const Color(0xFF5AB688)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    const cornerLength = 28.0;

    // Top-Left
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, cornerLength), cornerPaint);

    // Top-Right
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, cornerLength), cornerPaint);

    // Bottom-Left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(0, -cornerLength), cornerPaint);

    // Bottom-Right
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(0, -cornerLength), cornerPaint);

    // Animated scanning line
    final scanY = rect.top + (rect.height * animation.value);
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF5AB688).withValues(alpha: 0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(rect.left, scanY - 2, rect.width, 4))
      ..strokeWidth = 2.5;

    canvas.drawLine(Offset(rect.left + 8, scanY), Offset(rect.right - 8, scanY), scanPaint);
  }

  @override
  bool shouldRepaint(covariant _ProduceReticlePainter oldDelegate) => true;
}
