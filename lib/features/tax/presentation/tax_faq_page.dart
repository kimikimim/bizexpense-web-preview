import 'package:flutter/material.dart';

class TaxFaqPage extends StatelessWidget {
  const TaxFaqPage({super.key});

  final List<Map<String, String>> _faqList = const [
    {
      "q": "세금을 줄일 수 있는 가장 확실한 방법은?",
      "a": "가장 기본은 '적격증빙' 수취입니다. 세금계산서, 카드전표, 현금영수증(지출증빙용)이 없는 지출은 비용으로 인정받기 어렵습니다.\n\n또한, 노란우산공제 가입이나 중소기업 특별세액감면 등 본인 업종에 맞는 공제 혜택을 놓치지 않는 것이 중요합니다."
    },
    {
      "q": "어떤 비용까지 경비 처리가 되나요?",
      "a": "원칙적으로 '사업과 직접 관련된 지출'만 가능합니다.\n\n- 식대: 직원/거래처와 식사 (혼밥은 불가)\n- 차량: 업무용 차량 유류비, 수리비\n- 기업업무추진비(구 접대비): 한도 내에서 인정, 건당 3만원 이상은 반드시 적격증빙 필수\n- 경조사비: 건당 20만원까지 (청첩장·부고 문자 캡처 보관 필수)\n\n단, 개인적인 병원비, 미용실, 가사 물품 구입비는 절대 불가능합니다.\n\n※ '접대비'는 2024년부터 '기업업무추진비'로 명칭이 변경됐습니다."
    },
    {
      "q": "직원을 처음 고용하는데 뭘 해야 하죠?",
      "a": "1. 근로계약서 작성 (필수)\n2. 4대보험 가입 (입사 다음 달 15일까지)\n3. 원천세 신고/납부 (매월 10일)\n\n일용직이나 프리랜서(3.3%)도 반드시 신고해야 나중에 비용 처리가 가능합니다."
    },
    {
      "q": "종합소득세 세율은 어떻게 되나요? (2024년 귀속 기준)",
      "a": "2024년 귀속분(2025년 5월 신고)부터 세율 구간이 일부 확대됐습니다.\n\n• 1,400만원 이하: 6%\n• 1,400만원 초과 ~ 5,000만원 이하: 15%\n• 5,000만원 초과 ~ 8,800만원 이하: 24%\n• 8,800만원 초과 ~ 1.5억원 이하: 35%\n• 1.5억원 초과 ~ 3억원 이하: 38%\n• 3억원 초과 ~ 5억원 이하: 40%\n• 5억원 초과 ~ 10억원 이하: 42%\n• 10억원 초과: 45%\n\n이전에는 6% 구간이 1,200만원 이하였는데, 2024년부터 1,400만원으로 넓어졌습니다."
    },
    {
      "q": "개인사업자 vs 법인, 언제 전환하나요?",
      "a": "보통 순이익(매출-비용)이 1.5억 원~2억 원을 넘어가면 법인이 세율 측면에서 유리해집니다.\n\n하지만 법인 돈은 마음대로 빼서 쓸 수 없다는 단점이 있으므로, 자금 융통성과 대외 신용도를 종합적으로 고려해야 합니다."
    },
    {
      "q": "장부 정리는 꼭 해야 하나요?",
      "a": "네, 필수입니다. 장부가 없으면 국세청이 정한 '추계신고(단순/기준경비율)'를 해야 하는데, 이는 실제 쓴 돈보다 비용 인정을 적게 받아 세금 폭탄을 맞을 확률이 높습니다.\n\n저희 앱(BizExpense)에 매일 기록하는 것만으로도 훌륭한 장부가 됩니다."
    },
    {
      "q": "세무 조사는 어떤 경우에 나오나요?",
      "a": "1. 동종 업계 대비 소득률이 현저히 낮을 때\n2. 적격증빙 없이 비용을 과다하게 처리했을 때\n3. 가족 명의로 인건비를 허위 계상했을 때\n\n투명하게 기록하고 증빙을 남기는 것이 최선의 예방책입니다."
    },
  ];

  @override
  Widget build(BuildContext context) {
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final contentColor = isDark ? Colors.grey[300] : Colors.black87;
    final contentBgColor = isDark ? Colors.white10 : Colors.grey[50];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("세무사님, 이게 궁금해요!"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _faqList.length + 1,
        separatorBuilder: (ctx, idx) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == _faqList.length) {
            return Container(
              margin: const EdgeInsets.only(top: 24, bottom: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey.shade300),
              ),
              child: const Column(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    "⚠️ 면책 조항",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "본 앱에서 제공하는 정보는 일반적인 세무 가이드이며, 개별 사업장의 상황에 따라 법적 적용이 달라질 수 있습니다.\n\n앱 내 정보를 활용한 신고 결과에 대해 법적 책임을 지지 않으므로, 중요한 의사결정은 반드시 전문 세무사와 상담하시기 바랍니다.",
                    style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final item = _faqList[index];
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Q",
                        style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['q']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 17, 
                          color: titleColor, 
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: contentBgColor, 
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['a']!,
                      style: TextStyle(
                        fontSize: 15, 
                        height: 1.6,
                        color: contentColor, 
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
