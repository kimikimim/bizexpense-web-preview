import 'package:expense_pro/features/transactions/data/transaction_model.dart';

class SmsParserService {
  
  static final List<_CardPattern> _patterns = [
    
    _CardPattern(
      company: '삼성카드',
      pattern: RegExp(
        r'삼성카드.*?승인.*?\*(\d{4}).*?([\d,]+)원.*?([가-힣A-Za-z0-9\s]+?)\s+(\d{2}/\d{2})',
        dotAll: true,
      ),
      amountGroup: 2,
      storeGroup: 3,
    ),
    
    _CardPattern(
      company: 'KB국민카드',
      pattern: RegExp(
        r'국민카드.*?승인.*?\*(\d{4}).*?([\d,]+)원.*?([가-힣A-Za-z0-9\s]+)',
        dotAll: true,
      ),
      amountGroup: 2,
      storeGroup: 3,
    ),
    
    _CardPattern(
      company: '신한카드',
      pattern: RegExp(
        r'신한카드.*?승인.*?([\d,]+)원.*?([가-힣A-Za-z0-9\s]+)',
        dotAll: true,
      ),
      amountGroup: 1,
      storeGroup: 2,
    ),
    
    _CardPattern(
      company: '현대카드',
      pattern: RegExp(
        r'현대카드.*?승인.*?([\d,]+)원.*?([가-힣A-Za-z0-9\s]+)',
        dotAll: true,
      ),
      amountGroup: 1,
      storeGroup: 2,
    ),
    
    _CardPattern(
      company: '롯데카드',
      pattern: RegExp(
        r'롯데카드.*?승인.*?([\d,]+)원.*?([가-힣A-Za-z0-9\s]+)',
        dotAll: true,
      ),
      amountGroup: 1,
      storeGroup: 2,
    ),
    
    _CardPattern(
      company: '우리카드',
      pattern: RegExp(
        r'우리카드.*?승인.*?([\d,]+)원.*?([가-힣A-Za-z0-9\s]+)',
        dotAll: true,
      ),
      amountGroup: 1,
      storeGroup: 2,
    ),
    
    _CardPattern(
      company: '하나카드',
      pattern: RegExp(
        r'하나카드.*?승인.*?([\d,]+)원.*?([가-힣A-Za-z0-9\s]+)',
        dotAll: true,
      ),
      amountGroup: 1,
      storeGroup: 2,
    ),
    
    _CardPattern(
      company: 'NH농협카드',
      pattern: RegExp(
        r'농협카드.*?승인.*?([\d,]+)원.*?([가-힣A-Za-z0-9\s]+)',
        dotAll: true,
      ),
      amountGroup: 1,
      storeGroup: 2,
    ),
    
    _CardPattern(
      company: 'BC카드',
      pattern: RegExp(
        r'BC카드.*?승인.*?([\d,]+)원.*?([가-힣A-Za-z0-9\s]+)',
        dotAll: true,
      ),
      amountGroup: 1,
      storeGroup: 2,
    ),
    
    _CardPattern(
      company: '씨티카드',
      pattern: RegExp(
        r'씨티카드.*?승인.*?([\d,]+)원.*?([가-힣A-Za-z0-9\s]+)',
        dotAll: true,
      ),
      amountGroup: 1,
      storeGroup: 2,
    ),
    
    _CardPattern(
      company: '카드',
      pattern: RegExp(
        r'승인.*?([\d,]+)원.*?([가-힣A-Za-z0-9]{2,20})',
        dotAll: true,
      ),
      amountGroup: 1,
      storeGroup: 2,
    ),
  ];

