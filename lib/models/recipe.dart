import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final List<String> ingredients;

  @HiveField(4)
  final List<String> instructions;

  @HiveField(5)
  String imageUrl;

  @HiveField(6)
  final List<String> categories;

  @HiveField(7)
  final List<String> dietaryPreferences;

  @HiveField(8)
  final int preparationTime;

  @HiveField(9)
  final int cookingTime;

  @HiveField(10)
  final int servings;

  @HiveField(11)
  final double rating;

  @HiveField(12)
  String? videoUrl;

  @HiveField(13)
  final String creatorId;

  @HiveField(14)
  final List<String> sharedWithUserIds;

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final DateTime? updatedAt;

  @HiveField(17)
  String? imagePath;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    List<String>? ingredients,
    List<String>? instructions,
    List<String>? categories,
    int? preparationTime,
    int? cookingTime,
    int? servings,
    required this.creatorId,
    DateTime? createdAt,
    this.imageUrl = '',
    this.imagePath,
    this.videoUrl,
    double? rating,
    List<String>? dietaryPreferences,
    List<String>? sharedWithUserIds,
    this.updatedAt,
  }) : 
    ingredients = ingredients ?? [],
    instructions = instructions ?? [],
    categories = categories ?? [],
    preparationTime = preparationTime ?? 0,
    cookingTime = cookingTime ?? 0,
    servings = servings ?? 1,
    rating = rating ?? 0.0,
    dietaryPreferences = dietaryPreferences ?? [],
    sharedWithUserIds = sharedWithUserIds ?? [],
    createdAt = createdAt ?? DateTime.now();

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? ingredients,
    List<String>? instructions,
    String? imageUrl,
    List<String>? categories,
    List<String>? dietaryPreferences,
    int? preparationTime,
    int? cookingTime,
    int? servings,
    double? rating,
    String? videoUrl,
    String? creatorId,
    List<String>? sharedWithUserIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imagePath,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      preparationTime: preparationTime ?? this.preparationTime,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      rating: rating ?? this.rating,
      videoUrl: videoUrl ?? this.videoUrl,
      creatorId: creatorId ?? this.creatorId,
      sharedWithUserIds: sharedWithUserIds ?? this.sharedWithUserIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'categories': categories,
      'dietaryPreferences': dietaryPreferences,
      'preparationTime': preparationTime,
      'cookingTime': cookingTime,
      'servings': servings,
      'rating': rating,
      'videoUrl': videoUrl,
      'creatorId': creatorId,
      'sharedWithUserIds': sharedWithUserIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      imageUrl: map['imageUrl']?.toString() ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      dietaryPreferences: List<String>.from(map['dietaryPreferences'] ?? []),
      preparationTime: int.tryParse(map['preparationTime']?.toString() ?? '') ?? 0,
      cookingTime: int.tryParse(map['cookingTime']?.toString() ?? '') ?? 0,
      servings: int.tryParse(map['servings']?.toString() ?? '') ?? 1,
      rating: double.tryParse(map['rating']?.toString() ?? '') ?? 0.0,
      videoUrl: map['videoUrl']?.toString(),
      creatorId: map['creatorId']?.toString() ?? 'unknown',
      sharedWithUserIds: List<String>.from(map['sharedWithUserIds'] ?? []),
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
      imagePath: map['imagePath']?.toString(),
    );
  }
} 