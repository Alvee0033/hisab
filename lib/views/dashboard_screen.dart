import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../viewmodels/transaction_provider.dart';
import '../viewmodels/settings_provider.dart';
import '../services/hive_service.dart';
import 'widgets/expense_summary_widget.dart';
import 'widgets/weekly_graph_widget.dart';
import 'widgets/transaction_list_item.dart';
import 'widgets/setup_wizard.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';
import 'reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load transactions and check salary
    Future.microtask(() {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      
      transactionProvider.loadTransactions();
      transactionProvider.checkAndAddSalary(settingsProvider);
      
      _checkFirstRun();
    });
  }

  Future<void> _checkFirstRun() async {
    final box = HiveService.getSettingsBox();
    final isFirstRun = box.get('isFirstRun', defaultValue: true);

    if (isFirstRun) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SetupWizard(
          onFinish: () {
            Navigator.pop(context);
            setState(() {}); // Refresh to apply changes
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    // Real data from provider
    final weeklyData = transactionProvider.weeklySpending;
    final billingDay = settingsProvider.billingCycleStartDay;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // Light background
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 80,
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 10),
                  title: Row(
                    children: [
                      Text(
                        _selectedIndex == 0 ? l10n.dashboard : l10n.transactions,
                        style: const TextStyle(
                          color: Color(0xFF2D3142),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF2D3142)),
                    onPressed: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.settings_rounded, color: Color(0xFF2D3142)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              if (_selectedIndex == 0) ...[
                // Dashboard Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        ExpenseSummaryWidget(
                          totalIncome: transactionProvider.getTotalIncome(billingDay, settingsProvider.isBillingCycleEnabled),
                          totalExpense: transactionProvider.getTotalExpense(billingDay, settingsProvider.isBillingCycleEnabled),
                          dailyAverage: transactionProvider.dailyAverage,
                          categorySpending: transactionProvider.categorySpending,
                        ),
                        const SizedBox(height: 12),
                        WeeklyGraphWidget(weeklyData: weeklyData),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.recentTransactions,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _selectedIndex = 1),
                              child: Text(l10n.viewAll),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= transactionProvider.transactions.length) return null;
                      // Show only last 5 transactions on dashboard
                      if (index >= 5) return null;
                      
                      final transaction = transactionProvider.transactions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: TransactionListItem(
                          transaction: transaction,
                          onDelete: () {
                            transactionProvider.deleteTransaction(transaction.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Transaction deleted')),
                            );
                          },
                        ),
                      );
                    },
                    childCount: transactionProvider.transactions.length > 5 
                        ? 5 
                        : transactionProvider.transactions.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ] else ...[
                // All Transactions List
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButton<String>(
                            value: transactionProvider.filterType,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.filter_list_rounded, color: Color(0xFF2D3142), size: 20),
                            isDense: true,
                            items: ['Week', 'Month', 'All'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value == 'Week' ? 'This Week' : (value == 'Month' ? 'This Month' : 'All Time'),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                transactionProvider.setFilterType(newValue);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final filteredTxs = transactionProvider.filteredTransactions;
                        if (index >= filteredTxs.length) return null;
                        
                        final transaction = filteredTxs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TransactionListItem(
                            transaction: transaction,
                            onDelete: () {
                              transactionProvider.deleteTransaction(transaction.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Transaction deleted')),
                              );
                            },
                          ),
                        );
                      },
                      childCount: transactionProvider.filteredTransactions.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ],
          ),

          // Floating Dock
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDockItem(0, Icons.dashboard_rounded, l10n.dashboard),
                    const SizedBox(width: 24),
                    _buildDockItem(1, Icons.list_alt_rounded, l10n.transactions),
                    const SizedBox(width: 24),
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                        );
                      },
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 4,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                    const SizedBox(width: 24),
                    _buildDockItem(2, Icons.pie_chart_rounded, l10n.reports, onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportsScreen()),
                      );
                    }),
                    const SizedBox(width: 24),
                    _buildDockItem(3, Icons.settings_rounded, l10n.settings, onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockItem(int index, IconData icon, String label, {VoidCallback? onTap}) {
    final isSelected = _selectedIndex == index && onTap == null;
    return GestureDetector(
      onTap: onTap ?? () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}
