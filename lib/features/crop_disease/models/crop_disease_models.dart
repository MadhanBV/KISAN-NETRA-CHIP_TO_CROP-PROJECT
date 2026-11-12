// Data models for YOLO26s Leaf Disease Detection and RAG Agricultural Diagnosis.

class BoundingBox {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  const BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x1: (json['x1'] as num?)?.toDouble() ?? 0.0,
      y1: (json['y1'] as num?)?.toDouble() ?? 0.0,
      x2: (json['x2'] as num?)?.toDouble() ?? 0.0,
      y2: (json['y2'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'x1': x1, 'y1': y1, 'x2': x2, 'y2': y2};
}

class DetectionItem {
  final String className;
  final int classId;
  final double confidence;
  final String crop;
  final String condition;
  final bool isHealthy;
  final BoundingBox box;
  final BoundingBox boxNormalized;

  const DetectionItem({
    required this.className,
    required this.classId,
    required this.confidence,
    required this.crop,
    required this.condition,
    required this.isHealthy,
    required this.box,
    required this.boxNormalized,
  });

  factory DetectionItem.fromJson(Map<String, dynamic> json) {
    return DetectionItem(
      className: json['class_name'] as String? ?? '',
      classId: (json['class_id'] as num?)?.toInt() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      crop: json['crop'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      isHealthy: json['is_healthy'] as bool? ?? false,
      box: BoundingBox.fromJson(json['box'] as Map<String, dynamic>? ?? {}),
      boxNormalized: BoundingBox.fromJson(
        json['box_normalized'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class DiagnosisContent {
  final String overview;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> favorableConditions;
  final String severity;
  final List<String> organicManagement;
  final List<String> chemicalManagement;
  final List<String> prevention;
  final List<String> farmerRecommendations;

  const DiagnosisContent({
    required this.overview,
    required this.symptoms,
    required this.causes,
    required this.favorableConditions,
    required this.severity,
    required this.organicManagement,
    required this.chemicalManagement,
    required this.prevention,
    required this.farmerRecommendations,
  });

  factory DiagnosisContent.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      }
      return [];
    }

    return DiagnosisContent(
      overview: json['overview'] as String? ?? '',
      symptoms: parseList(json['symptoms']),
      causes: parseList(json['causes']),
      favorableConditions: parseList(json['favorable_conditions']),
      severity: json['severity'] as String? ?? 'Standard',
      organicManagement: parseList(json['organic_management']),
      chemicalManagement: parseList(json['chemical_management']),
      prevention: parseList(json['prevention']),
      farmerRecommendations: parseList(json['farmer_recommendations']),
    );
  }
}

class KnowledgeSource {
  final String sourceFile;
  final String crop;
  final String section;
  final double similarity;

  const KnowledgeSource({
    required this.sourceFile,
    required this.crop,
    required this.section,
    required this.similarity,
  });

  factory KnowledgeSource.fromJson(Map<String, dynamic> json) {
    return KnowledgeSource(
      sourceFile: json['source_file'] as String? ?? '',
      crop: json['crop'] as String? ?? '',
      section: json['section'] as String? ?? '',
      similarity: (json['similarity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CropDiagnosisResponse {
  final bool success;
  final String crop;
  final String detectedCondition;
  final String className;
  final double confidence;
  final bool isHealthy;
  final int imageWidth;
  final int imageHeight;
  final List<DetectionItem> detections;
  final DiagnosisContent diagnosis;
  final List<KnowledgeSource> knowledgeSources;
  final String disclaimer;
  final String language;

  const CropDiagnosisResponse({
    required this.success,
    required this.crop,
    required this.detectedCondition,
    required this.className,
    required this.confidence,
    required this.isHealthy,
    required this.imageWidth,
    required this.imageHeight,
    required this.detections,
    required this.diagnosis,
    required this.knowledgeSources,
    required this.disclaimer,
    required this.language,
  });

  factory CropDiagnosisResponse.fromJson(Map<String, dynamic> json) {
    return CropDiagnosisResponse(
      success: json['success'] as bool? ?? false,
      crop: json['crop'] as String? ?? 'Crop',
      detectedCondition: json['detected_condition'] as String? ?? 'Unknown',
      className: json['class_name'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      isHealthy: json['is_healthy'] as bool? ?? false,
      imageWidth: (json['image_width'] as num?)?.toInt() ?? 640,
      imageHeight: (json['image_height'] as num?)?.toInt() ?? 640,
      detections: (json['detections'] as List? ?? [])
          .map((e) => DetectionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      diagnosis: DiagnosisContent.fromJson(
        json['diagnosis'] as Map<String, dynamic>? ?? {},
      ),
      knowledgeSources: (json['knowledge_sources'] as List? ?? [])
          .map((e) => KnowledgeSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      disclaimer: json['disclaimer'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
    );
  }
}

class QualityDetectionItem {
  final String className;
  final int classId;
  final double confidence;
  final String crop;
  final String qualityStatus;
  final bool isFresh;
  final String gradeLabel;
  final BoundingBox box;
  final BoundingBox boxNormalized;

  const QualityDetectionItem({
    required this.className,
    required this.classId,
    required this.confidence,
    required this.crop,
    required this.qualityStatus,
    required this.isFresh,
    required this.gradeLabel,
    required this.box,
    required this.boxNormalized,
  });

  factory QualityDetectionItem.fromJson(Map<String, dynamic> json) {
    return QualityDetectionItem(
      className: json['class_name'] as String? ?? '',
      classId: (json['class_id'] as num?)?.toInt() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      crop: json['crop'] as String? ?? '',
      qualityStatus: json['quality_status'] as String? ?? '',
      isFresh: json['is_fresh'] as bool? ?? true,
      gradeLabel: json['grade_label'] as String? ?? '',
      box: BoundingBox.fromJson(json['box'] as Map<String, dynamic>? ?? {}),
      boxNormalized: BoundingBox.fromJson(
        json['box_normalized'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class QualityReportContent {
  final String overview;
  final String freshnessScore;
  final String marketGrade;
  final String shelfLifeEstimate;
  final List<String> storageGuidelines;
  final List<String> packagingAndHandling;
  final List<String> segregationAndSanitation;
  final List<String> mandiAdvisory;
  final List<String> preventionOfSpoilage;

  const QualityReportContent({
    required this.overview,
    required this.freshnessScore,
    required this.marketGrade,
    required this.shelfLifeEstimate,
    required this.storageGuidelines,
    required this.packagingAndHandling,
    required this.segregationAndSanitation,
    required this.mandiAdvisory,
    required this.preventionOfSpoilage,
  });

  factory QualityReportContent.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      }
      return [];
    }

    return QualityReportContent(
      overview: json['overview'] as String? ?? '',
      freshnessScore: json['freshness_score'] as String? ?? '',
      marketGrade: json['market_grade'] as String? ?? 'Grade A',
      shelfLifeEstimate: json['shelf_life_estimate'] as String? ?? '',
      storageGuidelines: parseList(json['storage_guidelines']),
      packagingAndHandling: parseList(json['packaging_and_handling']),
      segregationAndSanitation: parseList(json['segregation_and_sanitation']),
      mandiAdvisory: parseList(json['mandi_advisory']),
      preventionOfSpoilage: parseList(json['prevention_of_spoilage']),
    );
  }
}

class CropQualityResponse {
  final bool success;
  final String crop;
  final String qualityStatus;
  final String className;
  final double confidence;
  final bool isFresh;
  final String gradeLabel;
  final int imageWidth;
  final int imageHeight;
  final List<QualityDetectionItem> detections;
  final QualityReportContent qualityReport;
  final List<KnowledgeSource> knowledgeSources;
  final String disclaimer;
  final String language;

  const CropQualityResponse({
    required this.success,
    required this.crop,
    required this.qualityStatus,
    required this.className,
    required this.confidence,
    required this.isFresh,
    required this.gradeLabel,
    required this.imageWidth,
    required this.imageHeight,
    required this.detections,
    required this.qualityReport,
    required this.knowledgeSources,
    required this.disclaimer,
    required this.language,
  });

  factory CropQualityResponse.fromJson(Map<String, dynamic> json) {
    return CropQualityResponse(
      success: json['success'] as bool? ?? false,
      crop: json['crop'] as String? ?? 'Produce',
      qualityStatus: json['quality_status'] as String? ?? 'Fresh',
      className: json['class_name'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      isFresh: json['is_fresh'] as bool? ?? true,
      gradeLabel: json['grade_label'] as String? ?? 'Grade A',
      imageWidth: (json['image_width'] as num?)?.toInt() ?? 640,
      imageHeight: (json['image_height'] as num?)?.toInt() ?? 640,
      detections: (json['detections'] as List? ?? [])
          .map((e) => QualityDetectionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      qualityReport: QualityReportContent.fromJson(
        json['quality_report'] as Map<String, dynamic>? ?? {},
      ),
      knowledgeSources: (json['knowledge_sources'] as List? ?? [])
          .map((e) => KnowledgeSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      disclaimer: json['disclaimer'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
    );
  }
}
