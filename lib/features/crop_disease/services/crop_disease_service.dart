import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/config/app_config.dart';
import '../models/crop_disease_models.dart';

class CropDiseaseService {
  final http.Client _client;

  CropDiseaseService({http.Client? client}) : _client = client ?? http.Client();

  /// Uploads leaf image bytes for YOLO26s detection and RAG agricultural diagnosis.
  Future<CropDiagnosisResponse> diagnoseLeafImage({
    required Uint8List imageBytes,
    required String filename,
    String language = 'en',
    String? cropHint,
  }) async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/crop/diagnose');
    final request = http.MultipartRequest('POST', uri);

    request.fields['language'] = language;
    if (cropHint != null && cropHint.isNotEmpty) {
      request.fields['crop_type'] = cropHint;
    }

    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: filename.endsWith('.jpg') || filename.endsWith('.png')
          ? filename
          : '$filename.jpg',
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);

    try {
      final streamedResponse = await _client.send(request).timeout(
            const Duration(seconds: 180),
          );
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(responseBody);
        return CropDiagnosisResponse.fromJson(data);
      } else {
        String errorMsg = 'Server returned error ${streamedResponse.statusCode}';
        try {
          final errJson = jsonDecode(responseBody);
          if (errJson is Map && errJson.containsKey('detail')) {
            errorMsg = errJson['detail'].toString();
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to communicate with crop diagnosis server: $e');
    }
  }

  /// Sends a conversational agricultural question to the RAG engine via the main backend.
  Future<Map<String, dynamic>> askAssistant({
    required String question,
    String? crop,
    String language = 'en',
  }) async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/crop/chat');
    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'question': question,
              if (crop != null && crop.isNotEmpty) 'crop': crop,
              'language': language,
            }),
          )
          .timeout(const Duration(seconds: 180));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Assistant error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to AI Assistant: $e');
    }
  }

  /// Checks whether YOLO and RAG models are active.
  Future<Map<String, dynamic>> checkModelsStatus() async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/crop/models/status');
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'yolo_model_available': false, 'rag_engine_available': false};
    } catch (_) {
      return {'yolo_model_available': false, 'rag_engine_available': false};
    }
  }

  /// Uploads crop produce image bytes for Quality YOLO detection (Fresh vs Rotten) and RAG post-harvest advisory.
  Future<CropQualityResponse> analyzeCropQuality({
    required Uint8List imageBytes,
    required String filename,
    String language = 'en',
    String? cropHint,
  }) async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/crop/quality/analyze');
    final request = http.MultipartRequest('POST', uri);

    request.fields['language'] = language;
    if (cropHint != null && cropHint.isNotEmpty) {
      request.fields['crop_type'] = cropHint;
    }

    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: filename.endsWith('.jpg') || filename.endsWith('.png')
          ? filename
          : '$filename.jpg',
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);

    try {
      final streamedResponse = await _client.send(request).timeout(
            const Duration(seconds: 180),
          );
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(responseBody);
        return CropQualityResponse.fromJson(data);
      } else {
        String errorMsg = 'Server returned error ${streamedResponse.statusCode}';
        try {
          final errJson = jsonDecode(responseBody);
          if (errJson is Map && errJson.containsKey('detail')) {
            errorMsg = errJson['detail'].toString();
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to communicate with crop quality server: $e');
    }
  }

  /// Checks whether Quality model and RAG engine are active.
  Future<Map<String, dynamic>> checkQualityStatus() async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/crop/quality/status');
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'quality_model_available': false, 'rag_engine_available': false};
    } catch (_) {
      return {'quality_model_available': false, 'rag_engine_available': false};
    }
  }

  /// Uploads crop & fruit image bytes for Model 3 detection (Banana Anthracnose,
  /// Mango Anthracnose, Mango Stem End Rot, Potato Blackspot Bruising, Potato Dry Rot)
  /// and RAG agricultural diagnosis.
  Future<CropDiagnosisResponse> diagnoseCropDisease({
    required Uint8List imageBytes,
    required String filename,
    String language = 'en',
    String? cropHint,
  }) async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/crop/disease-detection/diagnose');
    final request = http.MultipartRequest('POST', uri);

    request.fields['language'] = language;
    if (cropHint != null && cropHint.isNotEmpty) {
      request.fields['crop_type'] = cropHint;
    }

    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: filename.endsWith('.jpg') || filename.endsWith('.png')
          ? filename
          : '$filename.jpg',
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);

    try {
      final streamedResponse = await _client.send(request).timeout(
            const Duration(seconds: 180),
          );
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(responseBody);
        return CropDiagnosisResponse.fromJson(data);
      } else {
        String errorMsg = 'Server returned error ${streamedResponse.statusCode}';
        try {
          final errJson = jsonDecode(responseBody);
          if (errJson is Map && errJson.containsKey('detail')) {
            errorMsg = errJson['detail'].toString();
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to communicate with crop disease server: $e');
    }
  }

  /// Checks whether Crop Disease Model 3 and RAG engine are active.
  Future<Map<String, dynamic>> checkDiseaseDetectionStatus() async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/crop/disease-detection/status');
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'disease_model_available': false, 'rag_engine_available': false};
    } catch (_) {
      return {'disease_model_available': false, 'rag_engine_available': false};
    }
  }
}
