import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/crop_disease/models/crop_disease_models.dart';

/// Saved AI Diagnosis Report record for offline review & PDF generation.
class SavedAiReport {
  final int id;
  final String crop;
  final String detectedCondition;
  final double confidence;
  final bool isHealthy;
  final String imagePath;
  final String overview;
  final List<String> symptoms;
  final List<String> organicManagement;
  final List<String> chemicalManagement;
  final List<String> prevention;
  final String language;
  final DateTime createdAt;

  const SavedAiReport({
    required this.id,
    required this.crop,
    required this.detectedCondition,
    required this.confidence,
    required this.isHealthy,
    required this.imagePath,
    required this.overview,
    required this.symptoms,
    required this.organicManagement,
    required this.chemicalManagement,
    required this.prevention,
    required this.language,
    required this.createdAt,
  });

  factory SavedAiReport.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      try {
        final decoded = jsonDecode(val.toString());
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return [];
    }

    return SavedAiReport(
      id: map['id'] as int? ?? 0,
      crop: map['crop']?.toString() ?? '',
      detectedCondition: map['detected_condition']?.toString() ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      isHealthy: (map['is_healthy'] as int? ?? 0) == 1,
      imagePath: map['image_path']?.toString() ?? '',
      overview: map['overview']?.toString() ?? '',
      symptoms: parseList(map['symptoms']),
      organicManagement: parseList(map['organic_management']),
      chemicalManagement: parseList(map['chemical_management']),
      prevention: parseList(map['prevention']),
      language: map['language']?.toString() ?? 'en',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Saved AI Conversation item (Chat or Voice Assistant Q&A)
class SavedConversation {
  final int id;
  final String type; // 'chat' or 'voice'
  final String query;
  final String response;
  final String crop;
  final String language;
  final DateTime createdAt;

  const SavedConversation({
    required this.id,
    required this.type,
    required this.query,
    required this.response,
    required this.crop,
    required this.language,
    required this.createdAt,
  });

  factory SavedConversation.fromMap(Map<String, dynamic> map) {
    return SavedConversation(
      id: map['id'] as int? ?? 0,
      type: map['type']?.toString() ?? 'chat',
      query: map['query']?.toString() ?? '',
      response: map['response']?.toString() ?? '',
      crop: map['crop']?.toString() ?? '',
      language: map['language']?.toString() ?? 'en',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Production SQLite local database service.
/// Persists AI reports and AI conversations for offline access.
class LocalDbService {
  static final LocalDbService instance = LocalDbService._internal();
  LocalDbService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'chip_to_crop_local.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ai_reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            crop TEXT NOT NULL,
            detected_condition TEXT NOT NULL,
            confidence REAL NOT NULL,
            is_healthy INTEGER NOT NULL,
            image_path TEXT NOT NULL,
            overview TEXT,
            symptoms TEXT,
            organic_management TEXT,
            chemical_management TEXT,
            prevention TEXT,
            language TEXT,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE ai_conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            query TEXT NOT NULL,
            response TEXT NOT NULL,
            crop TEXT,
            language TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // --- AI REPORTS ---

  /// Save diagnosis report and its image file locally
  Future<int> saveReport({
    required CropDiagnosisResponse diagnosis,
    required Uint8List imageBytes,
    required String language,
  }) async {
    try {
      final db = await database;
      final docsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(docsDir.path, 'report_images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageFile = File(p.join(imagesDir.path, fileName));
      await imageFile.writeAsBytes(imageBytes);

      final row = {
        'crop': diagnosis.crop,
        'detected_condition': diagnosis.detectedCondition,
        'confidence': diagnosis.confidence,
        'is_healthy': diagnosis.isHealthy ? 1 : 0,
        'image_path': imageFile.path,
        'overview': diagnosis.diagnosis.overview,
        'symptoms': jsonEncode(diagnosis.diagnosis.symptoms),
        'organic_management': jsonEncode(diagnosis.diagnosis.organicManagement),
        'chemical_management': jsonEncode(diagnosis.diagnosis.chemicalManagement),
        'prevention': jsonEncode(diagnosis.diagnosis.prevention),
        'language': language,
        'created_at': DateTime.now().toIso8601String(),
      };

      final id = await db.insert('ai_reports', row);
      debugPrint('Saved AI report #$id to SQLite local database.');
      return id;
    } catch (e) {
      debugPrint('Failed to save AI report to SQLite: $e');
      return -1;
    }
  }

  /// Automatically persists an AI Produce Quality Report to SQLite.
  Future<int> saveQualityReport({
    required CropQualityResponse qualityResponse,
    required Uint8List imageBytes,
    String language = 'en',
  }) async {
    try {
      final db = await database;
      final docsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(docsDir.path, 'report_images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = 'quality_report_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageFile = File(p.join(imagesDir.path, fileName));
      await imageFile.writeAsBytes(imageBytes);

      final row = {
        'crop': qualityResponse.crop,
        'detected_condition': '${qualityResponse.qualityStatus} (${qualityResponse.gradeLabel})',
        'confidence': qualityResponse.confidence,
        'is_healthy': qualityResponse.isFresh ? 1 : 0,
        'image_path': imageFile.path,
        'overview': qualityResponse.qualityReport.overview,
        'symptoms': jsonEncode(qualityResponse.qualityReport.storageGuidelines),
        'organic_management': jsonEncode(qualityResponse.qualityReport.packagingAndHandling),
        'chemical_management': jsonEncode(qualityResponse.qualityReport.segregationAndSanitation),
        'prevention': jsonEncode(qualityResponse.qualityReport.preventionOfSpoilage),
        'language': language,
        'created_at': DateTime.now().toIso8601String(),
      };

      final id = await db.insert('ai_reports', row);
      debugPrint('Saved AI quality report #$id to SQLite local database.');
      return id;
    } catch (e) {
      debugPrint('Failed to save AI quality report to SQLite: $e');
      return -1;
    }
  }

  /// Get all saved AI reports (latest first)
  Future<List<SavedAiReport>> getAllReports() async {
    try {
      final db = await database;
      final list = await db.query('ai_reports', orderBy: 'id DESC');
      return list.map((m) => SavedAiReport.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Failed to query AI reports: $e');
      return [];
    }
  }

  /// Delete a single AI report
  Future<void> deleteReport(int id) async {
    try {
      final db = await database;
      // Get image path first
      final rows = await db.query('ai_reports', where: 'id = ?', whereArgs: [id], limit: 1);
      if (rows.isNotEmpty) {
        final path = rows.first['image_path']?.toString();
        if (path != null) {
          final f = File(path);
          if (await f.exists()) await f.delete();
        }
      }
      await db.delete('ai_reports', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Failed to delete AI report $id: $e');
    }
  }

  /// Clear all AI reports
  Future<void> clearAllReports() async {
    try {
      final db = await database;
      await db.delete('ai_reports');
    } catch (e) {
      debugPrint('Failed to clear all reports: $e');
    }
  }

  // --- AI CONVERSATIONS ---

  /// Save a conversation Q&A item
  Future<int> saveConversation({
    required String type, // 'chat' or 'voice'
    required String query,
    required String response,
    String? crop,
    required String language,
  }) async {
    try {
      final db = await database;
      final row = {
        'type': type,
        'query': query,
        'response': response,
        'crop': crop ?? '',
        'language': language,
        'created_at': DateTime.now().toIso8601String(),
      };
      final id = await db.insert('ai_conversations', row);
      debugPrint('Saved $type conversation #$id to SQLite.');
      return id;
    } catch (e) {
      debugPrint('Failed to save conversation to SQLite: $e');
      return -1;
    }
  }

  /// Get all saved conversations (latest first)
  Future<List<SavedConversation>> getAllConversations({String? filterType}) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> list;
      if (filterType != null && filterType.isNotEmpty) {
        list = await db.query(
          'ai_conversations',
          where: 'type = ?',
          whereArgs: [filterType],
          orderBy: 'id DESC',
        );
      } else {
        list = await db.query('ai_conversations', orderBy: 'id DESC');
      }
      return list.map((m) => SavedConversation.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Failed to query conversations: $e');
      return [];
    }
  }

  /// Delete a single conversation
  Future<void> deleteConversation(int id) async {
    try {
      final db = await database;
      await db.delete('ai_conversations', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Failed to delete conversation $id: $e');
    }
  }

  /// Clear all conversations
  Future<void> clearAllConversations() async {
    try {
      final db = await database;
      await db.delete('ai_conversations');
    } catch (e) {
      debugPrint('Failed to clear conversations: $e');
    }
  }
}

