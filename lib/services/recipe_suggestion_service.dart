import '../models/recipe.dart';

class RecipeSuggestionService {
  List<Recipe> suggestRecipes(List<String> availableIngredients, List<Recipe> allRecipes) {
    // Normalize available ingredients by converting to lowercase and trimming
    final normalizedAvailable = availableIngredients
        .map((i) => i.toLowerCase().trim())
        .toSet();

    // Calculate match scores for each recipe
    final recipesWithScores = allRecipes.map((recipe) {
      final normalizedRecipeIngredients = recipe.ingredients
          .map((i) => i.toLowerCase().trim())
          .toSet();

      // Count matching ingredients
      final matchingIngredients = normalizedRecipeIngredients
          .where((ingredient) => normalizedAvailable.any((available) =>
              ingredient.contains(available) || available.contains(ingredient)))
          .length;

      // Calculate score as percentage of required ingredients that are available
      final score = matchingIngredients / normalizedRecipeIngredients.length;

      return (recipe, score);
    }).toList();

    // Sort recipes by score (highest first)
    recipesWithScores.sort((a, b) => b.$2.compareTo(a.$2));
    
    // Return recipes with at least one matching ingredient
    return recipesWithScores
        .where((item) => item.$2 > 0)
        .map((item) => item.$1)
        .toList();
  }

  Set<String> extractCommonIngredients(List<Recipe> recipes) {
    if (recipes.isEmpty) return {};

    final allIngredients = recipes
        .expand((recipe) => recipe.ingredients)
        .map((ingredient) => ingredient.toLowerCase().trim());

    // Count ingredient occurrences
    final ingredientCounts = <String, int>{};
    for (final ingredient in allIngredients) {
      ingredientCounts[ingredient] = (ingredientCounts[ingredient] ?? 0) + 1;
    }

    // Return ingredients that appear in at least 10% of recipes
    final minOccurrences = (recipes.length * 0.1).ceil();
    return ingredientCounts.entries
        .where((entry) => entry.value >= minOccurrences)
        .map((entry) => entry.key)
        .toSet();
  }

  List<String> suggestMissingIngredients(Recipe recipe, List<String> availableIngredients) {
    final normalizedAvailable = availableIngredients
        .map((i) => i.toLowerCase().trim())
        .toSet();

    return recipe.ingredients
        .where((ingredient) {
          final normalizedIngredient = ingredient.toLowerCase().trim();
          return !normalizedAvailable.any((available) =>
              normalizedIngredient.contains(available) || available.contains(normalizedIngredient));
        })
        .toList();
  }
}
