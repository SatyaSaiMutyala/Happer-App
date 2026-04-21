// Model class for Happer Product Detail data from WebSocket
import 'package:happer_app/shared/models/happer_product.dart';

class HapperProductDetail {
  final String id;
  final String? buyUrl;
  final String? promoCodeWinner;
  final String? promoCodeLoser;
  final int state;
  final List<String> pictures;
  final List<String> usersList;
  final List<String> containers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> wishes;
  final bool happed;
  final List<HighlightBy> highlightBy;
  final DateTime? happDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String title;
  final Description description;
  final double price;
  final Brand brand;
  final double discountPercentage;
  final int v;
  final String? timer;
  final String? userId;
  final int? timerstamp;
  final String? country;
  
  // Additional fields for detail view
  final List<UserDetail> latestUsers;
  final int totalUsers;
  final int remainingTime;
  final bool isActive;
  final String productStatus;

  HapperProductDetail({
    required this.id,
    this.buyUrl,
    this.promoCodeWinner,
    this.promoCodeLoser,
    required this.state,
    required this.pictures,
    required this.usersList,
    required this.containers,
    required this.createdAt,
    required this.updatedAt,
    required this.wishes,
    required this.happed,
    required this.highlightBy,
    this.happDate,
    this.startDate,
    this.endDate,
    required this.title,
    required this.description,
    required this.price,
    required this.brand,
    required this.discountPercentage,
    required this.v,
    this.timer,
    this.userId,
    this.timerstamp,
    this.country,
    required this.latestUsers,
    required this.totalUsers,
    required this.remainingTime,
    required this.isActive,
    required this.productStatus,
  });

  factory HapperProductDetail.fromJson(Map<String, dynamic> json) {
    // Parse basic product information similar to HapperProduct
    var product = HapperProductDetail(
      id: json['_id'] ?? '',
      buyUrl: json['buy_url'],
      promoCodeWinner: json['promo_code_winner'],
      promoCodeLoser: json['promo_code_loser'],
      state: json['state'] ?? 0,
      pictures: json['pictures'] != null
          ? List<String>.from(json['pictures'])
          : [],
      usersList: json['users_list'] != null
          ? List<String>.from(json['users_list'])
          : [],
      containers: json['containers'] != null
          ? List<String>.from(json['containers'])
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      wishes: json['wishes'] != null
          ? List<String>.from(json['wishes'])
          : [],
      happed: json['happed'] ?? false,
      highlightBy: json['highlight_by'] != null
          ? List<HighlightBy>.from(
              json['highlight_by'].map((x) => HighlightBy.fromJson(x)))
          : [],
      happDate: json['happ_date'] != null
          ? DateTime.parse(json['happ_date'])
          : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      title: json['title'] ?? '',
      description: json['description'] != null
          ? Description.fromJson(json['description'])
          : Description(en: '', fr: ''),
      price: json['price']?.toDouble() ?? 0.0,
      brand: json['brand'] != null
          ? Brand.fromJson(json['brand'])
          : Brand(id: '', name: '',),
      discountPercentage: json['discount_percentage']?.toDouble() ?? 0.0,
      v: json['__v'] ?? 0,
      timer: json['timer'],
      userId: json['user_id'],
      timerstamp: json['timerstamp'],
      country: json['country'],
      
      // Parse additional detail-specific fields
      latestUsers: json['latest_users'] != null
          ? List<UserDetail>.from(
              json['latest_users'].map((x) => UserDetail.fromJson(x)))
          : [],
      totalUsers: json['total_users'] ?? 0,
      remainingTime: json['remaining_time'] ?? 0,
      isActive: json['is_active'] ?? true,
      productStatus: json['product_status'] ?? 'active',
    );
    
    return product;
  }
  
  // Create from HapperProduct to maintain backward compatibility
  factory HapperProductDetail.fromHapperProduct(HapperProduct product, {
    List<UserDetail> latestUsers = const [],
    int totalUsers = 0,
    int remainingTime = 30,
    bool isActive = true,
    String productStatus = 'active',
  }) {
    return HapperProductDetail(
      id: product.id,
      buyUrl: product.buyUrl,
      promoCodeWinner: product.promoCodeWinner,
      promoCodeLoser: product.promoCodeLoser,
      state: product.state,
      pictures: product.pictures,
      usersList: product.usersList,
      containers: product.containers,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      wishes: product.wishes,
      happed: product.happed,
      highlightBy: product.highlightBy,
      happDate: product.happDate,
      startDate: product.startDate,
      endDate: product.endDate,
      title: product.title,
      description: product.description,
      price: product.price,
      brand: product.brand,
      discountPercentage: product.discountPercentage,
      v: product.v,
      country: product.country,
      latestUsers: latestUsers,
      totalUsers: totalUsers,
      remainingTime: remainingTime,
      isActive: isActive,
      productStatus: productStatus,
    );
  }
  
  // Helper methods that were in HapperProduct
  String getDescription() {
    // Prefer English description, fall back to French or empty string
    if (description.en != null && description.en!.isNotEmpty) {
      return description.en!;
    } else if (description.fr != null && description.fr!.isNotEmpty) {
      return description.fr!;
    }
    return '';
  }

  String getBrandName() {
    return brand.name.isNotEmpty ? brand.name : "Unknown Brand";
  }

  String getFirstUserName() {
    if (usersList.isNotEmpty) {
      final user = usersList.first;
      if (user.contains('/')) {
        return user.split('/')[1];
      }
      return user;
    }
    return "No User";
  }
  
  // Get timer duration from the product
  int get timerDuration {
    // First try to get it from timerstamp
    if (timerstamp != null && timerstamp! > 0) {
      return timerstamp!;
    }
    
    // Then try to get it from timer string
    if (timer != null && timer!.isNotEmpty) {
      try {
        // Parse timer string (assuming format like "30s" or "1m")
        final regex = RegExp(r'(\d+)([ms])');
        final match = regex.firstMatch(timer!);
        
        if (match != null) {
          final value = int.parse(match.group(1) ?? "30");
          final unit = match.group(2);
          
          if (unit == 'm') {
            return value * 60; // Convert minutes to seconds
          }
          return value; // Seconds
        }
      } catch (e) {
        
      }
    }
    
    // Default to 30 seconds if no valid timer information
    return 30;
  }
  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'buy_url': buyUrl,
      'promo_code_winner': promoCodeWinner,
      'promo_code_loser': promoCodeLoser,
      'state': state,
      'pictures': pictures,
      'users_list': usersList,
      'containers': containers,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'wishes': wishes,
      'happed': happed,
      'highlight_by': highlightBy.map((x) => x.toJson()).toList(),
      'happ_date': happDate?.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'title': title,
      'description': description.toJson(),
      'price': price,
      'brand': brand.toJson(),
      'discount_percentage': discountPercentage,
      '__v': v,
      'timer': timer,
      'user_id': userId,
      'timerstamp': timerstamp,
      'country': country,
      'latest_users': latestUsers.map((x) => x.toJson()).toList(),
      'total_users': totalUsers,
      'remaining_time': remainingTime,
      'is_active': isActive,
      'product_status': productStatus,
    };
  }
}

// Model for user details in the product detail response
class UserDetail {
  final String id;
  final String username;
  final String? avatar;
  final DateTime? timestamp;
  final int? position;

  UserDetail({
    required this.id,
    required this.username,
    this.avatar,
    this.timestamp,
    this.position,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? 'Unknown',
      avatar: json['avatar'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : null,
      position: json['position'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
      'timestamp': timestamp?.toIso8601String(),
      'position': position,
    };
  }
}
