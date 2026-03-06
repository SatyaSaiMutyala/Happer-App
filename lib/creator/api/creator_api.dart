import 'dart:convert';

import 'package:happer_app/creator/model/creator_model.dart';
import 'package:happer_app/creator/model/items_model.dart';

import 'package:happer_app/webservices/auth_service.dart';
import 'package:happer_app/webservices/websocket_client.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatorApiService {
    static const String baseUrl = 'https://newapi.happer.fr/';

  // static const String baseUrl =
  //     'https://happer-production.francecentral.cloudapp.azure.com/'; // Corrected API base URL
  final String token; // Pass the token when initializing the service

  CreatorApiService({required this.token});

  Future<String> _getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token)) {
    
      final authService = AuthService();
      final refreshed = await authService.refreshToken();
      if (refreshed) {
        token = prefs.getString('token');
        
      } else {
   
        throw Exception('Failed to refresh token');
      }
    }

    return token!;
  }

  Future<dynamic> fetchSelfieDetails(String selfieId) async {
    final token = await _getValidToken();

    final url = Uri.parse('${baseUrl}api/selfies/$selfieId');

    final response = await http.get(url, headers: {'Authorization': token});

   

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } catch (e) {
       
        throw Exception('Failed to parse response');
      }
    } else {
      
      throw Exception('Failed to load selfie details');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCreatorProductDetails(
    String categoryId,
  ) async {
    final token = await _getValidToken();

    final url = Uri.parse(
      '${baseUrl}api/selfies/influencer?category=$categoryId&page=1&validated=VALIDATED&country=',
    );

    final response = await http.get(url, headers: {'Authorization': token});



    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        return data
            .map((selfie) {
              final items = selfie['items_id'] as List<dynamic>? ?? [];
              return items.map((item) {
                final product = item['item'] ?? {};
                return {
                  'imageUrl':
                      (product['pictures'] as List<dynamic>?)?.first ?? '',
                  'price':
                      product['promo_percent'] != null
                          ? '${product['promo_percent']}% OFF'
                          : 'Price not available',
                  'name': product['name'] ?? 'Unknown',
                  'created_at':
                      product['created_at'] ?? DateTime.now().toIso8601String(),
                };
              }).toList();
            })
            .expand((x) => x)
            .toList(); // Flatten the list of lists
      } else {
        throw Exception('No data found in the response.');
      }
    } else {
      throw Exception('Failed to load selfie and category details');
    }
  }

  Future<CreatorModel> getSelfieById(String selfieId) async {
    final url = '${baseUrl}api/selfies/$selfieId';

    // Ensure the token is valid and non-null
    if (token.isEmpty) {
      throw Exception('Token is missing or invalid');
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': token ?? ''},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return CreatorModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch selfie details');
    }
  }

  Future<void> postLike(String selfieId) async {
    final token = await _getValidToken();

    final url = Uri.parse('${baseUrl}api/likes');
    final body = json.encode({'selfie_id': selfieId});

    final response = await http.post(
      url,
      headers: {'Authorization': token, 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
    
    } else {
   
      throw Exception('Failed to like selfie');
    }
  }

  Future<void> postDisLike(String selfieId) async {
    final token = await _getValidToken();

    final url = Uri.parse('${baseUrl}api/likes/user');
    final body = json.encode({'selfie_id': selfieId});

    final response = await http.delete(
      url,
      headers: {'Authorization': token, 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      
    } else {
   
      throw Exception('Failed to dislike selfie');
    }
  }

  Future<void> likeSelfie(String selfieId) async {
    final token = await _getValidToken();

    final url = Uri.parse('${baseUrl}api/selfies/$selfieId/like');

    final response = await http.post(
      url,
      headers: {'Authorization': token, 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      
    } else {
      
      throw Exception('Failed to like selfie');
    }
  }

  Future<void> dislikeSelfie(String selfieId) async {
    final token = await _getValidToken();

    final url = Uri.parse('${baseUrl}api/selfies/$selfieId/unlike');

    final response = await http.post(
      url,
      headers: {'Authorization': token, 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      
    } else {
   
      throw Exception('Failed to dislike selfie');
    }
  }

  Future<List<dynamic>> fetchDiscover({required int page}) async {
    final token = await _getValidToken();

    final url = Uri.parse('${baseUrl}api/selfies?page=$page');

    final response = await http.get(url, headers: {'Authorization': token});

 

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } catch (e) {
      
        throw Exception('Failed to parse response');
      }
    } else {
     
      throw Exception('Failed to load selfies');
    }
  }

  Future<List<dynamic>> fetchInfluencerSelfies({required int page}) async {
    final token = await _getValidToken();

    final url = Uri.parse('${baseUrl}api/selfies/influencer?page=$page');

    final response = await http.get(url, headers: {'Authorization': token});

  

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } catch (e) {
       
        throw Exception('Failed to parse response');
      }
    } else {
     
      throw Exception('Failed to load influencer selfies');
    }
  }

