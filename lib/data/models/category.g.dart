// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 5;

  @override
  Category read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Category(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      type: fields[3] as CategoryType,
      color: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryTypeAdapter extends TypeAdapter<CategoryType> {
  @override
  final int typeId = 2;

  @override
  CategoryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CategoryType.income;
      case 1:
        return CategoryType.expense;
      default:
        return CategoryType.income;
    }
  }

  @override
  void write(BinaryWriter writer, CategoryType obj) {
    switch (obj) {
      case CategoryType.income:
        writer.writeByte(0);
        break;
      case CategoryType.expense:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
