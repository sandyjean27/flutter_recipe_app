import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/recipe_service.dart';
import '../services/favorites_service.dart';
import 'favorites_page.dart';
import 'login_page.dart';
import 'my_recipes_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  final AuthService authService;
  final RecipeService recipeService;
  final FavoritesService favoritesService;

  const ProfilePage({
    Key? key,
    required this.authService,
    required this.recipeService,
    required this.favoritesService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = authService.getCurrentUserId();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        children: [
          // Profile Header
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 20),
          Text(
            userId ?? 'Guest User',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 30),

          // Menu Items
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('My Favorites'),
            onTap: () => _openFavorites(context),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('My Recipes'),
            onTap: () => _openMyRecipes(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => _openSettings(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  void _openFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesPage(
          recipeService: recipeService,
          authService: authService,
          favoritesService: favoritesService,
        ),
      ),
    );
  }

  void _openMyRecipes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyRecipesPage(
          recipeService: recipeService,
          authService: authService,
          favoritesService: favoritesService,
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          authService: authService,
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await authService.signOut();
      // Navigate to login page
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginPage(
              authService: authService,
              recipeService: recipeService,
              favoritesService: favoritesService,
            ),
          ),
          (route) => false,
        );
      }
    }
  }
} 