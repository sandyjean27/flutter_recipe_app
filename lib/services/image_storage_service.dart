import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class ImageStorageService {
  static final ImageStorageService _instance = ImageStorageService._internal();
  factory ImageStorageService() => _instance;
  ImageStorageService._internal();

  Future<String> saveImage(File imageFile) async {
    try {
      if (kIsWeb) {
        // For web, return the file path directly as we can't save files
        return imageFile.path;
      }

      // Get the application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesPath = join(appDir.path, 'recipe_images');
      
      // Create the directory if it doesn't exist
      final Directory imagesDir = Directory(imagesPath);
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate unique filename
      final String fileName = '${const Uuid().v4()}.png';
      final String filePath = join(imagesPath, fileName);

      // Copy the file to app's directory
      await imageFile.copy(filePath);
      
      return filePath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      throw Exception('Failed to save image: $e');
    }
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      if (kIsWeb) return; // Skip deletion on web platform
      
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
      throw Exception('Failed to delete image: $e');
    }
  }
} 