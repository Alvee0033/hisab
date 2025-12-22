import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../services/hive_service.dart';
import 'settings_provider.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  String _filterType = 'Month'; // 'Week', 'Month', 'All'

  List<TransactionModel> get transactions => _transactions;
  String get filterType => _filterType;

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  List<TransactionModel> get filteredTransactions {
    if (_filterType == 'All') return _transactions;

    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    if (_filterType == 'Week') {
      // Start of current week (Monday)
      start = now.subtract(Duration(days: now.weekday - 1));
      start = DateTime(start.year, start.month, start.day);
    } else {
      // Month (default) - Logic will be handled by billing cycle in UI or here if we pass settings
      // For now, standard month
      start = DateTime(now.year, now.month, 1);
    }

    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) && 
             t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Helper to get transactions based on billing cycle
  List<TransactionModel> getTransactionsForBillingCycle(int startDay) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    if (now.day >= startDay) {
      // Current month cycle
      start = DateTime(now.year, now.month, startDay);
      // End is next month start day - 1 second
      if (now.month == 12) {
        end = DateTime(now.year + 1, 1, startDay).subtract(const Duration(seconds: 1));
      } else {
        end = DateTime(now.year, now.month + 1, startDay).subtract(const Duration(seconds: 1));
      }
    } else {
      // Previous month cycle
      if (now.month == 1) {
        start = DateTime(now.year - 1, 12, startDay);
      } else {
        start = DateTime(now.year, now.month - 1, startDay);
      }
      end = DateTime(now.year, now.month, startDay).subtract(const Duration(seconds: 1));
    }

    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) && 
             t.date.isBefore(end);
    }).toList();
  }

  double get totalIncome {
    return filteredTransactions
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return filteredTransactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double getTotalIncome(int billingStartDay, bool isBillingCycleEnabled) {
    final txs = _filterType == 'Month' 
        ? (isBillingCycleEnabled ? getTransactionsForBillingCycle(billingStartDay) : filteredTransactions)
        : filteredTransactions;
        
    return txs
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double getTotalExpense(int billingStartDay, bool isBillingCycleEnabled) {
    final txs = _filterType == 'Month' 
        ? (isBillingCycleEnabled ? getTransactionsForBillingCycle(billingStartDay) : filteredTransactions)
        : filteredTransactions;

    return txs
        .where((t) => t.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get balance => totalIncome - totalExpense; // This might need update but let's keep simple for now

  // Get spending for the last 7 days (including today)
  List<double> get weeklySpending {
    final now = DateTime.now();
    final List<double> spending = List.filled(7, 0.0);

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

      final dailyTotal = _transactions
          .where((t) =>
              t.isExpense &&
              t.date.isAfter(startOfDay) &&
              t.date.isBefore(endOfDay))
          .fold(0.0, (sum, item) => sum + item.amount);
      
      spending[i] = dailyTotal;
    }
    return spending;
  }

  // Calculate daily average for the current month
  double get dailyAverage {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final daysPassed = now.difference(startOfMonth).inDays + 1;
    
    final monthlyExpense = _transactions
        .where((t) => 
            t.isExpense && 
            t.date.isAfter(startOfMonth) && 
            t.date.isBefore(now.add(const Duration(days: 1))))
        .fold(0.0, (sum, item) => sum + item.amount);

    return daysPassed > 0 ? monthlyExpense / daysPassed : 0.0;
  }

  // Get spending by category
  Map<String, double> get categorySpending {
    final Map<String, double> spending = {};
    
    for (var t in _transactions.where((t) => t.isExpense)) {
      spending[t.categoryId] = (spending[t.categoryId] ?? 0) + t.amount;
    }
    
    return spending;
  }

  Future<void> loadTransactions() async {
    final box = HiveService.getTransactionBox();
    _transactions = box.values.toList();
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final box = HiveService.getTransactionBox();
    await box.put(transaction.id, transaction);
    _transactions.add(transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    final box = HiveService.getTransactionBox();
    await box.delete(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> checkAndAddSalary(SettingsProvider settings) async {
    if (!settings.isSalaryEnabled) return;

    final now = DateTime.now();
    // Check if today is the salary day
    if (now.day == settings.salaryDate) {
      final box = HiveService.getSettingsBox();
      final lastSalaryMonth = box.get('lastSalaryMonth');

      // If we haven't added salary for this month yet
      if (lastSalaryMonth != now.month) {
        final salaryTransaction = TransactionModel(
          id: const Uuid().v4(),
          title: 'Auto Salary',
          amount: settings.salaryAmount,
          date: now,
          categoryId: 'Salary',
          isExpense: false,
          note: 'Automatically added monthly salary',
        );

        await addTransaction(salaryTransaction);
        await box.put('lastSalaryMonth', now.month);
      }
    }
  }
}
