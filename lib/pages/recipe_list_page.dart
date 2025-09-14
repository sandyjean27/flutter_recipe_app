import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../widgets/recipe_image.dart';
import 'add_recipe_page.dart';
import 'recipe_suggestion_page.dart';
import 'recipe_detail_page.dart';

class RecipeListPage extends StatefulWidget {
  final RecipeService recipeService;
  final AuthService authService;
  final FavoritesService favoritesService;

  const RecipeListPage({
    super.key,
    required this.recipeService,
    required this.authService,
    required this.favoritesService,
  });

  @override
  State<RecipeListPage> createState() => RecipeListPageState();
}

class RecipeListPageState extends State<RecipeListPage> {
  List<Recipe> _recipes = [];
  Map<String, bool> _favorites = {};
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  bool _isLoading = true;

  // Public method to refresh recipes
  void refreshRecipes() {
    _loadRecipes();
  }

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() => _isLoading = true);
    try {
      final recipes = await widget.recipeService.getAllRecipes();
      final userId = widget.authService.getCurrentUserId();
      
      if (userId != null) {
        // Load favorite status for each recipe
        final Map<String, bool> favorites = {};
        for (final recipe in recipes) {
          favorites[recipe.id] = await widget.favoritesService.isFavorite(userId, recipe.id);
        }
        setState(() {
          _recipes = recipes;
          _favorites = favorites;
          _isLoading = false;
        });
      } else {
        setState(() {
          _recipes = recipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recipes: $e')),
        );
      }
    }
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    try {
      final userId = widget.authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      await widget.favoritesService.toggleFavorite(userId, recipe.id);
      await _loadFavorites();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating favorite: $e')),
        );
      }
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final userId = widget.authService.getCurrentUserId();
      if (userId == null) return;

      final recipes = await widget.recipeService.getAllRecipes();
      final Map<String, bool> favorites = {};

      for (final recipe in recipes) {
        favorites[recipe.id] = await widget.favoritesService.isFavorite(userId, recipe.id);
      }

      if (mounted) {
        setState(() => _favorites = favorites);
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _filterByCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });
    
    try {
      final recipes = category == 'All'
          ? await widget.recipeService.getAllRecipes()
          : await widget.recipeService.getRecipesByCategory(category);
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error filtering recipes: $e')),
        );
      }
    }
  }

  Future<void> _searchRecipes(String query) async {
    setState(() => _isLoading = true);
    try {
      final recipes = query.isEmpty
          ? await widget.recipeService.getAllRecipes()
          : await widget.recipeService.searchRecipes(query);
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching recipes: $e')),
        );
      }
    }
  }

  void _openSearchPage() {
    if (!mounted) return;
    
    RecipeSuggestionPage.navigate(
      context,
      recipeService: widget.recipeService,
      authService: widget.authService,
      favoritesService: widget.favoritesService,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearchPage,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter dialog
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search recipes...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: _searchRecipes,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.kitchen),
                  tooltip: 'Find recipes by ingredients',
                  onPressed: _openSearchPage,
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                _buildCategoryChip('All'),
                _buildCategoryChip('Breakfast'),
                _buildCategoryChip('Lunch'),
                _buildCategoryChip('Dinner'),
                _buildCategoryChip('Dessert'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _recipes.isEmpty
                    ? const Center(
                        child: Text(
                          'No recipes found',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _recipes[index];
                          return _buildRecipeCard(recipe);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecipePage(
                recipeService: widget.recipeService,
                authService: widget.authService,
              ),
            ),
          ).then((_) => _loadRecipes());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(category),
        selected: _selectedCategory == category,
        onSelected: (selected) {
          _filterByCategory(category);
        },
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    final isFavorite = _favorites[recipe.id] ?? false;
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
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
          ).then((_) => _loadRecipes());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'recipe_image_${recipe.id}',
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: RecipeImage(
                  imagePath: recipe.imagePath,
                  title: recipe.title,
                  height: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () => _toggleFavorite(recipe),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.preparationTime + recipe.cookingTime} min',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.servings} servings',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: recipe.categories.map((category) {
                      return Chip(
                        label: Text(category),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 