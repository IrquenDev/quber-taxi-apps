import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Service for caching profile images locally
/// Only downloads images if the URL has changed
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();

  factory ImageCacheService() => _instance;

  ImageCacheService._internal();

  static const String _cacheFolder = 'image_cache';
  static const String _metadataFile = 'cache_metadata.json';

  /// Gets cached image file if URL hasn't changed, otherwise downloads and caches new image
  Future<File?> getCachedImage(String imageUrl) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final urlHash = _generateUrlHash(imageUrl);
      final imageFile = File(path.join(cacheDir.path, '$urlHash.jpg'));
      final metadataFile = File(path.join(cacheDir.path, _metadataFile));

      // Load existing metadata
      Map<String, dynamic> metadata = {};
      if (await metadataFile.exists()) {
        final metadataContent = await metadataFile.readAsString();
        metadata = jsonDecode(metadataContent);
      }

      // Check if image exists and URL hasn't changed
      if (await imageFile.exists() && metadata[urlHash] == imageUrl) {
        return imageFile;
      }

      // Download new image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        await imageFile.writeAsBytes(response.bodyBytes);

        // Update metadata
        metadata[urlHash] = imageUrl;
        await metadataFile.writeAsString(jsonEncode(metadata));

        return imageFile;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching image: $e');
      }
    }

    return null;
  }

  /// Clears all cached images
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing image cache: $e');
      }
    }
  }

  /// Removes specific image from cache
  Future<void> removeFromCache(String imageUrl) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final urlHash = _generateUrlHash(imageUrl);
      final imageFile = File(path.join(cacheDir.path, '$urlHash.jpg'));
      final metadataFile = File(path.join(cacheDir.path, _metadataFile));

      // Remove image file
      if (await imageFile.exists()) {
        await imageFile.delete();
      }

      // Update metadata
      if (await metadataFile.exists()) {
        final metadataContent = await metadataFile.readAsString();
        final metadata = Map<String, dynamic>.from(jsonDecode(metadataContent));
        metadata.remove(urlHash);
        await metadataFile.writeAsString(jsonEncode(metadata));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing image from cache: $e');
      }
    }
  }

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(path.join(appDir.path, _cacheFolder));

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  String _generateUrlHash(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