  static ParsedCardTransaction? parse(String text, {String? sender}) {
    
    if (text.contains('취소') || text.contains('환불') || text.contains('결제취소')) {
      return null;
    }
    
    if (!text.contains('승인') && !text.contains('결제')) {
      return null;
    }

    for (final p in _patterns) {
      final match = p.pattern.firstMatch(text);
      if (match == null) continue;

      final amountStr = match.group(p.amountGroup)?.replaceAll(',', '') ?? '0';
      final amount = int.tryParse(amountStr) ?? 0;
      if (amount <= 0) continue;

      final storeName = match.group(p.storeGroup)?.trim() ?? '알 수 없음';

      return ParsedCardTransaction(
        amount: amount,
        storeName: _cleanStoreName(storeName),
        cardCompany: _detectCompany(text) ?? p.company,
        date: DateTime.now(),
      );
    }
    return null;
  }

  static String _cleanStoreName(String raw) {
    
    var name = raw
        .replaceAll(RegExp(r'\d{2}/\d{2}.*$'), '') 
        .replaceAll(RegExp(r'\d{2}:\d{2}.*$'), '') 
        .replaceAll(RegExp(r'[0-9,원]+$'), '')      
        .trim();
    if (name.length > 20) name = name.substring(0, 20);
    return name.isEmpty ? '알 수 없음' : name;
  }

  static String? _detectCompany(String text) {
    const companies = [
      '삼성카드', 'KB국민카드', '국민카드', '신한카드', '현대카드',
      '롯데카드', '우리카드', '하나카드', 'NH농협카드', '농협카드',
      'BC카드', '씨티카드',
    ];
    for (final c in companies) {
      if (text.contains(c)) return c == '국민카드' ? 'KB국민카드' : c == '농협카드' ? 'NH농협카드' : c;
    }
    return null;
  }

  static String guessCategory(String storeName) {
    final name = storeName.toLowerCase();
    if (RegExp(r'스타벅스|커피|카페|이디야|투썸|할리스|파스쿠찌|메가커피').hasMatch(name)) return '카페';
    if (RegExp(r'맥도날드|버거킹|롯데리아|kfc|치킨|피자|배민|쿠팡이츠|요기요|배달').hasMatch(name)) return '식비';
    if (RegExp(r'편의점|gs25|cu|세븐일레븐|이마트|홈플러스|코스트코|마켓컬리|올리브영').hasMatch(name)) return '식비';
    if (RegExp(r'지하철|버스|택시|카카오|우버|ktx|srt|고속버스').hasMatch(name)) return '교통';
    if (RegExp(r'주유|sk에너지|gs칼텍스|현대오일뱅크|에쓰오일').hasMatch(name)) return '교통';
    if (RegExp(r'병원|의원|약국|치과|한의원|약|클리닉').hasMatch(name)) return '의료';
    if (RegExp(r'학원|교육|yes24|교보문고|알라딘').hasMatch(name)) return '교육';
    if (RegExp(r'쿠팡|네이버|11번가|gmarket|옥션|무신사|musinsa').hasMatch(name)) return '쇼핑';
    if (RegExp(r'통신|kt|sk텔레콤|lg유플러스|알뜰폰').hasMatch(name)) return '통신';
    if (RegExp(r'호텔|모텔|숙박|에어비앤비|여관').hasMatch(name)) return '숙박';
    if (RegExp(r'골프|헬스|피트니스|수영|스포츠|볼링').hasMatch(name)) return '여가';
    return '기타';
  }
}

class _CardPattern {
  final String company;
  final RegExp pattern;
  final int amountGroup;
  final int storeGroup;
  const _CardPattern({
    required this.company,
    required this.pattern,
    required this.amountGroup,
    required this.storeGroup,
  });
}

class ParsedCardTransaction {
  final int amount;
  final String storeName;
  final String cardCompany;
  final DateTime date;

  const ParsedCardTransaction({
    required this.amount,
    required this.storeName,
    required this.cardCompany,
    required this.date,
  });

  TransactionModel toTransactionModel({required String userId}) {
    return TransactionModel(
      id: '',
      userId: userId,
      date: date,
      amount: amount,
      storeName: storeName,
      transactionType: 'expense',
      accountId: 'SMS_AUTO',
      isPaid: true,
      category: SmsParserService.guessCategory(storeName),
      method: cardCompany,
      isTaxDeductible: true,
      memo: 'SMS 자동 등록',
    );
  }
}
