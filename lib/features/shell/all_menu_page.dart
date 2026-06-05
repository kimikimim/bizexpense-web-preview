import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:characters/characters.dart';

import '../../core/providers/theme_provider.dart';
import '../../core/providers/country_config_provider.dart';
import '../../core/utils/excel_service.dart';
import 'package:expense_pro/l10n/app_localizations.dart';

import '../transactions/data/transaction_repository.dart';
import '../transactions/data/transaction_model.dart';

import '../statistics/presentation/statistics_page.dart';
import '../tax/presentation/tax_calendar_page.dart';
import '../tax/presentation/tax_summary_page.dart';
import '../recurring/presentation/recurring_list_page.dart';
import '../transactions/presentation/invoice_page.dart';
import '../transactions/presentation/my_invoices_page.dart';
import '../user/presentation/settings_page.dart';
import '../auth/presentation/login_page.dart';
import '../user/presentation/profile_edit_page.dart';

class AllMenuPage extends ConsumerStatefulWidget {
  const AllMenuPage({super.key});

  @override
  ConsumerState<AllMenuPage> createState() => _AllMenuPageState();
}

class _AllMenuPageState extends ConsumerState<AllMenuPage> {
  bool _isExporting = false;

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutDialogTitle),
        content: Text(l10n.logoutDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.logoutConfirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _exportExcel({
    required bool forAccounting,
  }) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final repo = TransactionRepository();
      final List<TransactionModel> txs = await repo.getTransactions();

      final l10n = AppLocalizations.of(context)!;
      final config = ref.read(countryConfigProvider);
      if (txs.isEmpty) {
        _showSnackBar(l10n.noDataToExport);
      } else {
        final excel = ExcelService();
        if (forAccounting) {
          await excel.exportForAccounting(txs, config: config);
          _showSnackBar(l10n.exportExcelSuccess);
        } else {
          await excel.exportToExcel(txs, config: config);
          _showSnackBar(l10n.exportExcelBasicSuccess);
        }
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _showSnackBar(l10n.exportExcelError);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);
    final isKorea = ref.watch(countryConfigProvider).countryCode == 'KR';
    final user = Supabase.instance.client.auth.currentUser;

    final displayName = (user?.userMetadata?['name'] as String?) ?? 'Boss';
    final email = user?.email ?? '';
    final nickname = (user?.userMetadata?['nickname'] as String?) ?? '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l10n.menuAll,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildProfileHeader(
            isDark: isDark,
            name: displayName,
            email: email,
            nickname: nickname,
          ),

          const SizedBox(height: 16),

          _buildQuickAppsSection(isDark, l10n, isKorea),

          const SizedBox(height: 24),

          _buildSectionTitle(l10n.menuBusinessManagement),
          _buildMenuCard(
            isDark: isDark,
            children: [
              _buildMenuTile(
                icon: Icons.bar_chart,
                iconColor: Colors.blue,
                title: l10n.menuStatisticsAnalysis,
                subtitle: l10n.menuStatisticsAnalysisSub,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StatisticsPage(),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                icon: Icons.person_outline,
                iconColor: Colors.blueGrey,
                title: l10n.menuProfileSettings,
                subtitle: l10n.menuProfileSettingsSub,
                onTap: () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileEditPage(),
                    ),
                  );

                  if (changed == true && mounted) {
                    setState(() {});
                  }
                },
              ),
              if (isKorea)
                _buildMenuTile(
                  icon: Icons.receipt_long,
                  iconColor: Colors.purple,
                  title: l10n.menuTaxReport,
                  subtitle: l10n.menuTaxReportSub,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TaxSummaryPage(),
                      ),
                    );
                  },
                ),
              _buildMenuTile(
                icon: Icons.calendar_today,
                iconColor: Colors.orange,
                title: l10n.menuTaxSchedule,
                subtitle: l10n.menuTaxScheduleSub,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TaxCalendarPage(),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                icon: Icons.repeat,
                iconColor: Colors.teal,
                title: l10n.menuRecurring,
                subtitle: l10n.menuRecurringSub,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecurringListPage(),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                icon: Icons.description_outlined,
                iconColor: Colors.indigo,
                title: l10n.menuInvoice,
                subtitle: l10n.menuInvoiceSub,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InvoicePage(),
                    ),
                  );
                },
              ),
              // ME-only: issued-invoice ledger (vat_invoices table is ME-only)
              if (!isKorea)
                _buildMenuTile(
                  icon: Icons.receipt_long,
                  iconColor: Colors.deepPurple,
                  title: l10n.menuMyInvoices,
                  subtitle: l10n.menuMyInvoicesSub,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyInvoicesPage(),
                      ),
                    );
                  },
                ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSectionTitle(l10n.menuDataManagement),
          _buildMenuCard(
            isDark: isDark,
            children: [
              _buildMenuTile(
                icon: Icons.file_download,
                iconColor: Colors.green,
                title: l10n.menuExportExcel,
                subtitle: l10n.menuExportExcelSub,
                trailing: _isExporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: () => _exportExcel(forAccounting: false),
              ),
              _buildMenuTile(
                icon: Icons.table_view,
                iconColor: Colors.lightBlue,
                title: l10n.menuTaxExcel,
                subtitle: l10n.menuTaxExcelSub,
                trailing: _isExporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: () => _exportExcel(forAccounting: true),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSectionTitle(l10n.menuPreferences),
          _buildMenuCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                value: themeMode == ThemeMode.dark,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).toggleTheme(value);
                },
                title: Text(l10n.menuDarkMode),
                secondary: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: themeMode == ThemeMode.dark
                      ? Colors.yellow
                      : Colors.grey,
                ),
              ),
              const Divider(height: 0),
              _buildMenuTile(
                icon: Icons.logout,
                iconColor: Colors.red,
                title: l10n.menuLogout,
                subtitle: l10n.menuLogoutSub,
                isDestructive: true,
                onTap: _logout,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader({
    required bool isDark,
    required String name,
    required String email,
    String? nickname,
  }) {
    final initial = name.isNotEmpty ? name.characters.first : 'B';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blueGrey[700],
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email.isNotEmpty ? email : AppLocalizations.of(context)!.menuManagingBusiness,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.settings_outlined,
                size: 20,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAppsSection(bool isDark, AppLocalizations l10n, bool isKorea) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.menuFrequentlyUsed),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.8,
            children: [
              _buildQuickIcon(
                icon: Icons.bar_chart,
                label: l10n.menuStatisticsShort,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StatisticsPage(),
                    ),
                  );
                },
              ),
              if (isKorea)
                _buildQuickIcon(
                  icon: Icons.receipt_long,
                  label: l10n.menuTaxReportShort,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TaxSummaryPage(),
                      ),
                    );
                  },
                ),
              _buildQuickIcon(
                icon: Icons.calendar_today,
                label: l10n.menuTaxScheduleShort,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TaxCalendarPage(),
                    ),
                  );
                },
              ),
              _buildQuickIcon(
                icon: Icons.settings_outlined,
                label: l10n.menuSettingsShort,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i != 0) const Divider(height: 0),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
    Widget? trailing,
  }) {
    final textColor = isDestructive ? Colors.red : null;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: iconColor.withOpacity(0.12),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 11),
            )
          : null,
      trailing: trailing ??
          const Icon(
            Icons.chevron_right,
            size: 18,
          ),
    );
  }
}
