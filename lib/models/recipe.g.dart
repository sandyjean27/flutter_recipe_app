// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 0;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      ingredients: (fields[3] as List?)?.cast<String>(),
      instructions: (fields[4] as List?)?.cast<String>(),
      categories: (fields[6] as List?)?.cast<String>(),
      preparationTime: fields[8] as int?,
      cookingTime: fields[9] as int?,
      servings: fields[10] as int?,
      creatorId: fields[13] as String,
      createdAt: fields[15] as DateTime?,
      imageUrl: fields[5] as String,
      imagePath: fields[17] as String?,
      videoUrl: fields[12] as String?,
      rating: fields[11] as double?,
      dietaryPreferences: (fields[7] as List?)?.cast<String>(),
      sharedWithUserIds: (fields[14] as List?)?.cast<String>(),
      updatedAt: fields[16] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.ingredients)
      ..writeByte(4)
      ..write(obj.instructions)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.categories)
      ..writeByte(7)
      ..write(obj.dietaryPreferences)
      ..writeByte(8)
      ..write(obj.preparationTime)
      ..writeByte(9)
      ..write(obj.cookingTime)
      ..writeByte(10)
      ..write(obj.servings)
      ..writeByte(11)
      ..write(obj.rating)
      ..writeByte(12)
      ..write(obj.videoUrl)
      ..writeByte(13)
      ..write(obj.creatorId)
      ..writeByte(14)
      ..write(obj.sharedWithUserIds)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
