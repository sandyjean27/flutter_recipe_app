export 'recipe_service.dart';

import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';
import 'image_storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class RecipeService {
  static const String _boxName = 'recipes';
  static const String _metaBoxName = 'recipe_meta';
  static const int _schemaVersion = 1;
  late Box<Recipe> _recipeBox;
  late Box<dynamic> _metaBox;
  final _imageStorage = ImageStorageService();

  Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RecipeAdapter());
    }

    try {
      _metaBox = await Hive.openBox(_metaBoxName);
      _recipeBox = await Hive.openBox<Recipe>(_boxName);
      
      // Check if we need to clear the box due to schema changes
      final version = _metaBox.get('schema_version', defaultValue: 0);
      if (version != _schemaVersion) {
        await _recipeBox.clear();
        await _metaBox.put('schema_version', _schemaVersion);
      }

      if (_recipeBox.isEmpty) {
        await _populateSampleRecipes();
      }
    } catch (e) {
      // If there's an error reading the box, clear it and start fresh
      await _recipeBox.clear();
      await _metaBox.put('schema_version', _schemaVersion);
      await _populateSampleRecipes();
    }
  }

  Future<void> _populateSampleRecipes() async {
    final List<Recipe> sampleRecipes = _generateSampleRecipes();
    final existingRecipes = _recipeBox.values.toList();
    
    for (final recipe in sampleRecipes) {
      // Check if a recipe with the same title already exists
      if (!existingRecipes.any((r) => r.title == recipe.title)) {
        await _recipeBox.add(recipe);
      }
    }
  }

  List<Recipe> _generateSampleRecipes() {
    final List<Map<String, dynamic>> recipeData = [
      {
        'title': 'Classic Pancakes',
        'description': 'Fluffy and delicious homemade pancakes perfect for a weekend breakfast.',
        'ingredients': [
          '1 1/2 cups all-purpose flour',
          '3 1/2 teaspoons baking powder',
          '1/4 teaspoon salt',
          '1 tablespoon sugar',
          '1 1/4 cups milk',
          '1 egg',
          '3 tablespoons melted butter'
        ],
        'instructions': [
          'Mix dry ingredients in a bowl',
          'Whisk milk, egg, and melted butter in another bowl',
          'Combine wet and dry ingredients until just mixed',
          'Heat a griddle or pan over medium heat',
          'Pour 1/4 cup batter for each pancake',
          'Cook until bubbles form, then flip',
          'Cook other side until golden brown'
        ],
        'categories': ['Breakfast', 'Vegetarian'],
        'prepTime': 10,
        'cookTime': 15,
        'servings': 4,
        'imagePath': 'assets/images/image.png',
      },
      {
  'title': 'Brownie',
  'description': 'Rich and fudgy chocolate brownies with a crackly top.',
  'ingredients': [
    '1/2 cup butter',
    '1 cup sugar',
    '2 eggs',
    '1 teaspoon vanilla extract',
    '1/3 cup cocoa powder',
    '1/2 cup flour',
    '1/4 teaspoon salt',
    '1/4 teaspoon baking powder'
  ],
  'instructions': [
    'Preheat oven to 350°F (175°C) and grease a baking pan.',
    'Melt butter and mix with sugar, eggs, and vanilla extract.',
    'Stir in cocoa powder, flour, salt, and baking powder.',
    'Pour into prepared pan and bake for 20 to 25 minutes.',
    'Allow to cool before cutting into squares.'
  ],
  'categories': ['Dessert', 'Snacks'],
  'prepTime': 10,
  'cookTime': 25,
  'servings': 8,
  'imagePath': 'assets/images/brownie.png',
},

      {
        'title': 'Chicken Stir Fry',
        'description': 'Quick and healthy chicken stir fry with vegetables.',
        'ingredients': [
          'chicken breast',
          'broccoli',
          'carrots',
          'soy sauce',
          'garlic',
          'ginger',
          'rice'
        ],
        'instructions': [
          'Cut chicken into bite-sized pieces',
          'Chop vegetables',
          'Stir fry chicken until cooked',
          'Add vegetables and sauce',
          'Serve over rice'
        ],
        'categories': ['Dinner', 'Lunch'],
        'prepTime': 15,
        'cookTime': 20,
        'servings': 4,
      },
      // Add more unique recipes here...
    ];

    return recipeData.map((data) {
      return Recipe(
        id: const Uuid().v4(),
        title: data['title'],
        description: data['description'],
        ingredients: List<String>.from(data['ingredients']),
        instructions: List<String>.from(data['instructions']),
        categories: List<String>.from(data['categories'] ?? []),
        preparationTime: data['prepTime'],
        cookingTime: data['cookTime'],
        servings: data['servings'],
        creatorId: 'system',
        createdAt: DateTime.now(),
        imagePath: data['imagePath'],
      );
    }).toList();
  }

  // CRUD Operations
  Future<List<Recipe>> getAllRecipes() async {
    return _recipeBox.values.toList();
  }

  Future<Recipe?> getRecipeById(String id) async {
    return _recipeBox.get(id);
  }

  Future<List<Recipe>> getRecipesByCategory(String category) async {
    return _recipeBox.values
        .where((recipe) => recipe.categories.contains(category))
        .toList();
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    query = query.toLowerCase();
    return _recipeBox.values.where((recipe) {
      // Search in title
      if (recipe.title.toLowerCase().contains(query)) {
        return true;
      }
      
      // Search in description
      if (recipe.description.toLowerCase().contains(query)) {
        return true;
      }
      
      // Search in ingredients
      if (recipe.ingredients.any(
        (ingredient) => ingredient.toLowerCase().contains(query)
      )) {
        return true;
      }
      
      // Search in categories
      if (recipe.categories.any(
        (category) => category.toLowerCase().contains(query)
      )) {
        return true;
      }
      
      // Search in instructions
      if (recipe.instructions.any(
        (instruction) => instruction.toLowerCase().contains(query)
      )) {
        return true;
      }
      
      return false;
    }).toList();
  }

  Future<String> _saveImage(String sourcePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}${path.extension(sourcePath)}';
      final destinationPath = path.join(directory.path, 'recipe_images', fileName);

      // Create the recipe_images directory if it doesn't exist
      final imageDir = Directory(path.dirname(destinationPath));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      // Copy the image file to the app's directory
      final File sourceFile = File(sourcePath);
      await sourceFile.copy(destinationPath);

      return destinationPath;
    } catch (e) {
      print('Error saving image: $e');
      rethrow;
    }
  }

  Future<Recipe> addRecipe({
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> instructions,
    required List<String> categories,
    required int preparationTime,
    required int cookingTime,
    required int servings,
    required String creatorId,
    String? imagePath,
    String? videoUrl,
  }) async {
    String? savedImagePath;
    
    if (imagePath != null) {
      if (kIsWeb) {
        savedImagePath = imagePath; // Use the URL directly for web
      } else {
        try {
          savedImagePath = await _saveImage(imagePath);
        } catch (e) {
          throw Exception('Failed to save recipe image: $e');
        }
      }
    }

    final recipe = Recipe(
      id: const Uuid().v4(),
      title: title,
      description: description,
      ingredients: ingredients,
      instructions: instructions,
      categories: categories,
      preparationTime: preparationTime,
      cookingTime: cookingTime,
      servings: servings,
      creatorId: creatorId,
      createdAt: DateTime.now(),
      imagePath: savedImagePath,
      videoUrl: videoUrl,
    );

    try {
      await _recipeBox.add(recipe);
      return recipe;
    } catch (e) {
      if (!kIsWeb && savedImagePath != null) {
        final imageFile = File(savedImagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }
      throw Exception('Failed to save recipe: $e');
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final index = _recipeBox.values
        .toList()
        .indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      await _recipeBox.putAt(index, recipe);
    }
  }

  Future<void> deleteRecipe(Recipe recipe) async {
    try {
      // Delete the image file if it exists
      if (recipe.imagePath != null) {
        final imageFile = File(recipe.imagePath!);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }
      await recipe.delete();
    } catch (e) {
      print('Error deleting recipe: $e');
      rethrow;
    }
  }
} 
Future<List<Recipe>> getAllRecipes() async {
  // Assuming you have a list of recipes stored in Hive or locally.
  final List<Recipe> recipes = await Hive.box<Recipe>('recipes').values.toList();
  return recipes;
}