class PromoCode {
  final String id;
  final String creditCode;
  final int nbCredits;
  final bool used;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  PromoCode({
    required this.id,
    required this.creditCode,
    required this.nbCredits,
    required this.used,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['_id'] ?? '',
      creditCode: json['credit_code'] ?? '',
      nbCredits: json['nb_credits'] ?? 0,
      used: json['used'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      userId: json['user_id'] is Map ? json['user_id']['_id'] ?? '' : json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'credit_code': creditCode,
      'nb_credits': nbCredits,
      'used': used,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
    };
  }
}
