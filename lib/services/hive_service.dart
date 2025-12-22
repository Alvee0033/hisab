import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/user_model.dart';

class HiveService {
  static const String transactionBoxName = 'transactions';
  static const String categoryBoxName = 'categories';
  static const String userBoxName = 'user';
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(UserModelAdapter());

    // Open Boxes
    await Hive.openBox<TransactionModel>(transactionBoxName);
    await Hive.openBox<CategoryModel>(categoryBoxName);
    await Hive.openBox<UserModel>(userBoxName);
    await Hive.openBox(settingsBoxName);
  }

  // Transactions
  static Box<TransactionModel> getTransactionBox() {
    return Hive.box<TransactionModel>(transactionBoxName);
  }

  static Future<void> addTransaction(TransactionModel transaction) async {
    final box = getTransactionBox();
    await box.put(transaction.id, transaction);
  }

  static Future<void> deleteTransaction(String id) async {
    final box = getTransactionBox();
    await box.delete(id);
  }

  static List<TransactionModel> getAllTransactions() {
    final box = getTransactionBox();
    return box.values.toList();
  }

  // Categories
  static Box<CategoryModel> getCategoryBox() {
    return Hive.box<CategoryModel>(categoryBoxName);
  }

  static Future<void> addCategory(CategoryModel category) async {
    final box = getCategoryBox();
    await box.put(category.id, category);
  }

  static List<CategoryModel> getAllCategories() {
    final box = getCategoryBox();
    return box.values.toList();
  }

  // Settings
  static Box getSettingsBox() {
    return Hive.box(settingsBoxName);
  }
}
