import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteLocation {
  final String name;
  final double longitude;
  final double latitude;

  FavoriteLocation({
    required this.name,
    required this.longitude,
    required this.latitude,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'longitude': longitude,
    'latitude': latitude,
  };

  factory FavoriteLocation.fromJson(Map<String, dynamic> json) {
    return FavoriteLocation(
      name: json['name'],
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }
}

class FavoritesPrefsManager {
  static const _favoritesKey = 'favorite_locations';

  static Future<List<FavoriteLocation>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);
    if (jsonString == null) return [];
    final List decoded = json.decode(jsonString);
    return decoded.map((e) => FavoriteLocation.fromJson(e)).toList();
  }

  static Future<void> saveFavorite(FavoriteLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.add(location);
    final jsonString = json.encode(favorites.map((e) => e.toJson()).toList());
    await prefs.setString(_favoritesKey, jsonString);
  }

  static Future<void> removeFavorite(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeAt(index);
    final jsonString = json.encode(favorites.map((e) => e.toJson()).toList());
    await prefs.setString(_favoritesKey, jsonString);
  }
}
