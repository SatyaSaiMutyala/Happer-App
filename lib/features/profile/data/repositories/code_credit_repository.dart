import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/core/network/api_endpoints.dart';
import 'package:happer_app/features/profile/models/code_credit_model.dart';
import 'package:happer_app/features/profile/models/promo_code_model.dart';

class CodeCreditRepository {
  final ApiClient _client;

  CodeCreditRepository(this._client);

  /// Fetches the current user's credits and own promo code.
  Future<CodeCredit> getCodeCredits() async {
    final response = await _client.get(
      ApiEndpoints.fetchProfile,
      requiresAuth: true,
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};
    final credits = (data['credits'] as num?)?.toInt() ?? 0;
    final code = data['credit_code'] as String?;
    return CodeCredit(credits: credits, code: code);
  }

  /// Returns the current user's list of promo codes they received.
  Future<List<PromoCode>> fetchPromoCodes() async {
    final response = await _client.get(
      ApiEndpoints.getMyPromoCode,
      requiresAuth: true,
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(PromoCode.fromJson)
        .toList();
  }

  /// Applies a promo code entered by the user.
  Future<bool> verifyCode(String code) async {
    await _client.put(
      ApiEndpoints.verifyPromoCode,
      body: {'code': code},
      requiresAuth: true,
    );
    return true;
  }
}
