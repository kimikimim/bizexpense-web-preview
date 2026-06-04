import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_pro/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/providers/font_size_provider.dart';
import '../../../core/providers/country_config_provider.dart';
import '../../../core/config/country_tax_config.dart';

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

  void _showCountryPicker(BuildContext context, bool isDark) {
    final countries = kCountryConfigs.values.toList();
    final current = ref.read(countryConfigProvider);

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
                  AppLocalizations.of(ctx)!.settingsCountryPickerTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF191F28),
                  ),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: countries.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                ),
                itemBuilder: (_, i) {
                  final c = countries[i];
                  final isSelected = c.countryCode == current.countryCode;
                  return ListTile(
                    leading: Text(c.flagEmoji, style: const TextStyle(fontSize: 24)),
                    title: Text(
                      c.countryName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF3182F6) : null,
                      ),
                    ),
                    subtitle: Text('${c.vatTerminology} ${(c.vatRate * 100).toStringAsFixed(0)}% · ${c.currencySymbol}'),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: Color(0xFF3182F6))
                        : null,
                    onTap: () async {
                      await ref.read(countryConfigProvider.notifier).setCountry(c.countryCode);
                      if (context.mounted) Navigator.pop(ctx);
                    },
                  );
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
    if(mounted) {
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
    final sectionColor = isDark ? Colors.grey[400] : Colors.blueGrey;

    final currentFontSizeLevel = ref.watch(fontSizeProvider);
    final currentCountry = ref.watch(countryConfigProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(l10n.settingsDisplaySettings, style: TextStyle(color: sectionColor, fontWeight: FontWeight.bold)),
          ),
          Container(
            color: isDark ? Colors.grey[900] : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.settingsFontSizeLabel, style: const TextStyle(fontSize: 16)),
                    Text(
                      _getFontSizeLabel(currentFontSizeLevel, l10n),
                      style: TextStyle(color: Colors.blue[400], fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
                Slider(
                  value: currentFontSizeLevel.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  activeColor: Colors.blueGrey,
                  label: _getFontSizeLabel(currentFontSizeLevel, l10n),
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
                )
              ],
            ),
          ),

          ListTile(
            leading: Text(currentCountry.flagEmoji, style: const TextStyle(fontSize: 22)),
            title: Text(l10n.settingsCountryRegion),
            subtitle: Text("${currentCountry.countryName} · ${currentCountry.vatTerminology} ${(currentCountry.vatRate * 100).toStringAsFixed(0)}%"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _showCountryPicker(context, isDark),
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(l10n.settingsBusinessManagement, style: TextStyle(color: sectionColor, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.person_pin, color: Colors.indigo),
            title: Text(l10n.settingsMyBusinessInfo),
            subtitle: Text(l10n.settingsMyBusinessInfoSub),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MyBusinessPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.indigo),
            title: Text(l10n.settingsTaxScheduleSetup),
            subtitle: Text(l10n.settingsTaxScheduleSetupSub),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => TaxSetupPage()));
            },
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(l10n.menuDataManagement, style: TextStyle(color: sectionColor, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload, color: Colors.green),
            title: Text(l10n.settingsDataBackup),
            subtitle: Text(l10n.settingsDataBackupSub),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () async {
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
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined, color: Colors.blue),
            title: Text(l10n.settingsBackupFileDownload),
            subtitle: Text(l10n.settingsBackupFileDownloadSub),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () async {
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
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.orange),
            title: Text(l10n.settingsDataRestore),
            subtitle: Text(l10n.settingsDataRestoreSub),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () async {
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
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: Colors.indigo),
            title: Text(l10n.settingsTaxSettlementExcel),
            subtitle: Text(l10n.settingsTaxSettlementExcelSub),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () async {
              final transactions = await _transactionRepository.getTransactions();
              if (transactions.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.noDataToExport)),
                  );
                }
                return;
              }
              await _excelService.exportForAccounting(transactions);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.exportExcelSuccess)),
                );
              }
            },
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(l10n.settingsSupport, style: TextStyle(color: sectionColor, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline, color: Colors.amber),
            title: Text(l10n.settingsKakaoInquiry),
            subtitle: Text(l10n.settingsKakaoInquirySub),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _launchUrl(_kakaoOpenChatUrl),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: Colors.blue),
            title: Text(l10n.settingsEmailInquiry),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: _sendEmail,
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(l10n.settingsTermsAndPolicy, style: TextStyle(color: sectionColor, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.settingsTermsOfService),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _launchUrl(_termsUrl),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.settingsPrivacyPolicy),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _launchUrl(_privacyUrl),
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: Text(l10n.settingsOpenSourceLicense),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => showLicensePage(context: context, applicationName: "BizExpense", applicationVersion: _appVersion),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsAppVersion),
            trailing: Text(_appVersion, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _getFontSizeLabel(int level, AppLocalizations l10n) {
    switch (level) {
      case 1: return l10n.settingsFontSizeVerySmall;
      case 2: return l10n.settingsFontSizeSmall;
      case 3: return l10n.settingsFontSizeNormal;
      case 4: return l10n.settingsFontSizeLarge;
      case 5: return l10n.settingsFontSizeVeryLarge;
      default: return l10n.settingsFontSizeNormal;
    }
  }
}
