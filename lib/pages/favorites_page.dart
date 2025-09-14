import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../widgets/recipe_card.dart';
import '../pages/recipe_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  final RecipeService recipeService;
  final AuthService authService;
  final FavoritesService favoritesService;

  const FavoritesPage({
    Key? key,
    required this.recipeService,
    required this.authService,
    required this.favoritesService,
  }) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Recipe> _favoriteRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final userId = widget.authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final favoriteIds = await widget.favoritesService.getFavorites(userId);
      final allRecipes = await widget.recipeService.getAllRecipes();
      
      setState(() {
        _favoriteRecipes = allRecipes
            .where((recipe) => favoriteIds.contains(recipe.id))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading favorites: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromFavorites(Recipe recipe) async {
    try {
      final userId = widget.authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      await widget.favoritesService.removeFromFavorites(userId, recipe.id);
      await _loadFavorites();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe removed from favorites')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing from favorites: $e')),
        );
      }
    }
  }

  void _openRecipeDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(
          recipe: recipe,
          recipeService: widget.recipeService,
          authService: widget.authService,
          favoritesService: widget.favoritesService,
        ),
      ),
    ).then((_) => _loadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteRecipes.isEmpty
              ? const Center(
                  child: Text('No favorite recipes yet'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _favoriteRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _favoriteRecipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      favoritesService: widget.favoritesService,
                      authService: widget.authService,
                      onFavoritePressed: () => _removeFromFavorites(recipe),
                      isFavorite: true,
                      onTap: () => _openRecipeDetail(recipe),
                    );
                  },
                ),
    );
  }
} 