import 'package:hive/hive.dart';
import '../utils/hive_constants.dart';

part 'category_model.g.dart';

@HiveType(typeId: HiveConstants.categoryTypeId)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String iconCode; // Store icon as string code or path

  @HiveField(3)
  final int colorValue; // Store color as int

  @HiveField(4)
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    this.isDefault = false,
  });
}