Future<List<dynamic>> fetchInfluencerSelfiesWithSearch({
  required int page,
  required String searchTerm,
}) async {
  final token = await _getValidToken();

  final url = Uri.parse(
    '${baseUrl}api/selfies/influencer?page=$page&searchTerm=$searchTerm',
  );

  final response = await http.get(url, headers: {'Authorization': token});

  if (response.statusCode == 200) {
    try {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } catch (e) {
      throw Exception('Failed to parse response');
    }
  } else {
    throw Exception('Failed to load influencer selfies');
  }
}
  Future<ItemsModel> fetchItemDetails(String itemId) async {
    final token = await _getValidToken();

    final url = Uri.parse('${baseUrl}api/items/$itemId');

    final response = await http.get(url, headers: {'Authorization': token});



    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        return ItemsModel.fromJson(data); // Parse the response to ItemsModel
      } catch (e) {
       
        throw Exception('Failed to parse response');
      }
    } else {
    
      throw Exception('Failed to load item details');
    }
  }

  Future<Product> fetchProductDetails(String productId) async {
    final token = await _getValidToken();
print("checking for url  ${baseUrl}api/products/$productId");
    final url = Uri.parse('${baseUrl}api/products/$productId');

    final response = await http.get(url, headers: {'Authorization': token});

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data); // Parse the response to Product model
      } catch (e) {
        
        throw Exception('Failed to parse product details');
      }
    } else {
     
      throw Exception('Failed to fetch product details');
    }
  }

  Future<List<dynamic>> fetchMySelfies() async {
    final token = await _getValidToken();

    final url = Uri.parse('${baseUrl}api/selfies/me');

    final response = await http.get(url, headers: {'Authorization': token});



    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } catch (e) {

        throw Exception('Failed to parse my selfies response');
      }
    } else {

      throw Exception('Failed to load my selfies');
    }
  }

  Future<List<ItemsModel>> fetchBrandItems(String brandId) async {
    final token = await _getValidToken();

    final url = Uri.parse('${baseUrl}api/items/brand-items?brand_id=$brandId');

    final response = await http.get(url, headers: {'Authorization': token});

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ItemsModel.fromJson(item)).toList();
      } catch (e) {
        throw Exception('Failed to parse brand items response');
      }
    } else {
      throw Exception('Failed to load brand items');
    }
  }

//     Future<BrandResponse> fetchBrandAllItems(String brandId) async {
//     final token = await _getValidToken();

//     final url = Uri.parse('${baseUrl}api/items/brand-items?brand_id=$brandId');

//     final response = await http.get(url, headers: {'Authorization': token});

//     if (response.statusCode == 200) {
//       try {
//         final  data = json.decode(response.body);
//         return BrandResponse.fromJson(data);
//       } catch (e) {
//         throw Exception('Failed to parse brand items response');
//       }
//     } else {
//       throw Exception('Failed to load brand items');
//     }
//   }


Future<BrandResponse> fetchBrandAllItems(String brandId, {int page = 1, int limit = 10}) async {
  final token = await _getValidToken();
  print('Fetching brand items for brandId in function second: $brandId');

  // Add pagination parameters
  final url = Uri.parse('${baseUrl}api/items/brand-items?brand_id=$brandId&page=$page&limit=$limit');

  final response = await http.get(url, headers: {'Authorization': token});

  if (response.statusCode == 200) {
    try {
      final List<dynamic> data = json.decode(response.body);
      return BrandResponse.fromJson(data);
    } catch (e) {
      print('Error parsing response: $e');
      throw Exception('Failed to parse brand items response');
    }
  } else {
    print('Failed with status code: ${response.statusCode}');
    throw Exception('Failed to load brand items');
  }
}

}
