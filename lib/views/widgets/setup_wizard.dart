import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../viewmodels/settings_provider.dart';
import '../../services/hive_service.dart';

class SetupWizard extends StatefulWidget {
  final VoidCallback onFinish;

  const SetupWizard({super.key, required this.onFinish});

  @override
  State<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends State<SetupWizard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Salary State
  bool _enableSalary = false;
  final TextEditingController _salaryController = TextEditingController();
  int _selectedDate = 1;
  int _billingCycleDay = 1;

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 400,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildLanguagePage(context, settingsProvider, l10n),
                  _buildCurrencyPage(context, settingsProvider, l10n),
                  _buildBillingCyclePage(context, l10n),
                  _buildSalaryPage(context, l10n),
                  _buildWelcomePage(context, l10n),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(l10n.back),
                  )
                else
                  const SizedBox(width: 60),
                
                Row(
                  children: List.generate(5, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == index
                            ? theme.primaryColor
                            : Colors.grey.shade200,
                      ),
                    );
                  }),
                ),

                if (_currentPage < 4)
                  FilledButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(l10n.next),
                  )
                else
                  FilledButton(
                    onPressed: () async {
                      // Save Billing Cycle
                      await settingsProvider.setBillingCycleStartDay(_billingCycleDay);

                      // Save Salary Settings
                      if (_enableSalary && _salaryController.text.isNotEmpty) {
                        await settingsProvider.setSalarySettings(
                          amount: double.tryParse(_salaryController.text) ?? 0.0,
                          date: _selectedDate,
                          enabled: true,
                        );
                      }

                      final box = HiveService.getSettingsBox();
                      await box.put('isFirstRun', false);
                      widget.onFinish();
                    },
                    child: Text(l10n.finish),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingCyclePage(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.calendar_today, size: 48, color: Colors.orange),
        ),
        const SizedBox(height: 24),
        Text(
          "Billing Cycle", // TODO: Localize
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Select the day your monthly budget resets", // TODO: Localize
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        DropdownButtonFormField<int>(
          value: _billingCycleDay,
          decoration: InputDecoration(
            labelText: l10n.dayOfMonth,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: List.generate(28, (index) => index + 1).map((day) {
            return DropdownMenuItem(
              value: day,
              child: Text('$day${_getDaySuffix(day)}'),
            );
          }).toList(),
          onChanged: (val) => setState(() => _billingCycleDay = val!),
        ),
      ],
    );
  }

  Widget _buildLanguagePage(BuildContext context, SettingsProvider settings, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.language, size: 48, color: Colors.blue),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.selectLanguage,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 32),
        _buildOptionTile(
          context,
          title: l10n.english,
          subtitle: 'English',
          isSelected: settings.locale.languageCode == 'en',
          onTap: () => settings.setLocale(const Locale('en')),
        ),
        const SizedBox(height: 16),
        _buildOptionTile(
          context,
          title: l10n.bengali,
          subtitle: 'Bengali',
          isSelected: settings.locale.languageCode == 'bn',
          onTap: () => settings.setLocale(const Locale('bn')),
        ),
      ],
    );
  }

  Widget _buildCurrencyPage(BuildContext context, SettingsProvider settings, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.attach_money, size: 48, color: Colors.green),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.selectCurrency,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 32),
        _buildOptionTile(
          context,
          title: l10n.bangladeshiTaka,
          subtitle: '৳ (BDT)',
          isSelected: true,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        _buildOptionTile(
          context,
          title: l10n.usDollar,
          subtitle: '\$ (USD)',
          isSelected: false,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSalaryPage(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet, size: 48, color: Colors.purple),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.autoSalary,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.autoSalarySubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          
          SwitchListTile(
            title: Text(l10n.enableAutoSalary, style: const TextStyle(fontWeight: FontWeight.bold)),
            value: _enableSalary,
            onChanged: (val) => setState(() => _enableSalary = val),
            activeColor: Theme.of(context).primaryColor,
          ),
          
          if (_enableSalary) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.salaryAmount,
                prefixText: '৳ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedDate,
              decoration: InputDecoration(
                labelText: l10n.dayOfMonth,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: List.generate(28, (index) => index + 1).map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text('$day${_getDaySuffix(day)}'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedDate = val!),
            ),
          ],
        ],
      ),
    );
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  Widget _buildWelcomePage(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, size: 48, color: Colors.teal),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.allSet,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.allSetSubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildOptionTile(BuildContext context, {
    required String title, 
    required String subtitle,
    required bool isSelected, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Theme.of(context).primaryColor : const Color(0xFF2D3142),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
