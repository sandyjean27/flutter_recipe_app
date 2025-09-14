import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/media_service.dart';
import '../services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditRecipePage extends StatefulWidget {
  final Recipe recipe;
  final RecipeService recipeService;
  final AuthService authService;

  const EditRecipePage({
    Key? key,
    required this.recipe,
    required this.recipeService,
    required this.authService,
  }) : super(key: key);

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _mediaService = MediaService();
  VideoPlayerController? _videoController;
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _ingredientsController;
  late TextEditingController _instructionsController;
  late TextEditingController _preparationTimeController;
  late TextEditingController _cookingTimeController;
  late TextEditingController _servingsController;
  
  String? _imagePath;
  String? _videoUrl;
  List<String> _selectedCategories = [];
  List<String> _ingredients = [];
  bool _isLoading = false;

  final List<String> _availableCategories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
    'Vegetarian',
    'Vegan',
    'Gluten-free',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.recipe.title);
    _descriptionController = TextEditingController(text: widget.recipe.description);
    _instructionsController = TextEditingController(
      text: widget.recipe.instructions.join('\n'),
    );
    _preparationTimeController = TextEditingController(
      text: widget.recipe.preparationTime.toString(),
    );
    _cookingTimeController = TextEditingController(
      text: widget.recipe.cookingTime.toString(),
    );
    _servingsController = TextEditingController(
      text: widget.recipe.servings.toString(),
    );
    _ingredientsController = TextEditingController();
    _ingredients = List.from(widget.recipe.ingredients);
    _selectedCategories = List.from(widget.recipe.categories);
    _imagePath = widget.recipe.imagePath;
    _videoUrl = widget.recipe.videoUrl;

    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    if (_videoUrl != null) {
      _videoController = VideoPlayerController.file(File(_videoUrl!))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRecipe,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty == true ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) => value?.isEmpty == true
                          ? 'Please enter a description'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildIngredientsSection(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _instructionsController,
                      decoration: const InputDecoration(
                        labelText: 'Instructions (one per line)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) => value?.isEmpty == true
                          ? 'Please enter instructions'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _preparationTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Prep Time (min)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => value?.isEmpty == true
                                ? 'Please enter prep time'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cookingTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Cook Time (min)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => value?.isEmpty == true
                                ? 'Please enter cook time'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _servingsController,
                      decoration: const InputDecoration(
                        labelText: 'Servings',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty == true ? 'Please enter servings' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoriesSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      _showError('Please add at least one ingredient');
      return;
    }
    if (_selectedCategories.isEmpty) {
      _showError('Please select at least one category');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedRecipe = Recipe(
        id: widget.recipe.id,
        title: _titleController.text,
        description: _descriptionController.text,
        ingredients: _ingredients,
        instructions: _instructionsController.text
            .split('\n')
            .where((line) => line.isNotEmpty)
            .toList(),
        categories: _selectedCategories,
        preparationTime: int.parse(_preparationTimeController.text),
        cookingTime: int.parse(_cookingTimeController.text),
        servings: int.parse(_servingsController.text),
        creatorId: widget.recipe.creatorId,
        createdAt: widget.recipe.createdAt,
        imagePath: _imagePath,
        videoUrl: _videoUrl,
      );

      await widget.recipeService.updateRecipe(updatedRecipe);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Error updating recipe: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _preparationTimeController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recipe Image'),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(
                            _imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.error_outline, size: 48),
                              );
                            },
                          )
                        : Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.error_outline, size: 48),
                              );
                            },
                          ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 48),
                        SizedBox(height: 8),
                        Text('Tap to add image'),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _ingredientsController,
          decoration: InputDecoration(
            labelText: 'Add Ingredient',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addIngredient,
            ),
          ),
          onFieldSubmitted: (_) => _addIngredient(),
        ),
        if (_ingredients.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _ingredients
                .map(
                  (ingredient) => Chip(
                    label: Text(ingredient),
                    onDeleted: () => _removeIngredient(ingredient),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Categories',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _availableCategories
              .map(
                (category) => FilterChip(
                  label: Text(category),
                  selected: _selectedCategories.contains(category),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _addIngredient() {
    final ingredient = _ingredientsController.text.trim();
    if (ingredient.isNotEmpty) {
      setState(() {
        _ingredients.add(ingredient);
        _ingredientsController.clear();
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() => _imagePath = pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }
} 