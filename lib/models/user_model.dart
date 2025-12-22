import 'package:hive/hive.dart';
import '../utils/hive_constants.dart';

part 'user_model.g.dart';

@HiveType(typeId: HiveConstants.userTypeId)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? displayName;

  @HiveField(3)
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}
