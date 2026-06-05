import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_pro/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/providers/font_size_provider.dart';
import '../../../core/providers/country_config_provider.dart';
import '../../../core/providers/locale_provider.dart';

import '../../transactions/presentation/my_business_page.dart';
import '../../tax/presentation/tax_setup_page.dart';
import '../../../core/utils/backup_service.dart';
import '../../../core/utils/excel_service.dart';
import '../../transactions/data/transaction_repository.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _appVersion = "";
  final BackupService _backupService = BackupService();
  final ExcelService _excelService = ExcelService();
  final TransactionRepository _transactionRepository = TransactionRepository();

  final String _supportEmail = 'support@bizexpense.com';
  final String _kakaoOpenChatUrl = 'https://open.kakao.com/o/your_link_id';
  final String _termsUrl = 'https://your-notion-url.com/terms';
  final String _privacyUrl = 'https://your-notion-url.com/privacy';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  static const _languages = [
    ('ko', '한국어'),
    ('en', 'English'),
    ('ar', 'العربية'),
  ];

  String _languageLabel(String code) {
    for (final l in _languages) {
      if (l.$1 == code) return l.$2;
    }
    return code;
  }

  void _showLanguagePicker(BuildContext context, bool isDark, String currentLang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  AppLocalizations.of(ctx)!.settingsLanguagePickerTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF191F28),
                  ),
                ),
              ),
              for (final lang in _languages)
                ListTile(
                  title: Text(
                    lang.$2,
                    style: TextStyle(
                      fontWeight: lang.$1 == currentLang ? FontWeight.bold : FontWeight.normal,
                      color: lang.$1 == currentLang ? const Color(0xFF3182F6) : null,
                    ),
                  ),
                  trailing: lang.$1 == currentLang
                      ? const Icon(Icons.check_rounded, color: Color(0xFF3182F6))
                      : null,
                  onTap: () async {
                    await ref.read(localeProvider.notifier).setLanguage(lang.$1);
                    if (context.mounted) Navigator.pop(ctx);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = info.version;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.settingsLinkError)));
    }
  }

  Future<void> _sendEmail() async {
    final l10n = AppLocalizations.of(context)!;
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: _encodeQueryParameters(<String, String>{
        'subject': l10n.settingsInquirySubject,
        'body': l10n.settingsInquiryBody,
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.settingsMailError)));
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentFontSizeLevel = ref.watch(fontSizeProvider);
    final currentCountry = ref.watch(countryConfigProvider);
    final isKorea = currentCountry.countryCode == 'KR';
    final selectedLanguage = ref.watch(localeProvider);
    final effectiveLang = selectedLanguage ?? currentCountry.languageCode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // ── Display ─────────────────────────────
          _sectionLabel(l10n.settingsDisplaySettings, isDark),
          _card(isDark, [
            _fontSizeControl(currentFontSizeLevel, l10n),
            // Language — changeable independently of the account's region.
            _tile(
              leading: _leadingIcon(Icons.language, Colors.blue),
              title: l10n.settingsLanguage,
              subtitle: _languageLabel(effectiveLang),
              onTap: () => _showLanguagePicker(context, isDark, effectiveLang),
            ),
            // Region — fixed at signup (determines which data center the
            // account lives in), so it's read-only here.
            ListTile(
              leading: Text(currentCountry.flagEmoji, style: const TextStyle(fontSize: 22)),
              title: Text(l10n.settingsCountryRegion,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(
                "${currentCountry.countryName} · ${l10n.settingsRegionFixedNote}",
                style: const TextStyle(fontSize: 11),
              ),
              trailing: Icon(Icons.lock_outline, size: 16, color: Colors.grey[400]),
            ),
          ]),
          const SizedBox(height: 22),

          // ── Business ────────────────────────────
          _sectionLabel(l10n.settingsBusinessManagement, isDark),
          _card(isDark, [
            _tile(
              leading: _leadingIcon(Icons.person_pin, Colors.indigo),
              title: l10n.settingsMyBusinessInfo,
              subtitle: l10n.settingsMyBusinessInfoSub,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyBusinessPage())),
            ),
            if (isKorea)
              _tile(
                leading: _leadingIcon(Icons.calendar_month, Colors.indigo),
                title: l10n.settingsTaxScheduleSetup,
                subtitle: l10n.settingsTaxScheduleSetupSub,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaxSetupPage())),
              ),
          ]),
          const SizedBox(height: 22),

          // ── Data ────────────────────────────────
          _sectionLabel(l10n.menuDataManagement, isDark),
          _card(isDark, [
            _tile(
              leading: _leadingIcon(Icons.cloud_upload, Colors.green),
              title: l10n.settingsDataBackup,
              subtitle: l10n.settingsDataBackupSub,
              onTap: _runAutoBackup,
            ),
            _tile(
              leading: _leadingIcon(Icons.file_download_outlined, Colors.blue),
              title: l10n.settingsBackupFileDownload,
              subtitle: l10n.settingsBackupFileDownloadSub,
              onTap: _downloadBackup,
            ),
            _tile(
              leading: _leadingIcon(Icons.restore, Colors.orange),
              title: l10n.settingsDataRestore,
              subtitle: l10n.settingsDataRestoreSub,
              onTap: _restoreBackup,
            ),
            _tile(
              leading: _leadingIcon(Icons.account_balance_wallet, Colors.indigo),
              title: l10n.settingsTaxSettlementExcel,
              subtitle: l10n.settingsTaxSettlementExcelSub,
              onTap: _exportTaxExcel,
            ),
          ]),
          const SizedBox(height: 22),

          // ── Support ─────────────────────────────
          _sectionLabel(l10n.settingsSupport, isDark),
          _card(isDark, [
            if (isKorea)
              _tile(
                leading: _leadingIcon(Icons.chat_bubble_outline, Colors.amber),
                title: l10n.settingsKakaoInquiry,
                subtitle: l10n.settingsKakaoInquirySub,
                onTap: () => _launchUrl(_kakaoOpenChatUrl),
              ),
            _tile(
              leading: _leadingIcon(Icons.email_outlined, Colors.blue),
              title: l10n.settingsEmailInquiry,
              onTap: _sendEmail,
            ),
          ]),
          const SizedBox(height: 22),

          // ── Legal ───────────────────────────────
          _sectionLabel(l10n.settingsTermsAndPolicy, isDark),
          _card(isDark, [
            _tile(
              leading: _leadingIcon(Icons.description_outlined, Colors.blueGrey),
              title: l10n.settingsTermsOfService,
              onTap: () => _launchUrl(_termsUrl),
            ),
            _tile(
              leading: _leadingIcon(Icons.privacy_tip_outlined, Colors.blueGrey),
              title: l10n.settingsPrivacyPolicy,
              onTap: () => _launchUrl(_privacyUrl),
            ),
            _tile(
              leading: _leadingIcon(Icons.policy_outlined, Colors.blueGrey),
              title: l10n.settingsOpenSourceLicense,
              onTap: () => showLicensePage(context: context, applicationName: "BizExpense", applicationVersion: _appVersion),
            ),
          ]),
          const SizedBox(height: 28),

          Center(
            child: Text(
              "BizExpense · v$_appVersion",
              style: TextStyle(fontSize: 12, color: Colors.grey[isDark ? 600 : 500]),
            ),
          ),
        ],
      ),
    );
  }

  // ── reusable UI ───────────────────────────────
  Widget _sectionLabel(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.blueGrey,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _card(bool isDark, List<Widget> children) {
    final visible = children.whereType<Widget>().toList();
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < visible.length; i++) ...[
            if (i != 0) const Divider(height: 1),
            visible[i],
          ],
        ],
      ),
    );
  }

  Widget _leadingIcon(IconData icon, Color color) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: color.withOpacity(0.12),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _tile({
    required Widget leading,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: leading,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 11)) : null,
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }

  Widget _fontSizeControl(int level, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.settingsFontSizeLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              Text(
                _getFontSizeLabel(level, l10n),
                style: TextStyle(color: Colors.blue[400], fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: level.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: Colors.blueGrey,
            label: _getFontSizeLabel(level, l10n),
            onChanged: (value) {
              ref.read(fontSizeProvider.notifier).setFontSize(value.toInt());
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.settingsSmall, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(l10n.settingsMedium, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(l10n.settingsLarge, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // ── actions (unchanged logic) ─────────────────
  Future<void> _runAutoBackup() async {
    final success = await _backupService.autoBackup();
    if (mounted) {
      final l10n2 = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? l10n2.settingsBackupSuccess : l10n2.settingsBackupFailed),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadBackup() async {
    final backupJson = await _backupService.createBackupFile();
    if (backupJson != null) {
      await Share.share(backupJson, subject: 'BizExpense Backup');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.settingsBackupShared)),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.settingsBackupShareFailed)),
        );
      }
    }
  }

  Future<void> _restoreBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        String backupJson;

        if (kIsWeb) {
          final bytes = result.files.single.bytes;
          if (bytes == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.settingsFileNotReadable)),
              );
            }
            return;
          }
          backupJson = utf8.decode(bytes);
        } else {
          final path = result.files.single.path;
          if (path == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.settingsFilePathNotFound)),
              );
            }
            return;
          }
          final file = File(path);
          backupJson = await file.readAsString();
        }

        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            final dl = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(dl.settingsRestoreDialogTitle),
              content: Text(dl.settingsRestoreDialogContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(dl.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(dl.settingsRestoreConfirm, style: const TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );

        if (confirm == true) {
          final success = await _backupService.restoreFromBackup(backupJson);
          if (mounted) {
            final l10n2 = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? l10n2.settingsRestoreSuccess : l10n2.settingsRestoreFailed),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.settingsFileReadFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _exportTaxExcel() async {
    final transactions = await _transactionRepository.getTransactions();
    if (transactions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noDataToExport)),
        );
      }
      return;
    }
    await _excelService.exportForAccounting(
      transactions,
      config: ref.read(countryConfigProvider),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.exportExcelSuccess)),
      );
    }
  }

  String _getFontSizeLabel(int level, AppLocalizations l10n) {
    switch (level) {
      case 1:
        return l10n.settingsFontSizeVerySmall;
      case 2:
        return l10n.settingsFontSizeSmall;
      case 3:
        return l10n.settingsFontSizeNormal;
      case 4:
        return l10n.settingsFontSizeLarge;
      case 5:
        return l10n.settingsFontSizeVeryLarge;
      default:
        return l10n.settingsFontSizeNormal;
    }
  }
}
