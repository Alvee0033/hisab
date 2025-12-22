import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../viewmodels/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.userEmail,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Settings Tiles
            _buildSectionHeader(context, l10n.preferences),
            const SizedBox(height: 16),
            
            _buildSettingTile(
              context,
              icon: Icons.dark_mode_rounded,
              title: l10n.darkMode,
              trailing: Switch(
                value: settingsProvider.themeMode == ThemeMode.dark,
                onChanged: (value) => settingsProvider.toggleTheme(value),
                activeColor: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildSettingTile(
              context,
              icon: Icons.language_rounded,
              title: l10n.language,
              trailing: DropdownButton<Locale>(
                value: settingsProvider.locale,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(
                    value: const Locale('en'),
                    child: Text(l10n.english),
                  ),
                  DropdownMenuItem(
                    value: const Locale('bn'),
                    child: Text(l10n.bengali),
                  ),
                ],
                onChanged: (Locale? locale) {
                  if (locale != null) {
                    settingsProvider.setLocale(locale);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            _buildSettingTile(
              context,
              icon: Icons.currency_exchange_rounded,
              title: l10n.selectCurrency,
              trailing: const Text(
                'BDT (৳)',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),

            _buildSettingTile(
              context,
              icon: Icons.calendar_today_rounded,
              title: "Billing Cycle", // TODO: Localize
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: settingsProvider.isBillingCycleEnabled,
                    onChanged: (value) {
                      settingsProvider.setBillingCycle(
                        settingsProvider.billingCycleStartDay,
                        value,
                      );
                    },
                    activeColor: theme.primaryColor,
                  ),
                  if (settingsProvider.isBillingCycleEnabled) ...[
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: settingsProvider.billingCycleStartDay,
                      underline: const SizedBox(),
                      items: List.generate(28, (index) => index + 1).map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text('$day'),
                        );
                      }).toList(),
                      onChanged: (int? day) {
                        if (day != null) {
                          settingsProvider.setBillingCycle(day, true);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader(context, l10n.data),
            const SizedBox(height: 16),

            _buildSettingTile(
              context,
              icon: Icons.cloud_upload_rounded,
              title: l10n.backupData,
              onTap: () {
                // Implement backup
              },
            ),
            const SizedBox(height: 12),
            _buildSettingTile(
              context,
              icon: Icons.delete_outline_rounded,
              title: l10n.clearAllData,
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                // Implement clear data
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
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
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor ?? Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor ?? const Color(0xFF2D3142),
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }
}
