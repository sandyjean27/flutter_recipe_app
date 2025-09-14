import 'dart:io';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String imagePath;

  const DetailScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: 'recipe_image_${imagePath.hashCode}',
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: _buildImage(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
      );
    } else if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
      );
    }
  }

  Widget _buildDefaultImage() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(
          Icons.error_outline,
          size: 50,
          color: Colors.white54,
        ),
      ),
    );
  }
}

class RecipeImage extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;
  final double height;
  final BoxFit fit;
  final String title;

  const RecipeImage({
    Key? key,
    this.imagePath,
    this.imageUrl,
    this.height = 200,
    this.fit = BoxFit.cover,
    required this.title,
  }) : super(key: key);

  String _getDefaultImagePath() {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('pancake')) {
      return 'assets/images/pancake.png';
    } else if (lowerTitle.contains('stir') || lowerTitle.contains('chicken')) {
      return 'assets/images/stir.png';
    } else if (lowerTitle.contains('brownie')) {
      return 'assets/images/brownie.png';
    } else if (lowerTitle.contains('toast') || lowerTitle.contains('bread')) {
      return 'assets/images/toast.png';
    } else if (lowerTitle.contains('spaghetti') || lowerTitle.contains('pasta')) {
      return 'assets/images/spaghetti.png';
    } else if (lowerTitle.contains('salad')) {
      return 'assets/images/salad.png';
    } else if (lowerTitle.contains('shrimp') || lowerTitle.contains('seafood')) {
      return 'assets/images/shrimp.png';
    } else if (lowerTitle.contains('taco')) {
      return 'assets/images/taco.png';
    }
    return 'assets/images/default.png';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullImage(context),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.05), // Reduced opacity for subtle effect
                      ],
                      stops: const [0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath != null && imagePath!.isNotEmpty) {
      if (imagePath!.startsWith('assets/')) {
        return Image.asset(
          imagePath!,
          height: height,
          width: double.infinity,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } else {
        final file = File(imagePath!);
        if (file.existsSync()) {
          return Image.file(
            file,
            height: height,
            width: double.infinity,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        }
      }
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        height: height,
        width: double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      _getDefaultImagePath(),
      height: height,
      width: double.infinity,
      fit: fit,
    );
  }

  void _showFullImage(BuildContext context) {
    String imageToShow = imagePath ?? imageUrl ?? _getDefaultImagePath();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(imagePath: imageToShow),
      ),
    );
  }
}
