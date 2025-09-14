import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/favorites_service.dart';
import '../services/auth_service.dart';
import '../widgets/favorite_button.dart';
import '../widgets/recipe_image.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final FavoritesService favoritesService;
  final AuthService authService;
  final VoidCallback? onFavoritePressed;
  final bool isFavorite;
  final VoidCallback? onTap;
  final Widget? trailing;
  final double? matchPercentage;

  const RecipeCard({
    Key? key,
    required this.recipe,
    required this.favoritesService,
    required this.authService,
    this.onFavoritePressed,
    this.isFavorite = false,
    this.onTap,
    this.trailing,
    this.matchPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            Stack(
              children: [
                Hero(
                  tag: 'recipe_image_${recipe.id}',
                  child: RecipeImage(
                    imagePath: recipe.imagePath,
                    imageUrl: recipe.imageUrl,
                    height: 200,
                    title: recipe.title,
                  ),
                ),
                if (matchPercentage != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: matchPercentage! > 70 
                            ? Colors.green 
                            : matchPercentage! > 40 
                                ? Colors.orange 
                                : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${matchPercentage!.toStringAsFixed(1)}% match',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Recipe Details
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trailing != null) trailing!,
                      FavoriteButton(
                        recipeId: recipe.id,
                        favoritesService: favoritesService,
                        authService: authService,
                        onFavoriteChanged: (isFavorite) {
                          onFavoritePressed?.call();
                        },
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 