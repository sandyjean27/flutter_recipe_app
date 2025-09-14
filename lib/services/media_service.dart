import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

class MediaService {
  final ImagePicker _picker = ImagePicker();
  Directory? _appDir;

  Future<void> _ensureInitialized() async {
    if (!kIsWeb && _appDir == null) {
      _appDir = await path_provider.getApplicationDocumentsDirectory();
    }
  }

  Future<String> _getMediaDirectory(String type) async {
    if (kIsWeb) return '';
    
    await _ensureInitialized();
    final String mediaDir = path.join(_appDir!.path, 'recipe_$type');
    final Directory directory = Directory(mediaDir);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return mediaDir;
  }

  Future<String?> pickAndSaveImage({bool fromCamera = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return null;

      if (kIsWeb) {
        // For web, just return the path as is
        return image.path;
      }

      final String mediaDir = await _getMediaDirectory('images');
      
      // Generate unique filename with timestamp and random number
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String random = DateTime.now().microsecond.toString();
      final String fileName = 'image_${timestamp}_$random${path.extension(image.path)}';
      final String savedPath = path.join(mediaDir, fileName);

      // Copy image to app directory
      final File savedFile = await File(image.path).copy(savedPath);
      
      // Verify the file was saved successfully
      if (!await savedFile.exists()) {
        throw Exception('Failed to save image file');
      }

      // Return normalized path
      return path.normalize(savedFile.absolute.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<String?> pickAndSaveVideo({bool fromCamera = false}) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video == null) return null;

      if (kIsWeb) {
        // For web, just return the path as is
        return video.path;
      }

      final String mediaDir = await _getMediaDirectory('videos');
      
      // Generate unique filename with timestamp and random number
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String random = DateTime.now().microsecond.toString();
      final String fileName = 'video_${timestamp}_$random${path.extension(video.path)}';
      final String savedPath = path.join(mediaDir, fileName);

      // Copy video to app directory
      final File savedFile = await File(video.path).copy(savedPath);
      
      // Verify the file was saved successfully
      if (!await savedFile.exists()) {
        throw Exception('Failed to save video file');
      }

      // Return normalized path
      return path.normalize(savedFile.absolute.path);
    } catch (e) {
      debugPrint('Error picking video: $e');
      return null;
    }
  }

  Future<void> deleteMedia(String filePath) async {
    if (kIsWeb) return; // No need to delete in web environment
    
    try {
      final File file = File(path.normalize(filePath));
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting media: $e');
    }
  }

  bool isValidMediaPath(String? filePath) {
    if (filePath == null || filePath.isEmpty) return false;
    if (kIsWeb) return true; // Always return true for web paths
    
    try {
      final String normalizedPath = path.normalize(filePath);
      final file = File(normalizedPath);
      return file.existsSync();
    } catch (e) {
      debugPrint('Error checking media path: $e');
      return false;
    }
  }
} 