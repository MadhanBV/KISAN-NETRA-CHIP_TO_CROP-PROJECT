import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/database/local_db_service.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/services/pdf_service.dart';
import '../../ai_assistant/screens/ai_assistant_screen.dart';
import '../../ai_assistant/services/voice_service.dart';
import '../../ai_assistant/widgets/clean_ai_text_view.dart';
import '../models/crop_disease_models.dart';

/// Comprehensive produce quality & freshness assessment report.
/// Displays YOLO quality detection bounding boxes, APMC market grade,
/// shelf-life estimates, storage protocols, and Sarvam-powered multi-lingual TTS.
class CropQualityReportScreen extends StatefulWidget {
  final CropQualityResponse qualityResponse;
  final Uint8List imageBytes;

  const CropQualityReportScreen({
    super.key,
    required this.qualityResponse,
    required this.imageBytes,
  });

  @override
  State<CropQualityReportScreen> createState() => _CropQualityReportScreenState();
}

class _CropQualityReportScreenState extends State<CropQualityReportScreen> {
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
      await LocalDbService.instance.saveQualityReport(
        qualityResponse: widget.qualityResponse,
        imageBytes: widget.imageBytes,
        language: _selectedAudioLanguage,
      );
    } catch (e) {
      debugPrint('Quality report auto-save error: $e');
    }
  }

  Future<void> _downloadPdf() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating official PDF quality report...'),
          duration: Duration(seconds: 1),
        ),
      );
      await PdfService.generateAndShareQualityReport(
        qualityResponse: widget.qualityResponse,
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
    if (_isPlaying) {
      await _voiceService.stop();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isLoadingAudio = true);

    final q = widget.qualityResponse;
    final r = q.qualityReport;
    final isFresh = q.isFresh;

    final String speechText = isFresh
        ? '${q.crop} quality assessment: Prime Grade A fresh quality detected with ${(q.confidence * 100).toInt()}% confidence. '
            'Estimated shelf life: ${r.shelfLifeEstimate}. '
            'Storage recommendation: ${r.storageGuidelines.isNotEmpty ? r.storageGuidelines.first : "Keep in ventilated packhouse"}. '
            'Mandi advisory: ${r.mandiAdvisory.isNotEmpty ? r.mandiAdvisory.first : "Prime market pricing"}.'
        : 'Warning! Spoilage detected on ${q.crop} with ${(q.confidence * 100).toInt()}% confidence. '
            'Estimated shelf life is critical. '
            'Immediate segregation is mandatory to prevent fungal spore spread. '
            '${r.segregationAndSanitation.isNotEmpty ? r.segregationAndSanitation.first : "Disinfect crates with 0.1% sodium hypochlorite."}';

    await _voiceService.speak(speechText, languageCode: _selectedAudioLanguage);
    if (mounted) {
      setState(() => _isLoadingAudio = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.qualityResponse;
    final r = q.qualityReport;
    final isFresh = q.isFresh;

    final primaryThemeColor = isFresh ? const Color(0xFF0F4D33) : const Color(0xFF8B2500);
    final accentThemeColor = isFresh ? const Color(0xFF1B8A5A) : const Color(0xFFD32F2F);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        title: Text(
          '${q.crop} Quality Assessment',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: primaryThemeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Download Official PDF',
            onPressed: _downloadPdf,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Report',
            onPressed: _downloadPdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Scanned Image with Detection Bounding Boxes
            _buildImageHeroCard(primaryThemeColor, accentThemeColor),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 2. Freshness Status Banner
                  _buildStatusBanner(isFresh, accentThemeColor),

                  const SizedBox(height: 16),

                  // 3. Audio Voice Advisory Bar
                  _buildAudioAdvisoryCard(primaryThemeColor),

                  const SizedBox(height: 16),

                  // 4. Key Metrics Grid
                  _buildMetricsGrid(q, r, isFresh),

                  const SizedBox(height: 16),

                  // 5. Executive Assessment Overview
                  if (r.overview.isNotEmpty) ...[
                    _buildSectionCard(
                      title: 'Executive Assessment Summary',
                      icon: Icons.analytics_outlined,
                      iconColor: const Color(0xFF2E7D32),
                      child: CleanAiTextView(text: r.overview),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 6. Post-Harvest Storage Guidelines
                  if (r.storageGuidelines.isNotEmpty) ...[
                    _buildSectionCard(
                      title: 'Optimal Post-Harvest Storage',
                      icon: Icons.ac_unit_rounded,
                      iconColor: const Color(0xFF0277BD),
                      child: _buildBulletList(r.storageGuidelines, Icons.check_circle_outline_rounded, const Color(0xFF0277BD)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 7. Packaging & Handling Practices
                  if (r.packagingAndHandling.isNotEmpty) ...[
                    _buildSectionCard(
                      title: 'Packaging & Transit Handling',
                      icon: Icons.inventory_2_outlined,
                      iconColor: const Color(0xFFE65100),
                      child: _buildBulletList(r.packagingAndHandling, Icons.arrow_right_rounded, const Color(0xFFE65100)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 8. Segregation & Sanitation Protocols
                  if (r.segregationAndSanitation.isNotEmpty) ...[
                    _buildSectionCard(
                      title: isFresh ? 'Lot Segregation Standards' : 'Mandatory Sanitation & Quarantine',
                      icon: isFresh ? Icons.rule_rounded : Icons.healing_rounded,
                      iconColor: isFresh ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      child: _buildBulletList(
                        r.segregationAndSanitation,
                        isFresh ? Icons.verified_outlined : Icons.warning_rounded,
                        isFresh ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 9. Mandi Dispatch & Pricing Advisory
                  if (r.mandiAdvisory.isNotEmpty) ...[
                    _buildSectionCard(
                      title: 'APMC Mandi Marketing Advisory',
                      icon: Icons.storefront_outlined,
                      iconColor: const Color(0xFF4527A0),
                      child: _buildBulletList(r.mandiAdvisory, Icons.trending_up_rounded, const Color(0xFF4527A0)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 10. Prevention of Spoilage
                  if (r.preventionOfSpoilage.isNotEmpty) ...[
                    _buildSectionCard(
                      title: 'Long-Term Spoilage Prevention',
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFF2E7D32),
                      child: _buildBulletList(r.preventionOfSpoilage, Icons.eco_outlined, const Color(0xFF2E7D32)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 11. Grounded Knowledge Citations
                  if (q.knowledgeSources.isNotEmpty) ...[
                    _buildKnowledgeSourcesCard(q.knowledgeSources),
                    const SizedBox(height: 20),
                  ],

                  // 12. Bottom Action Buttons
                  _buildBottomActionButtons(q),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeroCard(Color primaryColor, Color accentColor) {
    return Container(
      color: Colors.black,
      height: 280,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            widget.imageBytes,
            fit: BoxFit.contain,
          ),
          CustomPaint(
            painter: _QualityBoxPainter(
              detections: widget.qualityResponse.detections,
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.center_focus_strong, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.qualityResponse.detections.length} Produce Detected',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(bool isFresh, Color accentColor) {
    final q = widget.qualityResponse;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFresh ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFresh ? const Color(0xFFA5D6A7) : const Color(0xFFFFCDD2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isFresh ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFresh ? Icons.verified_rounded : Icons.warning_amber_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFresh ? 'Fresh Quality Produce' : 'Produce Spoilage Detected',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isFresh ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  q.gradeLabel,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isFresh ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isFresh
                      ? 'Complies with standard APMC Grade A market benchmarks.'
                      : 'Immediate segregation recommended to avoid batch cross-contamination.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioAdvisoryCard(Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isPlaying ? const Color(0xFF0F4D33) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isPlaying ? const Color(0xFF0F4D33) : Colors.grey.shade200,
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
          // Row 1: Header + Listen Button
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _isPlaying
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFF0F4D33).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.record_voice_over_rounded,
                  color: _isPlaying ? Colors.white : const Color(0xFF0F4D33),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPlaying ? 'Speaking Quality Advisory' : 'Listen to Advisory',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _isPlaying ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
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
                onTap: _isLoadingAudio ? null : _toggleAudioAdvisory,
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
                      if (_isLoadingAudio)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      else
                        Icon(
                          _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        _isLoadingAudio ? 'Loading...' : (_isPlaying ? 'Stop' : 'Listen'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
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
                      color: _isPlaying
                          ? Colors.white.withValues(alpha: 0.15)
                          : const Color(0xFFF3F5F3),
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
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (newLang) {
                          if (newLang != null) {
                            setState(() => _selectedAudioLanguage = newLang);
                            if (_isPlaying) {
                              _voiceService.stop();
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
    );
  }

  Widget _buildMetricsGrid(CropQualityResponse q, QualityReportContent r, bool isFresh) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            label: 'Freshness Score',
            value: r.freshnessScore.isNotEmpty ? r.freshnessScore : '${(q.confidence * 100).toInt()}%',
            icon: Icons.speed_rounded,
            color: isFresh ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            label: 'Estimated Shelf Life',
            value: r.shelfLifeEstimate.isNotEmpty ? r.shelfLifeEstimate : '7–10 Days',
            icon: Icons.hourglass_top_rounded,
            color: const Color(0xFF0277BD),
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
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

  Widget _buildBulletList(List<String> items, IconData bulletIcon, Color iconColor) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(bulletIcon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKnowledgeSourcesCard(List<KnowledgeSource> sources) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.verified_outlined, size: 16, color: Color(0xFF2E7D32)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Grounded Knowledge Sources (RAG ChromaDB)',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...sources.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${s.sourceFile} (${s.crop.toUpperCase()}) — Similarity: ${(s.similarity * 100).toInt()}%',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF388E3C)),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons(CropQualityResponse q) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4D33),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AiAssistantScreen(),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
            label: const Text(
              'Ask AI Assistant About This Crop',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF0F4D33)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _downloadPdf,
            icon: const Icon(Icons.download_rounded, color: Color(0xFF0F4D33), size: 20),
            label: const Text(
              'Download PDF Quality Certificate',
              style: TextStyle(color: Color(0xFF0F4D33), fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

/// Custom painter for overlaying YOLO bounding boxes on the scanned produce image.
class _QualityBoxPainter extends CustomPainter {
  final List<QualityDetectionItem> detections;

  _QualityBoxPainter({required this.detections});

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty) return;

    for (final det in detections) {
      final box = det.boxNormalized;
      final rect = Rect.fromLTRB(
        box.x1 * size.width,
        box.y1 * size.height,
        box.x2 * size.width,
        box.y2 * size.height,
      );

      final boxColor = det.isFresh ? const Color(0xFF00E676) : const Color(0xFFFF1744);

      final strokePaint = Paint()
        ..color = boxColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), strokePaint);

      // Label badge
      final textSpan = TextSpan(
        text: ' ${det.crop}: ${det.qualityStatus} (${(det.confidence * 100).toInt()}%) ',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final labelRect = Rect.fromLTWH(
        rect.left,
        max(0.0, rect.top - 20),
        textPainter.width + 4,
        20,
      );

      final bgPaint = Paint()..color = boxColor.withValues(alpha: 0.85);
      canvas.drawRRect(RRect.fromRectAndRadius(labelRect, const Radius.circular(4)), bgPaint);
      textPainter.paint(canvas, Offset(labelRect.left + 2, labelRect.top + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _QualityBoxPainter oldDelegate) => true;

  double max(double a, double b) => a > b ? a : b;
}
