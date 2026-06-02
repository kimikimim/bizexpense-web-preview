import 'package:intl/intl.dart';
import '../../features/transactions/data/transaction_model.dart';
import 'package:uuid/uuid.dart';

class TextParser {
  
  static bool _looksLikeCardSms(String text) {
    final hasWon = text.contains('원');
    final hasDigit = RegExp(r'\d').hasMatch(text);
    final hasKeyword = text.contains('승인') ||
        text.contains('사용') ||
        text.contains('취소') ||
        text.contains('카드');

    return hasWon && hasDigit && hasKeyword;
  }

  static int? _extractAmount(String text) {
    final amountRegex = RegExp(r'([\d,]+)\s*원');
    final matches = amountRegex.allMatches(text).toList();
    if (matches.isEmpty) return null;

    for (final match in matches.reversed) {
      final raw = match.group(1)!.replaceAll(',', '');
      final parsed = int.tryParse(raw);
      if (parsed == null) continue;

      if (parsed >= 100 && parsed <= 1000000000) {
        return parsed;
      }
    }
    return null;
  }

  static DateTime _extractDate(String text) {
    final now = DateTime.now();

    final pattern1 = RegExp(r'(\d{1,2})[/.](\d{1,2})\s+(\d{1,2}):(\d{2})');
    final m1 = pattern1.firstMatch(text);
    if (m1 != null) {
      final month = int.tryParse(m1.group(1)!) ?? now.month;
      final day = int.tryParse(m1.group(2)!) ?? now.day;
      final hour = int.tryParse(m1.group(3)!) ?? 0;
      final minute = int.tryParse(m1.group(4)!) ?? 0;
      return DateTime(now.year, month, day, hour, minute);
    }

    final pattern2 = RegExp(r'(\d{1,2})[/.](\d{1,2})');
    final m2 = pattern2.firstMatch(text);
    if (m2 != null) {
      final month = int.tryParse(m2.group(1)!) ?? now.month;
      final day = int.tryParse(m2.group(2)!) ?? now.day;
      return DateTime(now.year, month, day);
    }

    final pattern3 = RegExp(r'(\d{4})[.-](\d{1,2})[.-](\d{1,2})');
    final m3 = pattern3.firstMatch(text);
    if (m3 != null) {
      final year = int.tryParse(m3.group(1)!) ?? now.year;
      final month = int.tryParse(m3.group(2)!) ?? now.month;
      final day = int.tryParse(m3.group(3)!) ?? now.day;
      return DateTime(year, month, day);
    }

    return now;
  }

  static String _extractStoreName(String text) {
    
    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (lines.isEmpty) return '사용처 미상';

    final metaPattern = RegExp(
      r'(승인|사용|취소|일시불|할부|원|카드|잔액|누적|포인트|[0-9,]+원)',
    );

    final cleanedLines = lines
        .map((l) => l.replaceAll(RegExp(r'\[.*?\]'), '').trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final candidates = cleanedLines.where((line) {
      if (metaPattern.hasMatch(line)) return false; 
      if (line.length < 2) return false;
      if (line.length > 25) return false;
      return true;
    }).toList();

    String storeName;
    if (candidates.isNotEmpty) {
      storeName = candidates.first;
    } else {
      
      String s = text;
      s = s.replaceAll(RegExp(r'\[.*?\]'), '');
      s = s.replaceAll(RegExp(r'[\d,]+원'), '');
      s = s.replaceAll(RegExp(r'(\d{1,2})[/.](\d{1,2})'), '');
      s = s.replaceAll(RegExp(r'(승인|사용|취소|일시불|할부|Web발신)'), '');
      s = s.replaceAll('\n', ' ');
      s = s.trim();

      if (s.isEmpty) {
        storeName = '사용처 미상';
      } else {
        storeName = s;
      }
    }

    if (storeName.length > 20) {
      storeName = storeName.substring(0, 20);
    }
    if (storeName.length < 2) {
      storeName = '사용처 미상';
    }

    return storeName;
  }

  static TransactionModel? parse(String text) {
    try {
      final raw = text.trim();

      if (raw.length > 200) return null;

      if (raw.contains('{') || raw.contains('}') || raw.contains(';')) return null;

      if (!_looksLikeCardSms(raw)) return null;

      if (raw.contains('취소')) return null;

      final amount = _extractAmount(raw);
      if (amount == null) return null;

      final date = _extractDate(raw);

      final storeName = _extractStoreName(raw);

      String method = '카드(문자)';
      if (raw.contains('법인')) {
        method = '법인카드';
      } else if (raw.contains('체크') || raw.contains('개인')) {
        method = '개인카드';
      }

      return TransactionModel(
        id: const Uuid().v4(),
        userId: 'temp_user', 
        date: date,
        amount: amount,
        storeName: storeName,
        category: '미분류',
        method: method,
        receiptUrl: null,
        transactionType: 'expense', 
        accountId: 'ParsedSMS',
        isPaid: true,
      );
    } catch (e) {
      
      return null;
    }
  }
}
