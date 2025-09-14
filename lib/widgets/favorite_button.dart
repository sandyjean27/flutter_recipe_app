import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../services/auth_service.dart';

class FavoriteButton extends StatefulWidget {
  final String recipeId;
  final FavoritesService favoritesService;
  final AuthService authService;
  final void Function(bool)? onFavoriteChanged;

  const FavoriteButton({
    Key? key,
    required this.recipeId,
    required this.favoritesService,
    required this.authService,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final userId = widget.authService.getCurrentUserId();
      if (userId == null) return;

      final isFavorite = await widget.favoritesService.isFavorite(
        userId,
        widget.recipeId,
      );
      
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final userId = widget.authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      await widget.favoritesService.toggleFavorite(userId, widget.recipeId);
      
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
          widget.onFavoriteChanged?.call(_isFavorite);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating favorite: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? Colors.red : null,
      ),
      onPressed: _toggleFavorite,
    );
  }
} 