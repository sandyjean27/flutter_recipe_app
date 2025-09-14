export 'favorites_service.dart';

import 'package:hive_flutter/hive_flutter.dart';

class FavoritesService {
  static const String _boxName = 'favorites';
  late Box<List<dynamic>> _favoritesBox;

  Future<void> init() async {
    _favoritesBox = await Hive.openBox<List<dynamic>>(_boxName);
  }

  Future<List<String>> getFavorites(String userId) async {
    final favorites = _favoritesBox.get(userId, defaultValue: <String>[]);
    return List<String>.from(favorites ?? []);
  }

  Future<bool> isFavorite(String userId, String recipeId) async {
    final favorites = await getFavorites(userId);
    return favorites.contains(recipeId);
  }

  Future<void> addToFavorites(String userId, String recipeId) async {
    final favorites = await getFavorites(userId);
    if (!favorites.contains(recipeId)) {
      favorites.add(recipeId);
      await _favoritesBox.put(userId, favorites);
    }
  }

  Future<void> removeFromFavorites(String userId, String recipeId) async {
    final favorites = await getFavorites(userId);
    favorites.remove(recipeId);
    await _favoritesBox.put(userId, favorites);
  }

  Future<void> toggleFavorite(String userId, String recipeId) async {
    final isFav = await isFavorite(userId, recipeId);
    if (isFav) {
      await removeFromFavorites(userId, recipeId);
    } else {
      await addToFavorites(userId, recipeId);
    }
  }

  Future<void> clearFavorites(String userId) async {
    await _favoritesBox.put(userId, <String>[]);
  }
} 