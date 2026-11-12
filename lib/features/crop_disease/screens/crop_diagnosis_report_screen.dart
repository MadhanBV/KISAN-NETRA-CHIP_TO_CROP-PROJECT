import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/database/local_db_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/services/pdf_service.dart';
import '../../ai_assistant/screens/ai_assistant_screen.dart';
import '../../ai_assistant/services/voice_service.dart';
import '../../ai_assistant/widgets/clean_ai_text_view.dart';
import '../models/crop_disease_models.dart';

/// Comprehensive, farmer-friendly diagnosis report screen.
/// Displays YOLO26s detection boxes, confidence meters, grounded RAG guidance,
/// and Sarvam-powered Text-to-Speech (TTS) voice advisory in any regional language.
class CropDiagnosisReportScreen extends StatefulWidget {
  final CropDiagnosisResponse diagnosis;
  final Uint8List imageBytes;

  const CropDiagnosisReportScreen({
    super.key,
    required this.diagnosis,
    required this.imageBytes,
  });

  @override
  State<CropDiagnosisReportScreen> createState() => _CropDiagnosisReportScreenState();
}

class _CropDiagnosisReportScreenState extends State<CropDiagnosisReportScreen> {
  final VoiceService _voiceService = VoiceService();
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  late String _selectedAudioLanguage;

  final Map<String, String> _supportedAudioLanguages = {
    'hi': 'हिन्दी (Hindi)',
    'en': 'English',
    'te': 'తెలుగు (Telugu)',
    'ta': 'தமிழ் (Tamil)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'mr': 'मराठी (Marathi)',
    'bn': 'বাংলা (Bengali)',
    'gu': 'ગુજરાતી (Gujarati)',
    'pa': 'ਪੰਜਾਬੀ (Punjabi)',
    'ml': 'മലയാളം (Malayalam)',
  };

  @override
  void initState() {
    super.initState();
    final appLang = LocaleController.instance.currentLanguage.languageCode;
    _selectedAudioLanguage = _supportedAudioLanguages.containsKey(appLang) ? appLang : 'hi';
    _voiceService.speakingNotifier.addListener(_onSpeakingChanged);
    _autoSaveReport();
  }

  Future<void> _autoSaveReport() async {
    try {
      await LocalDbService.instance.saveReport(
        diagnosis: widget.diagnosis,
        imageBytes: widget.imageBytes,
        language: _selectedAudioLanguage,
      );
    } catch (e) {
      debugPrint('Auto-save error: $e');
    }
  }

