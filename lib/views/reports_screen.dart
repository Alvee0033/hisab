import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../viewmodels/transaction_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  String _getLocalizedCategoryName(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case 'Food': return l10n.catFood;
      case 'Transport': return l10n.catTransport;
      case 'Shopping': return l10n.catShopping;
      case 'Entertainment': return l10n.catEntertainment;
      case 'Bills': return l10n.catBills;
      case 'Health': return l10n.catHealth;
      case 'Education': return l10n.catEducation;
      case 'Salary': return l10n.catSalary;
      case 'Other': return l10n.catOther;
      default: return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categorySpending = transactionProvider.categorySpending;
    final totalExpense = transactionProvider.totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reports),
        centerTitle: true,
      ),
      body: categorySpending.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noExpensesYet,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Pie Chart Card
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.expenseBreakdown,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: categorySpending.entries.map((entry) {
                                final percentage = (entry.value / totalExpense) * 100;
                                return PieChartSectionData(
                                  color: _getCategoryColor(entry.key),
                                  value: entry.value,
                                  title: '${percentage.toStringAsFixed(0)}%',
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category List
                  ...categorySpending.entries.map((entry) {
                    final percentage = (entry.value / totalExpense);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(entry.key).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getCategoryIcon(entry.key),
                                  color: _getCategoryColor(entry.key),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getLocalizedCategoryName(context, entry.key),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF2D3142),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: percentage,
                                      backgroundColor: Colors.grey.shade100,
                                      color: _getCategoryColor(entry.key),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '৳${entry.value.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF2D3142),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': return const Color(0xFFFF6584);
      case 'Transport': return const Color(0xFF38E54D);
      case 'Shopping': return const Color(0xFF6C63FF);
      case 'Entertainment': return const Color(0xFFFFC107);
      case 'Bills': return const Color(0xFF00BCD4);
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant;
      case 'Transport': return Icons.directions_bus;
      case 'Shopping': return Icons.shopping_bag;
      case 'Entertainment': return Icons.movie;
      case 'Bills': return Icons.receipt;
      default: return Icons.more_horiz;
    }
  }
}
