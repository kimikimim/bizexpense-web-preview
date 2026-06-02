import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_pro/core/utils/app_logger.dart';
import 'card_model.dart';

class CardRepository {
  final _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<CardModel>> getCards() async {
    try {
      final uid = _userId;
      if (uid == null) return [];
      final res = await _client
          .from('cards')
          .select()
          .eq('user_id', uid)
          .eq('is_active', true)
          .order('created_at', ascending: true);
      return (res as List)
          .map((e) => CardModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      appLogger.e('카드 목록 조회 실패', error: e);
      return [];
    }
  }

  Future<CardModel?> addCard(CardModel card) async {
    try {
      final res = await _client
          .from('cards')
          .insert(card.toJson())
          .select()
          .single();
      return CardModel.fromJson(res as Map<String, dynamic>);
    } catch (e) {
      appLogger.e('카드 추가 실패', error: e);
      return null;
    }
  }

  Future<bool> deleteCard(String cardId) async {
    try {
      await _client
          .from('cards')
          .update({'is_active': false})
          .eq('id', cardId);
      return true;
    } catch (e) {
      appLogger.e('카드 삭제 실패', error: e);
      return false;
    }
  }

  Future<bool> connectCard({
    required String cardId,
    required String loginId,
    required String loginPassword,
  }) async {
    try {
      final res = await _client.functions.invoke(
        'card-connect',
        body: {
          'cardId': cardId,
          'loginId': loginId,
          'loginPassword': loginPassword,
        },
      );
      final data = res.data as Map<String, dynamic>?;
      return data?['success'] == true;
    } catch (e) {
      appLogger.e('카드 연동 실패', error: e);
      return false;
    }
  }

  Future<int> syncTransactions({String? cardId}) async {
    try {
      final res = await _client.functions.invoke(
        'sync-card-transactions',
        body: cardId != null ? {'cardId': cardId} : {},
      );
      final data = res.data as Map<String, dynamic>?;
      return (data?['synced'] as int?) ?? 0;
    } catch (e) {
      appLogger.e('거래 동기화 실패', error: e);
      return 0;
    }
  }
}
