import 'package:hive/hive.dart';
import '../utils/hive_constants.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: HiveConstants.transactionTypeId)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String categoryId;

  @HiveField(5)
  final bool isExpense; // true for expense, false for income

  @HiveField(6)
  final String? note;

  @HiveField(7)
  final String? attachmentPath;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.isExpense,
    this.note,
    this.attachmentPath,
  });
}
