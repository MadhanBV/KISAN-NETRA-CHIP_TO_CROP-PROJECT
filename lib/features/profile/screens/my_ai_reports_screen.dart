import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/local_db_service.dart';
import '../../../core/services/pdf_service.dart';
import '../../ai_assistant/widgets/clean_ai_text_view.dart';
import '../../crop_disease/models/crop_disease_models.dart';

class MyAiReportsScreen extends StatefulWidget {
  const MyAiReportsScreen({super.key});

  @override
  State<MyAiReportsScreen> createState() => _MyAiReportsScreenState();
}

class _MyAiReportsScreenState extends State<MyAiReportsScreen> {
  List<SavedAiReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final list = await LocalDbService.instance.getAllReports();
    if (mounted) {
      setState(() {
        _reports = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteReport(int id) async {
    await LocalDbService.instance.deleteReport(id);
    _loadReports();
  }

  void _openReportDetail(SavedAiReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${report.crop} Report',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
                      tooltip: 'Download PDF',
                      onPressed: () async {
                        try {
                          final file = File(report.imagePath);
                          final bytes = await file.exists() ? await file.readAsBytes() : null;
                          if (bytes != null) {
                            final diag = CropDiagnosisResponse(
                              success: true,
                              crop: report.crop,
                              detectedCondition: report.detectedCondition,
                              className: report.detectedCondition,
                              confidence: report.confidence,
                              isHealthy: report.isHealthy,
                              imageWidth: 640,
                              imageHeight: 640,
                              detections: const [],
                              diagnosis: DiagnosisContent(
                                overview: report.overview,
                                symptoms: report.symptoms,
                                causes: const [],
                                favorableConditions: const [],
                                severity: report.isHealthy ? 'Healthy' : 'Moderate',
                                organicManagement: report.organicManagement,
                                chemicalManagement: report.chemicalManagement,
                                prevention: report.prevention,
                                farmerRecommendations: const [],
                              ),
                              knowledgeSources: const [],
                              disclaimer: '',
                              language: report.language,
                            );
                            await PdfService.generateAndShareReport(
                              diagnosis: diag,
                              imageBytes: bytes,
                              language: report.language,
                            );
                          }
                        } catch (e) {
                          debugPrint('PDF error: $e');
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (report.imagePath.isNotEmpty && File(report.imagePath).existsSync())
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(report.imagePath),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: report.isHealthy ? const Color(0xFFE8F5E9) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            report.detectedCondition,
                            style: TextStyle(
                              color: report.isHealthy ? const Color(0xFF1B8755) : const Color(0xFFDC2626),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          '${(report.confidence * 100).toStringAsFixed(1)}% Confidence',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (report.overview.isNotEmpty) ...[
                      const Text('Overview', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 6),
                      CleanAiTextView(text: report.overview),
                      const SizedBox(height: 16),
                    ],
                    if (report.organicManagement.isNotEmpty) ...[
                      const Text('Organic Remedies', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1B8755))),
                      const SizedBox(height: 6),
                      ...report.organicManagement.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(color: Color(0xFF1B8755), fontWeight: FontWeight.bold)),
                                Expanded(child: Text(s, style: const TextStyle(fontSize: 13, height: 1.4))),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],
                    if (report.chemicalManagement.isNotEmpty) ...[
                      const Text('Chemical Management', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 6),
                      ...report.chemicalManagement.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                Expanded(child: Text(s, style: const TextStyle(fontSize: 13, height: 1.4))),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My AI Reports',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _reports.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadReports,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final r = _reports[i];
                      return _buildReportCard(r);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No AI Reports Saved Yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Scan crop leaves using the Leaf Disease Detection tool to generate and save reports automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(SavedAiReport report) {
    final imageFile = File(report.imagePath);
    final hasImage = report.imagePath.isNotEmpty && imageFile.existsSync();
    final dateStr = '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}';

    return GestureDetector(
      onTap: () => _openReportDetail(report),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: hasImage
                  ? Image.file(
                      imageFile,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 64,
                      height: 64,
                      color: const Color(0xFF0F4D33).withValues(alpha: 0.1),
                      child: const Icon(Icons.eco_rounded, color: Color(0xFF0F4D33), size: 28),
                    ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        report.crop,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: report.isHealthy ? const Color(0xFFE8F5E9) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            report.detectedCondition,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: report.isHealthy ? const Color(0xFF1B8755) : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(report.confidence * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    report.overview.isNotEmpty ? report.overview : 'Tap to view diagnosis & PDF export.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.grey),
              onPressed: () => _deleteReport(report.id),
            ),
          ],
        ),
      ),
    );
  }
}
