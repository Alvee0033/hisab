import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExpenseSummaryWidget extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double dailyAverage;
  final Map<String, double> categorySpending;

  const ExpenseSummaryWidget({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.dailyAverage,
    required this.categorySpending,
  });

  String _getLocalizedCategoryName(BuildContext context, String categoryId) {
    final l10n = AppLocalizations.of(context)!;
    switch (categoryId) {
      case 'Food': return l10n.catFood;
      case 'Transport': return l10n.catTransport;
      case 'Shopping': return l10n.catShopping;
      case 'Entertainment': return l10n.catEntertainment;
      case 'Bills': return l10n.catBills;
      case 'Health': return l10n.catHealth;
      case 'Education': return l10n.catEducation;
      case 'Salary': return l10n.catSalary;
      case 'Other': return l10n.catOther;
      default: return categoryId;
    }
  }

  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'Food': return const Color(0xFFFF6584);
      case 'Transport': return const Color(0xFF38E54D);
      case 'Shopping': return const Color(0xFF29C7AC);
      case 'Entertainment': return const Color(0xFFFFBC00);
      case 'Bills': return const Color(0xFF6C63FF);
      case 'Health': return const Color(0xFFFA8231);
      case 'Education': return const Color(0xFF0FB9B1);
      case 'Other': return const Color(0xFF8854D0);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    List<PieChartSectionData> sections = [];
    if (categorySpending.isEmpty) {
       sections.add(PieChartSectionData(
        color: Colors.grey.shade100,
        value: 1,
        title: '',
        radius: 25,
      ));
    } else {
      categorySpending.forEach((key, value) {
        final percentage = (value / totalExpense) * 100;
        // Only show if percentage is significant enough to be visible
        if (percentage > 2) {
             sections.add(PieChartSectionData(
            color: _getCategoryColor(key),
            value: value,
            title: '${percentage.toStringAsFixed(0)}%',
            radius: 35,
            titleStyle: const TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.bold, 
              color: Colors.white
            ),
          ));
        }
      });
    }

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dailyAverage,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '৳${dailyAverage.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLegendItem(
                      color: const Color(0xFF38E54D),
                      label: l10n.income,
                      amount: totalIncome,
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      color: const Color(0xFFFF6584),
                      label: l10n.expense,
                      amount: totalExpense,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: sections,
                        ),
                      ),
                      if (categorySpending.isNotEmpty)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.expense,
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.expenseBreakdown,
                              style: TextStyle(
                                fontSize: 6,
                                color: Colors.grey[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (categorySpending.isNotEmpty) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categorySpending.entries.take(3).map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(e.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getLocalizedCategoryName(context, e.key),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required double amount,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          '৳${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
          ),
        ),
      ],
    );
  }
}
