import 'package:flutter/material.dart';
import 'dart:io';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_page.dart';
import '../services/recipe_suggestion_service.dart';

class RecipeSuggestionPage extends StatefulWidget {
  final RecipeService recipeService;
  final AuthService authService;
  final FavoritesService favoritesService;

  const RecipeSuggestionPage({
    super.key,
    required this.recipeService,
    required this.authService,
    required this.favoritesService,
  });

  static void navigate(
    BuildContext context, {
    required RecipeService recipeService,
    required AuthService authService,
    required FavoritesService favoritesService,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeSuggestionPage(
          recipeService: recipeService,
          authService: authService,
          favoritesService: favoritesService,
        ),
      ),
    );
  }

  @override
  State<RecipeSuggestionPage> createState() => _RecipeSuggestionPageState();
}

class _RecipeSuggestionPageState extends State<RecipeSuggestionPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _selectedIngredients = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _addIngredient() {
    final ingredient = _searchController.text.trim();
    if (ingredient.isNotEmpty) {
      setState(() {
        _selectedIngredients.add(ingredient);
        _searchController.clear();
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _selectedIngredients.remove(ingredient);
    });
  }

  double _calculateMatchPercentage(Recipe recipe) {
    if (recipe.ingredients.isEmpty) return 0.0;
    
    int matchCount = recipe.ingredients
        .where((ingredient) => _selectedIngredients
            .any((selected) => selected.toLowerCase() == ingredient.toLowerCase()))
        .length;
    
    return (matchCount / recipe.ingredients.length) * 100;
  }

  Future<void> _searchRecipes() async {
  if (_selectedIngredients.isEmpty) {
    setState(() => _searchResults = []);
    return;
  }

  setState(() => _isLoading = true);
  try {
    // Fetch all recipes from your RecipeService
    final allRecipes = await widget.recipeService.getAllRecipes(); 
    
    // Use the RecipeSuggestionService to filter recipes
    final recipeSuggestionService = RecipeSuggestionService();
    final filteredRecipes = recipeSuggestionService.suggestRecipes(
      _selectedIngredients,
      allRecipes,
    );

    if (mounted) {
      setState(() {
        _searchResults = filteredRecipes.map((recipe) {
          final percentage = _calculateMatchPercentage(recipe);
          return {'recipe': recipe, 'percentage': percentage};
        }).toList();
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching recipes: $e')),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Add ingredients...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                ),
                onSubmitted: (_) => _addIngredient(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addIngredient,
              tooltip: 'Add ingredient',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Selected ingredients chips
          if (_selectedIngredients.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Ingredients:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _selectedIngredients
                        .map((ingredient) => Chip(
                              label: Text(ingredient),
                              onDeleted: () => _removeIngredient(ingredient),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          // Search button
          if (_selectedIngredients.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _searchRecipes,
                child: const Text('Search Recipes'),
              ),
            ),
          // Popular ingredients suggestions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Popular Ingredients:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildQuickSearchChip('Egg'),
                    _buildQuickSearchChip('Chicken'),
                    _buildQuickSearchChip('Rice'),
                    _buildQuickSearchChip('Pasta'),
                    _buildQuickSearchChip('Tomato'),
                  ],
                ),
              ],
            ),
          ),
          // Search results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _selectedIngredients.isEmpty
                              ? 'Add ingredients to search recipes'
                              : 'No recipes found with selected ingredients',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          final recipe = result['recipe'] as Recipe;
                          final percentage = result['percentage'] as double;
                          
                          return RecipeCard(
                            recipe: recipe,
                            favoritesService: widget.favoritesService,
                            authService: widget.authService,
                            onTap: () => _openRecipeDetail(recipe),
                            matchPercentage: percentage,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchChip(String ingredient) {
    return ActionChip(
      label: Text(ingredient),
      onPressed: () {
        setState(() {
          if (!_selectedIngredients.contains(ingredient)) {
            _selectedIngredients.add(ingredient);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 