import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/core/network/api_endpoints.dart';
import 'package:happer_app/features/profile/models/address_model.dart';

class AddressRepository {
  final ApiClient _client;

  AddressRepository([ApiClient? client]) : _client = client ?? ApiClient();

  Future<List<AddressModel>> getAllAddresses({int page = 1, int perPage = 20}) async {
    final response = await _client.get(
      ApiEndpoints.getAllAddresses,
      requiresAuth: true,
      queryParams: {'page': '$page', 'perPage': '$perPage'},
    );
    final outer = response['data'] as Map<String, dynamic>;
    final list = outer['data'] as List<dynamic>;
    return list
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AddressModel> addAddress(Map<String, dynamic> body) async {
    final response = await _client.post(
      ApiEndpoints.addAddress,
      body: body,
      requiresAuth: true,
    );
    return AddressModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<AddressModel> editAddress(String id, Map<String, dynamic> body) async {
    final response = await _client.put(
      ApiEndpoints.editAddress(id),
      body: body,
      requiresAuth: true,
    );
    return AddressModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteAddress(String id) async {
    await _client.delete(
      ApiEndpoints.deleteAddress(id),
      requiresAuth: true,
    );
  }
}