  Future<void> _downloadPdf() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating official PDF report...'),
          duration: Duration(seconds: 1),
        ),
      );
      await PdfService.generateAndShareReport(
        diagnosis: widget.diagnosis,
        imageBytes: widget.imageBytes,
        language: _selectedAudioLanguage,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  void _onSpeakingChanged() {
    if (mounted) {
      setState(() {
        _isPlaying = _voiceService.speakingNotifier.value;
        if (!_isPlaying) _isLoadingAudio = false;
      });
    }
  }

  @override
  void dispose() {
    _voiceService.speakingNotifier.removeListener(_onSpeakingChanged);
    _voiceService.stop();
    super.dispose();
  }

  Future<void> _toggleAudioAdvisory() async {
    if (_isPlaying || _isLoadingAudio) {
      await _voiceService.stop();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoadingAudio = false;
        });
      }
      return;
    }

    setState(() => _isLoadingAudio = true);

    final d = widget.diagnosis;
    final buffer = StringBuffer();
    buffer.write('${d.crop} crop advisory report. ');
    if (d.isHealthy) {
      buffer.write('The leaf is healthy with no significant disease lesions detected. ');
    } else {
      buffer.write('Detected condition: ${d.detectedCondition}. ');
    }
    if (d.diagnosis.overview.isNotEmpty) {
      buffer.write('${d.diagnosis.overview} ');
    }
    if (d.diagnosis.organicManagement.isNotEmpty) {
      buffer.write('Organic remedy: ${d.diagnosis.organicManagement.take(2).join(". ")}. ');
    }
    if (d.diagnosis.prevention.isNotEmpty) {
      buffer.write('Preventive care: ${d.diagnosis.prevention.take(1).join(". ")}. ');
    }

    try {
      await _voiceService.speak(
        buffer.toString(),
        languageCode: _selectedAudioLanguage,
      );
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
          _isPlaying = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
          _isPlaying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not play audio advisory: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagnosis = widget.diagnosis;
    final imageBytes = widget.imageBytes;
    final isHealthy = diagnosis.isHealthy;
    final primaryAccent = isHealthy ? const Color(0xFF1B8755) : const Color(0xFFD9534F);
    final bgTint = isHealthy ? const Color(0xFFE8F7EE) : const Color(0xFFFDF0ED);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${diagnosis.crop} Diagnosis Report',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _isPlaying ? const Color(0xFF1B8755) : AppColors.textPrimary,
            ),
            tooltip: _isPlaying ? 'Stop Speech' : 'Listen to Report',
            onPressed: _toggleAudioAdvisory,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.textPrimary),
            tooltip: 'Download PDF Report',
            onPressed: _downloadPdf,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            tooltip: 'Share PDF',
            onPressed: _downloadPdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Hero Condition Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: bgTint,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryAccent.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: primaryAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isHealthy ? Icons.verified_rounded : Icons.warning_amber_rounded,
                      color: primaryAccent,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHealthy ? 'Healthy Foliage' : diagnosis.detectedCondition,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: primaryAccent,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'YOLO26s Confidence: ${(diagnosis.confidence * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isHealthy ? 'CLEAN' : 'ALERT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. Audio Advisory Card (Sarvam AI Voice Reader)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isPlaying ? const Color(0xFF0F4D33) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isPlaying ? const Color(0xFF5AB688) : const Color(0xFF5AB688).withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Icon, Title, and Listen Button
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _isPlaying ? const Color(0xFF5AB688) : const Color(0xFFEBF7F0),
                          shape: BoxShape.circle,
                        ),
                        child: _isLoadingAudio
                            ? const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Color(0xFF0F4D33),
                                  ),
                                ),
                              )
                            : Icon(
                                _isPlaying ? Icons.stop_rounded : Icons.record_voice_over_rounded,
                                color: _isPlaying ? Colors.white : const Color(0xFF0F4D33),
                                size: 22,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isPlaying ? 'Speaking Advisory Aloud...' : 'Listen to Audio Advisory',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: _isPlaying ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'AI Voice • Tap Listen or change language',
                              style: TextStyle(
                                fontSize: 11,
                                color: _isPlaying ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: _toggleAudioAdvisory,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isPlaying ? const Color(0xFFD9534F) : const Color(0xFF0F4D33),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isPlaying ? 'Stop' : 'Listen',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    color: _isPlaying ? Colors.white24 : Colors.black.withValues(alpha: 0.06),
                  ),
                  const SizedBox(height: 8),
                  // Row 2: Speech Language Selector
                  Row(
                    children: [
                      Icon(
                        Icons.language_rounded,
                        size: 16,
                        color: _isPlaying ? Colors.white70 : const Color(0xFF0F4D33),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Language:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isPlaying ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _isPlaying ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFF3F5F3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedAudioLanguage,
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                isDense: true,
                                icon: Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: _isPlaying ? Colors.white : const Color(0xFF0F4D33),
                                ),
                                items: _supportedAudioLanguages.entries.map((e) {
                                  return DropdownMenuItem<String>(
                                    value: e.key,
                                    child: Text(
                                      e.value,
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newLang) {
                                  if (newLang != null) {
                                    setState(() => _selectedAudioLanguage = newLang);
                                    final appLang = AppLanguage.fromCode(newLang);
                                    LocaleController.instance.setLanguage(appLang);
                                    if (_isPlaying) {
                                      _toggleAudioAdvisory();
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Leaf Image with YOLO Bounding Box Overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 230,
                decoration: BoxDecoration(
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(imageBytes, fit: BoxFit.cover),
                    CustomPaint(
                      painter: _YoloBoundingBoxPainter(
                        detections: diagnosis.detections,
                        accentColor: primaryAccent,
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${diagnosis.detections.length} Detection(s)',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 3. AI Overview & Explanation (RAG Grounded)
            _buildCard(
              title: isHealthy ? 'Foliage Health Assessment' : 'Disease Overview',
              icon: Icons.menu_book_rounded,
              iconColor: const Color(0xFF0F4D33),
              child: CleanAiTextView(
                text: diagnosis.diagnosis.overview.isNotEmpty
                    ? diagnosis.diagnosis.overview
                    : 'Grounded agricultural assessment compiled from Kisan Netra repository.',
                isUser: false,
              ),
            ),

            const SizedBox(height: 14),

            // 4. Symptoms & Identification
            if (diagnosis.diagnosis.symptoms.isNotEmpty)
              _buildBulletCard(
                title: 'Visible Symptoms & Identification',
                icon: Icons.search_rounded,
                iconColor: const Color(0xFFD97706),
                items: diagnosis.diagnosis.symptoms,
              ),

            // 5. Causes & Favorable Conditions
            if (diagnosis.diagnosis.causes.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildBulletCard(
                title: 'Causes & Favorable Factors',
                icon: Icons.science_outlined,
                iconColor: const Color(0xFF2563EB),
                items: [
                  ...diagnosis.diagnosis.causes,
                  ...diagnosis.diagnosis.favorableConditions,
                ],
              ),
            ],

            // 6. Organic & Cultural Remedies
            if (diagnosis.diagnosis.organicManagement.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildBulletCard(
                title: 'Organic & Cultural Management',
                icon: Icons.eco_rounded,
                iconColor: const Color(0xFF16A34A),
                items: diagnosis.diagnosis.organicManagement,
              ),
            ],

            // 7. Chemical Treatments & Spraying
            if (diagnosis.diagnosis.chemicalManagement.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildBulletCard(
                title: 'Chemical Control (Follow Official Labels)',
                icon: Icons.medication_outlined,
                iconColor: const Color(0xFFDC2626),
                items: diagnosis.diagnosis.chemicalManagement,
                footer: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: const Text(
                    '⚠️ Always consult your district Krishi Vigyan Kendra (KVK) for localized chemical dosages, safety intervals, and weather suitability before spraying.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF991B1B), height: 1.35),
                  ),
                ),
              ),
            ],

            // 8. Preventive Best Practices
            if (diagnosis.diagnosis.prevention.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildBulletCard(
                title: 'Preventive Best Practices',
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFF0D9488),
                items: diagnosis.diagnosis.prevention,
              ),
            ],

            // 9. ChromaDB Grounded Sources
            if (diagnosis.knowledgeSources.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildSourcesCard(diagnosis.knowledgeSources),
            ],

            const SizedBox(height: 14),

            // 10. AI Disclaimer Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      diagnosis.disclaimer,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 11. Action Buttons: "Ask AI Bot" & "Scan Another Leaf"
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF0F4D33)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF0F4D33), size: 18),
                    label: const Text(
                      'Scan Another',
                      style: TextStyle(color: Color(0xFF0F4D33), fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4D33),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AiAssistantScreen(
                            initialQuestion: 'I scanned a ${diagnosis.crop} leaf with ${diagnosis.detectedCondition}. What organic remedies should I apply?',
                            crop: diagnosis.crop,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'Ask AI Bot',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildBulletCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
    Widget? footer,
  }) {
    return _buildCard(
      title: title,
      icon: icon,
      iconColor: iconColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.map(
            (it) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(color: Color(0xFF0F4D33), fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      it,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ?footer,
        ],
      ),
    );
  }

  Widget _buildSourcesCard(List<KnowledgeSource> sources) {
    return _buildCard(
      title: 'Knowledge Base Citations',
      icon: Icons.source_outlined,
      iconColor: const Color(0xFF7C3AED),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Information retrieved from verified agricultural research files in ChromaDB:',
            style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          ...sources.map(
            (s) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${s.sourceFile} (${s.section})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${(s.similarity * 100).toStringAsFixed(0)}% match',
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF0F4D33), fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YoloBoundingBoxPainter extends CustomPainter {
  final List<DetectionItem> detections;
  final Color accentColor;

  _YoloBoundingBoxPainter({required this.detections, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    for (final det in detections) {
      final box = det.boxNormalized;
      final rect = Rect.fromLTRB(
        box.x1 * size.width,
        box.y1 * size.height,
        box.x2 * size.width,
        box.y2 * size.height,
      );

      // Bounding box outline
      final paint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);

      // Label background pill
      final label = '${det.condition} ${(det.confidence * 100).toStringAsFixed(0)}%';
      final textSpan = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final labelRect = Rect.fromLTWH(
        rect.left,
        max(0, rect.top - textPainter.height - 4),
        textPainter.width + 8,
        textPainter.height + 4,
      );

      final bgPaint = Paint()..color = accentColor;
      canvas.drawRRect(RRect.fromRectAndRadius(labelRect, const Radius.circular(4)), bgPaint);
      textPainter.paint(canvas, Offset(labelRect.left + 4, labelRect.top + 2));
    }
  }

  double max(double a, double b) => a > b ? a : b;

  @override
  bool shouldRepaint(covariant _YoloBoundingBoxPainter oldDelegate) => true;
}
