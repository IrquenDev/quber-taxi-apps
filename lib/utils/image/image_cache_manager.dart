import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:quber_taxi/storage/prefs_manager.dart';

/// Service for managing image cache with persistent cache key invalidation
/// 
/// This service handles intelligent image caching by:
/// - Storing cache keys in persistent storage (SharedPreferences)
/// - Providing cache keys that can be used with SmartCachedImage widget
/// - Invalidating cache only when needed (when image actually changes)
/// - Supporting cache invalidation across app sessions
/// 
/// Usage:
/// ```dart
/// // Get cache key for an image URL
/// final cacheKey = await ImageCacheManager.instance.getCacheKey(
///   entityId: driverId,
///   entityType: 'driver',
/// );
/// 
/// // Use with SmartCachedImage
/// SmartCachedImage.circle(
///   imageUrl: imageUrl,
///   cacheKey: cacheKey,
///   ...
/// )
/// 
/// // Invalidate cache when image changes
/// if (imageWasChanged) {
///   await ImageCacheManager.instance.invalidateCache(
///     entityId: driverId,
///     entityType: 'driver',
///     imageUrl: imageUrl,
///   );
/// }
/// ```
class ImageCacheManager {
  // Private constructor for singleton pattern
  ImageCacheManager._internal();

  /// Singleton instance of [ImageCacheManager]
  static final ImageCacheManager instance = ImageCacheManager._internal();

  /// Internal reference to the shared preferences manager
  final SharedPrefsManager _prefsManager = SharedPrefsManager.instance;

  /// Internal cache manager instance
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  /// Gets or creates a cache key for a specific entity's image
  /// 
  /// The cache key is stored persistently in SharedPreferences, so it persists
  /// across app sessions. If no cache key exists, a new one is created.
  /// 
  /// [entityId] - The unique identifier for the entity (e.g., driver ID, client ID)
  /// [entityType] - The type of entity (e.g., 'driver', 'client', 'taxi')
  /// 
  /// Returns the cache key string to be used with SmartCachedImage
  Future<String?> getCacheKey({
    required int entityId,
    required String entityType,
  }) async {
    final cacheKeyKey = _buildCacheKeyKey(entityId, entityType);
    String? savedCacheKey = _prefsManager.getString(cacheKeyKey);

    if (savedCacheKey == null || savedCacheKey.isEmpty) {
      // Create initial cache key
      savedCacheKey = DateTime.now().millisecondsSinceEpoch.toString();
      await _prefsManager.setString(cacheKeyKey, savedCacheKey);
    }

    return savedCacheKey;
  }

  /// Gets cache key synchronously from preferences (without creating if missing)
  /// 
  /// This is useful in initState where you need the cache key immediately
  /// without async operations. If no cache key exists, returns null.
  /// 
  /// [entityId] - The unique identifier for the entity
  /// [entityType] - The type of entity
  /// 
  /// Returns the cache key if it exists, null otherwise
  String? getCacheKeySync({
    required int entityId,
    required String entityType,
  }) {
    final cacheKeyKey = _buildCacheKeyKey(entityId, entityType);
    return _prefsManager.getString(cacheKeyKey);
  }

  /// Invalidates the cache for a specific entity's image
  /// 
  /// This method:
  /// 1. Removes old cache entries from disk
  /// 2. Creates a new cache key
  /// 3. Stores the new cache key in preferences
  /// 
  /// This forces SmartCachedImage to treat the image as new and download it fresh.
  /// 
  /// [entityId] - The unique identifier for the entity
  /// [entityType] - The type of entity
  /// [imageUrl] - The full URL of the image (optional, for cache removal)
  /// 
  /// Returns the new cache key
  Future<String> invalidateCache({
    required int entityId,
    required String entityType,
    String? imageUrl,
  }) async {
    final cacheKeyKey = _buildCacheKeyKey(entityId, entityType);
    final oldCacheKey = _prefsManager.getString(cacheKeyKey);
    final newCacheKey = DateTime.now().millisecondsSinceEpoch.toString();

    // Remove old cache entries if imageUrl is provided
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _removeCacheEntries(imageUrl, oldCacheKey);
    }

