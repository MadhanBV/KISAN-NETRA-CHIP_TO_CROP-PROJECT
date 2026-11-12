import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Premium biometric reticle painter inspired by Apple FaceID and modern fintech KYC.
/// Features a dark focus mask, glowing biometric oval frame, 4 corner brackets,
/// and an animated scanning beam that only activates during biometric scanning.
class FaceReticlePainter extends CustomPainter {
  final Color borderColor;
  final double pulseValue;
  final double scanProgress;
  final bool isScanning;

  const FaceReticlePainter({
    this.borderColor = AppColors.primaryGreen,
    this.pulseValue = 0.0,
    this.scanProgress = 0.5,
    this.isScanning = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Darkened background cutout
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.60)
      ..style = PaintingStyle.fill;

    // Responsive oval dimensions with generous top/bottom margins
    final ovalWidth = size.width * 0.68;
    final ovalHeight = ovalWidth * 1.34;
    final center = Offset(size.width / 2, size.height * 0.45);
    final ovalRect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final ovalPath = Path()..addOval(ovalRect);
    final combinedPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      ovalPath,
    );
    canvas.drawPath(combinedPath, backgroundPaint);

    // 2. Outer soft glow ring
    final glowPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.15 + (pulseValue * 0.15))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(ovalRect, glowPaint);

    // 3. Primary crisp reticle border
    final strokePaint = Paint()
      ..color = borderColor.withValues(alpha: 0.85 + (pulseValue * 0.15))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawOval(ovalRect, strokePaint);

    // 4. Corner framing brackets around the oval bounding box
    final bracketPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final halfW = ovalWidth / 2 + 8;
    final halfH = ovalHeight / 2 + 8;
    const bracketLen = 20.0;

    // Top-Left
    canvas.drawLine(Offset(center.dx - halfW, center.dy - halfH + bracketLen),
        Offset(center.dx - halfW, center.dy - halfH), bracketPaint);
    canvas.drawLine(Offset(center.dx - halfW, center.dy - halfH),
        Offset(center.dx - halfW + bracketLen, center.dy - halfH), bracketPaint);

    // Top-Right
    canvas.drawLine(Offset(center.dx + halfW, center.dy - halfH + bracketLen),
        Offset(center.dx + halfW, center.dy - halfH), bracketPaint);
    canvas.drawLine(Offset(center.dx + halfW, center.dy - halfH),
        Offset(center.dx + halfW - bracketLen, center.dy - halfH), bracketPaint);

    // Bottom-Left
    canvas.drawLine(Offset(center.dx - halfW, center.dy + halfH - bracketLen),
        Offset(center.dx - halfW, center.dy + halfH), bracketPaint);
    canvas.drawLine(Offset(center.dx - halfW, center.dy + halfH),
        Offset(center.dx - halfW + bracketLen, center.dy + halfH), bracketPaint);

    // Bottom-Right
    canvas.drawLine(Offset(center.dx + halfW, center.dy + halfH - bracketLen),
        Offset(center.dx + halfW, center.dy + halfH), bracketPaint);
    canvas.drawLine(Offset(center.dx + halfW, center.dy + halfH),
        Offset(center.dx + halfW - bracketLen, center.dy + halfH), bracketPaint);

    // 5. Animated scanning beam ONLY activates after capturing the photo
    if (isScanning) {
      canvas.save();
      canvas.clipPath(ovalPath);

      final beamY = center.dy - (ovalHeight / 2) + (ovalHeight * scanProgress);
      final beamPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            borderColor.withValues(alpha: 0.0),
            borderColor.withValues(alpha: 0.25),
            borderColor.withValues(alpha: 0.65),
            borderColor.withValues(alpha: 0.25),
            borderColor.withValues(alpha: 0.0),
          ],
        ).createShader(
            Rect.fromLTWH(center.dx - halfW, beamY - 18, ovalWidth, 36));

      canvas.drawRect(
        Rect.fromLTWH(center.dx - halfW, beamY - 18, ovalWidth, 36),
        beamPaint,
      );

      // Horizontal laser line
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(center.dx - ovalWidth * 0.4, beamY),
        Offset(center.dx + ovalWidth * 0.4, beamY),
        linePaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant FaceReticlePainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.scanProgress != scanProgress ||
        oldDelegate.isScanning != isScanning;
  }
}
