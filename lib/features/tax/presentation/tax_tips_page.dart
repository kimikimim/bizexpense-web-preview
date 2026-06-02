import 'package:flutter/material.dart';

class TaxTipsPage extends StatelessWidget {
  const TaxTipsPage({super.key});

  final List<Map<String, dynamic>> _tipCategories = const [
    {
      "category": "💳 경비 처리의 기본",
      "color": Colors.blue,
      "tips": [
        {
          "title": "경조사비는 '20만원' 짜리 영수증",
          "desc": "청첩장, 부고장 문자만 캡처해두면 건당 20만원까지 접대비로 인정됩니다."
        },
        {
          "title": "간이영수증은 '3만원' 까지만 (일반경비·접대비 모두 동일)",
          "desc": "3만원 이상 지출은 세금계산서·카드전표·현금영수증(지출증빙용) 중 하나의 적격증빙이 없으면 비용 전액이 불인정됩니다. 적격증빙 미수취 가산세(2%)도 별도로 부과되니 꼭 받으세요."
        },
        {
          "title": "내 밥값은 경비가 안 된다?",
          "desc": "1인 사장님의 '혼밥'은 원칙적으로 가사 경비라 불가능합니다. 단, 거래처와 먹으면 '접대비', 직원과 먹으면 '복리후생비'로 인정됩니다."
        },
      ]
    },
    {
      "category": "🚗 차량 / 유류비",
      "color": Colors.orange,
      "tips": [
        {
          "title": "운행일지 안 써도 1,500만원",
          "desc": "업무용 승용차는 운행일지를 안 써도 연간 1,500만원(감가상각 800+유지비 700)까지 비용 처리 가능합니다."
        },
        {
          "title": "경차/9인승 카니발은 혜택 2배",
          "desc": "1,000cc 이하 경차와 9인승 이상 승합차는 부가세 환급도 되고, 연간 비용 한도도 없습니다."
        },
      ]
    },
    {
      "category": "🏠 공과금 / 통신비",
      "color": Colors.green,
      "tips": [
        {
          "title": "핸드폰 요금도 털어 넣자",
          "desc": "사업자 명의가 아니어도, 통신사 고객센터에 '사업자 등록'을 하면 부가세 환급 및 경비 처리가 됩니다."
        },
        {
          "title": "전기/가스/수도요금",
          "desc": "한전이나 도시가스에 사업자번호를 등록해야 세금계산서를 발급받아 부가세 환급을 받습니다."
        },
      ]
    },
    {
      "category": "👨‍👩‍👧‍👦 인건비 / 가족",
      "color": Colors.purple,
      "tips": [
        {
          "title": "가족이 일을 도와준다면?",
          "desc": "실제로 근무했다면 급여를 주고 비용 처리가 가능합니다. 단, 통장 이체 내역 등 확실한 증빙이 필요합니다."
        },
        {
          "title": "4대보험 두루누리 지원",
          "desc": "직원 월급이 약 270만원 미만이라면, 국가에서 연금/고용보험료의 80%를 지원해줍니다."
        },
        {
          "title": "노란우산공제 소득공제 한도 (2025년 상향)",
          "desc": "2025년 1월 이후 납입분부터 공제 한도가 올랐습니다.\n• 사업소득 4천만원 이하: 연 600만원 (종전 500만원)\n• 4천만원 초과 ~ 1억원 이하: 연 400만원 (종전 300만원)\n• 1억원 초과: 200만원 (변동 없음)\n세금감면 효과가 크니 가입을 적극 추천합니다."
        },
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.blueGrey[800];
    final descColor = isDark ? Colors.grey[400] : Colors.grey[700];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("사장님 절세 족보"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tipCategories.length + 1,
        itemBuilder: (context, index) {
          if (index == _tipCategories.length) {
            return Container(
              margin: const EdgeInsets.only(top: 20, bottom: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Text(
                    "⚠️ 면책 조항",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "본 앱에서 제공하는 세무 정보는 일반적인 기준에 따른 참고용이며, 개별 사업장의 상황에 따라 달라질 수 있습니다.\n\n정확한 신고 및 절세 전략은 반드시 세무 전문가와 상담하시기 바랍니다.",
                    style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final category = _tipCategories[index];
          final List<Map<String, String>> tips = category['tips'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Row(
                  children: [
                    Icon(Icons.bookmark, color: category['color'], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      category['category'],
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: titleColor, 
                      ),
                    ),
                  ],
                ),
              ),
              
              ...tips.map((tip) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor, 
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      tip['title']!,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: titleColor),
                    ),
                  ),
                  subtitle: Text(
                    tip['desc']!,
                    style: TextStyle(color: descColor, fontSize: 13, height: 1.4),
                  ),
                ),
              )),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
