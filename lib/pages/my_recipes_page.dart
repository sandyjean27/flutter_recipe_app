import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_page.dart';
import 'add_recipe_page.dart';
import 'edit_recipe_page.dart';

class MyRecipesPage extends StatefulWidget {
  final RecipeService recipeService;
  final AuthService authService;
  final FavoritesService favoritesService;

  const MyRecipesPage({
    Key? key,
    required this.recipeService,
    required this.authService,
    required this.favoritesService,
  }) : super(key: key);

  @override
  State<MyRecipesPage> createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {
  List<Recipe> _myRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyRecipes();
  }

  Future<void> _loadMyRecipes() async {
    setState(() => _isLoading = true);
    try {
      final userId = widget.authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final allRecipes = await widget.recipeService.getAllRecipes();
      
      setState(() {
        _myRecipes = allRecipes
            .where((recipe) => recipe.creatorId == userId)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recipes: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
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
    ).then((_) => _loadMyRecipes());
  }

  void _addNewRecipe() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecipePage(
          recipeService: widget.recipeService,
          authService: widget.authService,
        ),
      ),
    ).then((_) => _loadMyRecipes());
  }

  Future<bool> _deleteRecipe(Recipe recipe) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.recipeService.deleteRecipe(recipe);
        await _loadMyRecipes();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe deleted successfully')),
          );
        }
        return true; // Successfully deleted
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting recipe: $e')),
          );
        }
        return false; // Failed to delete
      }
    }
    return false; // User cancelled
  }

  void _editRecipe(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecipePage(
          recipe: recipe,
          recipeService: widget.recipeService,
          authService: widget.authService,
        ),
      ),
    ).then((edited) {
      if (edited == true) {
        _loadMyRecipes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyRecipes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myRecipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No recipes yet'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addNewRecipe,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Recipe'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _myRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _myRecipes[index];
                    return Dismissible(
                      key: Key(recipe.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _deleteRecipe(recipe),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _openRecipeDetail(recipe),
                        onLongPress: () => _editRecipe(recipe),
                        child: RecipeCard(
                          recipe: recipe,
                          favoritesService: widget.favoritesService,
                          authService: widget.authService,
                          onTap: () => _openRecipeDetail(recipe),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editRecipe(recipe),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRecipe,
        child: const Icon(Icons.add),
      ),
    );
  }
} 