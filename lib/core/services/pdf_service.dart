import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/crop_disease/models/crop_disease_models.dart';

class PdfService {
  /// Generates a professional, branded agricultural PDF diagnosis report
  /// and opens the system print/save/share sheet.
  static Future<void> generateAndShareReport({
    required CropDiagnosisResponse diagnosis,
    required Uint8List imageBytes,
    String? language,
  }) async {
    final pdf = pw.Document();

    final imageWidget = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#0F4D33'),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CHIP TO CROP',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'AI-Powered Agricultural Diagnosis Report',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      DateTime.now().toString().split('.').first,
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // 2. Crop & Condition Card + Image
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Photo
                  pw.Container(
                    width: 140,
                    height: 140,
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.ClipRRect(
                      horizontalRadius: 8,
                      verticalRadius: 8,
                      child: pw.Image(imageWidget, fit: pw.BoxFit.cover),
                    ),
                  ),
                  pw.SizedBox(width: 18),
                  // Details
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Crop: ${diagnosis.crop.toUpperCase()}',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#0F4D33'),
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Detected Condition: ${diagnosis.detectedCondition}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: diagnosis.isHealthy
                                ? PdfColor.fromHex('#1B8755')
                                : PdfColor.fromHex('#DC2626'),
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Confidence Score: ${(diagnosis.confidence * 100).toStringAsFixed(1)}%',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Health Status: ${diagnosis.isHealthy ? "Healthy" : "Infection / Disease Detected"}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: diagnosis.isHealthy ? PdfColors.green800 : PdfColors.red800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 18),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 10),

              // 3. Clinical Overview
              if (diagnosis.diagnosis.overview.isNotEmpty) ...[
                pw.Text(
                  'Overview & Agronomic Assessment',
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  diagnosis.diagnosis.overview,
                  style: const pw.TextStyle(fontSize: 10.5, color: PdfColors.grey800),
                ),
                pw.SizedBox(height: 12),
              ],

              // 4. Symptoms
              if (diagnosis.diagnosis.symptoms.isNotEmpty) ...[
                pw.Text(
                  'Key Symptoms Identified',
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                ...diagnosis.diagnosis.symptoms.map(
                  (s) => pw.Bullet(text: s, style: const pw.TextStyle(fontSize: 10.5)),
                ),
                pw.SizedBox(height: 12),
              ],

              // 5. Organic Management
              if (diagnosis.diagnosis.organicManagement.isNotEmpty) ...[
                pw.Text(
                  'Organic & Biological Remedies (Safe Farming)',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#1B8755'),
                  ),
                ),
                pw.SizedBox(height: 4),
                ...diagnosis.diagnosis.organicManagement.map(
                  (s) => pw.Bullet(text: s, style: const pw.TextStyle(fontSize: 10.5)),
                ),
                pw.SizedBox(height: 12),
              ],

              // 6. Chemical Management
              if (diagnosis.diagnosis.chemicalManagement.isNotEmpty) ...[
                pw.Text(
                  'Chemical Management (Recommended Dosages)',
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                ...diagnosis.diagnosis.chemicalManagement.map(
                  (s) => pw.Bullet(text: s, style: const pw.TextStyle(fontSize: 10.5)),
                ),
                pw.SizedBox(height: 12),
              ],

              // 7. Preventive Practices
              if (diagnosis.diagnosis.prevention.isNotEmpty) ...[
                pw.Text(
                  'Preventive & Cultural Practices',
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                ...diagnosis.diagnosis.prevention.map(
                  (s) => pw.Bullet(text: s, style: const pw.TextStyle(fontSize: 10.5)),
                ),
                pw.SizedBox(height: 12),
              ],

              pw.Spacer(),

              // Footer
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.only(top: 8),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
                ),
                child: pw.Text(
                  'Generated by CHIP TO CROP Grounded Agricultural RAG Engine. Always verify dosages with local agricultural extension officers.',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Open native share / print sheet
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'CHIP_TO_CROP_${diagnosis.crop}_diagnosis.pdf',
    );
  }

  /// Generates a professional agricultural PDF quality and freshness assessment report.
  static Future<void> generateAndShareQualityReport({
    required CropQualityResponse qualityResponse,
    required Uint8List imageBytes,
    String? language,
  }) async {
    final pdf = pw.Document();
    final imageWidget = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          final isFresh = qualityResponse.isFresh;
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#0F4D33'),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CHIP TO CROP',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Crop Quality & Freshness Assessment Report',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      DateTime.now().toString().split('.').first,
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Image and Summary
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.ClipRRect(
                    horizontalRadius: 8,
                    verticalRadius: 8,
                    child: pw.Image(imageWidget, width: 130, height: 130, fit: pw.BoxFit.cover),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${qualityResponse.crop} Quality Evaluation',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#0F4D33'),
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Quality Status: ${qualityResponse.qualityStatus}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: isFresh ? PdfColor.fromHex('#107C41') : PdfColor.fromHex('#D83B01'),
                          ),
                        ),
                        pw.Text(
                          'Market Grade: ${qualityResponse.gradeLabel}',
                          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
                        ),
                        pw.Text(
                          'Freshness Score: ${qualityResponse.qualityReport.freshnessScore}',
                          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
                        ),
                        pw.Text(
                          'Estimated Shelf Life: ${qualityResponse.qualityReport.shelfLifeEstimate}',
                          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
                        ),
                        pw.Text(
                          'AI Model Confidence: ${(qualityResponse.confidence * 100).toStringAsFixed(1)}%',
                          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 14),

              // Overview
              if (qualityResponse.qualityReport.overview.isNotEmpty) ...[
                pw.Text(
                  'Assessment Summary',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  qualityResponse.qualityReport.overview,
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                ),
                pw.SizedBox(height: 10),
              ],

              // Storage Guidelines
              if (qualityResponse.qualityReport.storageGuidelines.isNotEmpty) ...[
                pw.Text(
                  'Recommended Post-Harvest Storage',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                ...qualityResponse.qualityReport.storageGuidelines.take(3).map(
                  (s) => pw.Bullet(text: s, style: const pw.TextStyle(fontSize: 10)),
                ),
                pw.SizedBox(height: 10),
              ],

              // Mandi & Market Advisory
              if (qualityResponse.qualityReport.mandiAdvisory.isNotEmpty) ...[
                pw.Text(
                  'APMC Mandi & Marketing Advisory',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                ...qualityResponse.qualityReport.mandiAdvisory.take(3).map(
                  (s) => pw.Bullet(text: s, style: const pw.TextStyle(fontSize: 10)),
                ),
                pw.SizedBox(height: 10),
              ],

              pw.Spacer(),

              // Footer
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.only(top: 8),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
                ),
                child: pw.Text(
                  'Generated by CHIP TO CROP Quality Vision & RAG Engine. Verify lot parameters prior to APMC auction.',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'CHIP_TO_CROP_${qualityResponse.crop}_quality_report.pdf',
    );
  }
}

