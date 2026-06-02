class CardModel {
  final String id;
  final String userId;
  final String nickname;
  final String companyCode;
  final String companyName;
  final String? lastFour;
  final String? connectorId;
  final DateTime? lastSyncedAt;
  final bool isActive;
  final DateTime createdAt;

  const CardModel({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.companyCode,
    required this.companyName,
    this.lastFour,
    this.connectorId,
    this.lastSyncedAt,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isConnected => connectorId != null && connectorId!.isNotEmpty;

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        nickname: json['nickname'] as String,
        companyCode: json['company_code'] as String,
        companyName: json['company_name'] as String,
        lastFour: json['last_four'] as String?,
        connectorId: json['connector_id'] as String?,
        lastSyncedAt: json['last_synced_at'] != null
            ? DateTime.tryParse(json['last_synced_at'] as String)
            : null,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'nickname': nickname,
        'company_code': companyCode,
        'company_name': companyName,
        'last_four': lastFour,
        'is_active': isActive,
      };
}
