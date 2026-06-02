import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/card_model.dart';
import '../data/card_repository.dart';
import 'card_register_page.dart';
import 'card_import_page.dart';

class CardListPage extends StatefulWidget {
  const CardListPage({super.key});

  @override
  State<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> {
  final _repo = CardRepository();
  List<CardModel> _cards = [];
  bool _isLoading = true;
  Set<String> _syncingIds = {};

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    _cards = await _repo.getCards();
    setState(() => _isLoading = false);
  }

  Future<void> _syncCard(CardModel card) async {
    setState(() => _syncingIds.add(card.id));
    final count = await _repo.syncTransactions(cardId: card.id);
    await _loadCards();
    setState(() => _syncingIds.remove(card.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(count > 0
              ? '${card.nickname}: $count건 동기화 완료'
              : '${card.nickname}: 새로운 내역이 없습니다.'),
        ),
      );
    }
  }

  Future<void> _deleteCard(CardModel card) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('카드 연동 해제'),
        content: Text('${card.nickname} 연동을 해제할까요?\n기존 거래 내역은 유지됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('해제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _repo.deleteCard(card.id);
      _loadCards();
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = (String name) => kCardCompanies
        .firstWhere((c) => c.name == name,
            orElse: () => const CardCompanyInfo(
                name: '', code: '', color: Colors.grey, icon: Icons.credit_card))
        .color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('카드 관리'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_outlined),
            tooltip: '파일 가져오기 / SMS 설정',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CardImportPage()),
            ),
          ),
          if (_cards.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: '전체 동기화',
              onPressed: () async {
                final count = await _repo.syncTransactions();
                await _loadCards();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('전체 동기화 완료: $count건')),
                  );
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    final cardColor = company(card.companyName);
                    final isSyncing = _syncingIds.contains(card.id);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [cardColor, cardColor.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cardColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.credit_card,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(card.companyName,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                                const Spacer(),
                                if (card.isConnected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('연동됨',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(card.nickname,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            if (card.lastFour != null)
                              Text('**** **** **** ${card.lastFour}',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 13)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (card.lastSyncedAt != null)
                                  Text(
                                    '마지막 동기화: ${DateFormat('MM/dd HH:mm').format(card.lastSyncedAt!.toLocal())}',
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 11),
                                  )
                                else
                                  const Text('동기화 기록 없음',
                                      style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 11)),
                                const Spacer(),
                                if (card.isConnected)
                                  GestureDetector(
                                    onTap: isSyncing ? null : () => _syncCard(card),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: isSyncing
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white))
                                          : const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.sync,
                                                    color: Colors.white,
                                                    size: 14),
                                                SizedBox(width: 4),
                                                Text('동기화',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12)),
                                              ],
                                            ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _deleteCard(card),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('해제',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CardRegisterPage()),
          );
          if (result == true) _loadCards();
        },
        icon: const Icon(Icons.add),
        label: const Text('카드 추가'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.credit_card_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('연동된 카드가 없습니다.',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('카드를 추가하면 결제내역이 자동으로 등록됩니다.',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const CardRegisterPage()),
              );
              if (result == true) _loadCards();
            },
            icon: const Icon(Icons.add),
            label: const Text('카드 추가하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[800],
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