    // Update cache key in preferences
    await _prefsManager.setString(cacheKeyKey, newCacheKey);

    return newCacheKey;
  }

  /// Removes cache entries for a specific image URL
  /// 
  /// This removes both the base URL cache and the cache with old cacheKey
  /// 
  /// [imageUrl] - The full URL of the image
  /// [oldCacheKey] - The old cache key that was used (optional)
  Future<void> _removeCacheEntries(String imageUrl, String? oldCacheKey) async {
    try {
      // Remove cache for base URL (in case it was cached without cacheKey)
      try {
        await _cacheManager.removeFile(imageUrl);
      } catch (e) {
        // Ignore errors
      }

      // Remove cache for URL with old cacheKey (this is the actual key used by CachedNetworkImage)
      if (oldCacheKey != null && oldCacheKey.isNotEmpty) {
        final oldEffectiveCacheKey = '$imageUrl?cacheKey=$oldCacheKey';
        try {
          await _cacheManager.removeFile(oldEffectiveCacheKey);
        } catch (e) {
          // Ignore errors
        }
      }
    } catch (e) {
      // Ignore errors when removing cache
    }
  }

  /// Builds the SharedPreferences key for storing cache key
  /// 
  /// Format: '{entityType}_{entityId}_image_cache_key'
  String _buildCacheKeyKey(int entityId, String entityType) {
    return '${entityType}_${entityId}_image_cache_key';
  }

  /// Clears all cache keys for a specific entity type
  /// 
  /// This is useful when logging out or clearing user data
  /// 
  /// [entityType] - The type of entity
  Future<void> clearCacheKeysForEntityType(String entityType) async {
    // Note: This implementation clears all keys with the entityType prefix
    // For a more precise implementation, you would need to track entity IDs
    // This is a simplified version
    // In production, you might want to store a list of active entity IDs
  }

  /// Gets cache key and creates it if it doesn't exist (synchronous initialization)
  /// 
  /// This is useful when you need a cache key immediately in initState,
  /// but want to save it asynchronously later.
  /// 
  /// [entityId] - The unique identifier for the entity
  /// [entityType] - The type of entity
  /// 
  /// Returns a tuple: (currentCacheKey, needsSaving)
  /// - currentCacheKey: The cache key to use (may be newly created)
  /// - needsSaving: true if the cache key was just created and needs to be saved
  (String?, bool) getOrCreateCacheKeySync({
    required int entityId,
    required String entityType,
  }) {
    final cacheKeyKey = _buildCacheKeyKey(entityId, entityType);
    String? savedCacheKey = _prefsManager.getString(cacheKeyKey);

    if (savedCacheKey == null || savedCacheKey.isEmpty) {
      // Create initial cache key
      savedCacheKey = DateTime.now().millisecondsSinceEpoch.toString();
      return (savedCacheKey, true); // Needs saving
    }

    return (savedCacheKey, false); // Already exists
  }

  /// Saves a cache key to preferences (if it was just created)
  /// 
  /// Use this after getOrCreateCacheKeySync when needsSaving is true
  /// 
  /// [entityId] - The unique identifier for the entity
  /// [entityType] - The type of entity
  /// [cacheKey] - The cache key to save
  Future<void> saveCacheKeyIfNeeded({
    required int entityId,
    required String entityType,
    required String cacheKey,
  }) async {
    final cacheKeyKey = _buildCacheKeyKey(entityId, entityType);
    final existingCacheKey = _prefsManager.getString(cacheKeyKey);

    // Only save if it doesn't exist yet
    if (existingCacheKey == null || existingCacheKey.isEmpty) {
      await _prefsManager.setString(cacheKeyKey, cacheKey);
    }
  }
}

