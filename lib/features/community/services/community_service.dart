import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/community_post.dart';

class CommunityService {
  static const String _baseUrl = 'http://127.0.0.1:8000/community';

  static final CommunityService instance = CommunityService._internal();
  factory CommunityService() => instance;
  CommunityService._internal();

  /// Fetch community posts with optional crop filter
  Future<List<CommunityPost>> getPosts({String? cropType}) async {
    try {
      String url = '$_baseUrl/posts';
      if (cropType != null && cropType.isNotEmpty && cropType != 'All') {
        url += '?crop_type=${Uri.encodeComponent(cropType)}';
      }

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final postsList = (data['posts'] as List?) ?? [];
        return postsList
            .map((p) => CommunityPost.fromJson(p as Map<String, dynamic>))
            .where((p) => !p.id.startsWith('post-seed'))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching community posts: $e');
      return [];
    }
  }

  /// Create a new farmer community post with image upload to Supabase Storage
  Future<CommunityPost?> createPost({
    required String title,
    required String description,
    required String cropType,
    String? imagePath,
    Uint8List? imageBytes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final farmerName = prefs.getString('farmer_name') ?? 'Farmer';
      final farmerPhone = prefs.getString('farmer_phone') ?? '';

      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/posts'));
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['crop_type'] = cropType;
      request.fields['farmer_name'] = farmerName;
      request.fields['farmer_phone'] = farmerPhone;

      if (imageBytes != null && imageBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'post_upload.jpg',
          ),
        );
      } else if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('image', imagePath),
          );
        }
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final postJson = data['post'] as Map<String, dynamic>?;
        if (postJson != null) {
          return CommunityPost.fromJson(postJson);
        }
      } else {
        debugPrint('Create post failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error creating community post: $e');
    }
    return null;
  }

  /// Like a post
  Future<int> likePost(String postId) async {
    try {
      final response = await http
          .post(Uri.parse('$_baseUrl/posts/$postId/like'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['likes_count'] as num?)?.toInt() ?? 1;
      }
    } catch (e) {
      debugPrint('Error liking post $postId: $e');
    }
    return 1;
  }
}

