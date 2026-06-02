import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:url_launcher/url_launcher.dart';
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
                  '국가 / 지역 선택',
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("링크를 열 수 없습니다.")));
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: _encodeQueryParameters(<String, String>{
        'subject': '[BizExpense] 문의합니다',
        'body': '1. 문의 유형:\n2. 내용:\n\n(여기에 내용을 적어주세요)',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("기본 메일 앱을 찾을 수 없습니다.")));
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionColor = isDark ? Colors.grey[400] : Colors.blueGrey;

    final currentFontSizeLevel = ref.watch(fontSizeProvider);
    final currentCountry = ref.watch(countryConfigProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("설정"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text("화면 설정", style: TextStyle(color: sectionColor, fontWeight: FontWeight.bold)),
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
                    const Text("글자 크기", style: TextStyle(fontSize: 16)),
                    Text(
                      _getFontSizeLabel(currentFontSizeLevel), 
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
                  label: _getFontSizeLabel(currentFontSizeLevel),
                  onChanged: (value) {
                    
                    ref.read(fontSizeProvider.notifier).setFontSize(value.toInt());
                  },
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("작게", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("보통", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("크게", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
          
          ListTile(
            leading: Text(currentCountry.flagEmoji, style: const TextStyle(fontSize: 22)),
            title: const Text("국가 / 지역"),
            subtitle: Text("${currentCountry.countryName} · ${currentCountry.vatTerminology} ${(currentCountry.vatRate * 100).toStringAsFixed(0)}%"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _showCountryPicker(context, isDark),
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text("사업자 관리", style: TextStyle(color: sectionColor, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.person_pin, color: Colors.indigo),
            title: const Text("내 사업자 정보 수정"),
            subtitle: const Text("상호명, 사업자번호, 주소 등"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MyBusinessPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.indigo),
            title: const Text("세무 일정 설정"),
            subtitle: const Text("사업자 유형, 과세 유형 변경"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => TaxSetupPage()));
            },
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text("데이터 관리", style: TextStyle(color: sectionColor, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload, color: Colors.green),
            title: const Text("데이터 백업"),
            subtitle: const Text("클라우드에 자동 백업"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () async {
              final success = await _backupService.autoBackup();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? "백업이 완료되었습니다!" : "백업에 실패했습니다."),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined, color: Colors.blue),
            title: const Text("백업 파일 다운로드"),
            subtitle: const Text("로컬에 백업 파일 저장"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () async {
              final backupJson = await _backupService.createBackupFile();
              if (backupJson != null) {
                await Share.share(backupJson, subject: 'BizExpense 백업 파일');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("백업 파일을 공유했습니다.")),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("백업 파일 생성에 실패했습니다.")),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.orange),
            title: const Text("데이터 복원"),
            subtitle: const Text("백업 파일에서 데이터 복원"),
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
                          const SnackBar(content: Text("파일을 읽을 수 없습니다.")),
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
                          const SnackBar(content: Text("파일 경로를 찾을 수 없습니다.")),
                        );
                      }
                      return;
                    }
                    final file = File(path);
                    backupJson = await file.readAsString();
                  }
                  
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("데이터 복원"),
                      content: const Text("기존 데이터가 삭제되고 백업 데이터로 대체됩니다. 계속하시겠습니까?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("취소"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("복원", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm == true) {
                    final success = await _backupService.restoreFromBackup(backupJson);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? "복원이 완료되었습니다!" : "복원에 실패했습니다."),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("파일 읽기 실패: $e")),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: Colors.indigo),
            title: const Text("세무 정산용 엑셀"),
            subtitle: const Text("국세청 전자신고용 파일 생성"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () async {
              final transactions = await _transactionRepository.getTransactions();
              if (transactions.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("내보낼 데이터가 없습니다.")),
                  );
                }
                return;
              }
              await _excelService.exportForAccounting(transactions);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("세무 정산용 엑셀 파일이 생성되었습니다.")),
                );
              }
            },
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text("고객센터", style: TextStyle(color: sectionColor, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline, color: Colors.amber),
            title: const Text("카카오톡 1:1 문의"),
            subtitle: const Text("가장 빠르게 답변을 받을 수 있어요"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _launchUrl(_kakaoOpenChatUrl),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: Colors.blue),
            title: const Text("이메일 문의"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: _sendEmail,
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text("약관 및 정책", style: TextStyle(color: sectionColor, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text("서비스 이용약관"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _launchUrl(_termsUrl),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text("개인정보 처리방침"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _launchUrl(_privacyUrl),
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text("오픈소스 라이선스"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => showLicensePage(context: context, applicationName: "BizExpense", applicationVersion: _appVersion),
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("앱 버전"),
            trailing: Text(_appVersion, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _getFontSizeLabel(int level) {
    switch (level) {
      case 1: return "매우 작게";
      case 2: return "작게";
      case 3: return "보통";
      case 4: return "크게";
      case 5: return "매우 크게";
      default: return "보통";
    }
  }
}
