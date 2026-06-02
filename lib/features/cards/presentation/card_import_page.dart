import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/card_auto_import_service.dart';
import '../services/csv_import_service.dart';

class CardImportPage extends StatefulWidget {
  const CardImportPage({super.key});

  @override
  State<CardImportPage> createState() => _CardImportPageState();
}

class _CardImportPageState extends State<CardImportPage> with WidgetsBindingObserver {
  final _autoImport = CardAutoImportService();
  final _csvService = CsvImportService();

  bool _hasSmsPermission = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    
    if (state == AppLifecycleState.resumed) _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final sms = await Permission.sms.isGranted;
    setState(() => _hasSmsPermission = sms);
  }

  Future<void> _requestSmsPermission() async {
    final granted = await _autoImport.requestSmsPermission();
    setState(() => _hasSmsPermission = granted);
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('SMS 권한이 거부됐습니다. 설정에서 직접 허용해주세요.'),
          action: SnackBarAction(
            label: '설정',
            onPressed: openAppSettings,
          ),
        ),
      );
    }
  }

  Future<void> _importCsv() async {
    setState(() => _isImporting = true);
    try {
      final result = await _csvService.pickAndImport();
      if (result == null) return;

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('가져오기 완료'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _resultRow('저장됨', '${result.imported}건'),
                _resultRow('건너뜀', '${result.skipped}건'),
                if (result.failed > 0) _resultRow('실패', '${result.failed}건'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Widget _resultRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('결제내역 가져오기'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
          _SectionCard(
            icon: Icons.message_outlined,
            iconColor: Colors.green,
            title: 'SMS 자동 등록',
            subtitle: '카드 결제 문자를 받으면 자동으로 등록됩니다.',
            badge: _hasSmsPermission ? '활성화됨' : '비활성화',
            badgeColor: _hasSmsPermission ? Colors.green : Colors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• 삼성, KB국민, 신한, 현대, 롯데, 우리, 하나, 농협, BC 카드 지원\n'
                  '• 결제 문자 수신 시 자동으로 내역이 등록됩니다\n'
                  '• Android 전용',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _hasSmsPermission
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          label: const Text('SMS 권한 허용됨',
                              style: TextStyle(color: Colors.green)),
                        )
                      : ElevatedButton.icon(
                          onPressed: _requestSmsPermission,
                          icon: const Icon(Icons.sms),
                          label: const Text('SMS 권한 허용하기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _SectionCard(
            icon: Icons.notifications_outlined,
            iconColor: Colors.blue,
            title: '카드앱 알림 자동 등록',
            subtitle: '카드사 앱 푸시 알림으로 결제내역을 받는 경우',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• SMS 대신 카드앱 푸시 알림을 사용하는 경우\n'
                  '• 설정 → 알림 → 알림 접근에서 이 앱을 허용하세요\n'
                  '• Android 전용',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _autoImport.openNotificationSettings(),
                    icon: const Icon(Icons.settings),
                    label: const Text('알림 접근 설정 열기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _SectionCard(
            icon: Icons.upload_file_outlined,
            iconColor: Colors.purple,
            title: 'CSV/엑셀 파일 가져오기',
            subtitle: '카드사 홈페이지에서 내려받은 파일을 가져옵니다.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• 삼성, KB국민, 신한, 현대, 롯데, 우리, 하나, 농협 카드 지원\n'
                  '• iOS / Android 모두 사용 가능\n'
                  '• 각 카드사 앱 또는 홈페이지 → 이용내역 → 다운로드',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                
                _HowToDownloadExpander(),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isImporting ? null : _importCsv,
                    icon: _isImporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.upload_file),
                    label: Text(_isImporting ? '가져오는 중...' : '파일 선택하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(subtitle,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? Colors.grey).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(badge!,
                        style: TextStyle(
                            color: badgeColor ?? Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class _HowToDownloadExpander extends StatefulWidget {
  @override
  State<_HowToDownloadExpander> createState() => _HowToDownloadExpanderState();
}

class _HowToDownloadExpanderState extends State<_HowToDownloadExpander> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              const Text('카드사별 다운로드 방법 보기',
                  style: TextStyle(color: Colors.blue, fontSize: 13)),
              Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.blue,
                size: 18,
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          _guideItem('삼성카드', '삼성카드 앱 → 이용내역 → 엑셀 내려받기'),
          _guideItem('KB국민카드', 'KB Pay 앱 → 이용내역 → CSV 다운로드'),
          _guideItem('신한카드', '신한 SOL Pay → 이용내역 → 파일 저장'),
          _guideItem('현대카드', '현대카드 앱 → 이용내역 → 엑셀 다운로드'),
          _guideItem('롯데카드', '롯데카드 앱 → 이용내역 조회 → 저장'),
          _guideItem('하나카드', '하나카드 앱 → 이용내역 → 다운로드'),
          _guideItem('농협카드', 'NH스마트뱅킹 → 카드 이용내역 → 저장'),
        ],
      ],
    );
  }

  Widget _guideItem(String card, String guide) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(card,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12)),
            ),
            Expanded(
              child: Text(guide,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ),
      );
}
