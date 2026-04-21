class WonProduct {
  final String id;
  final String brand;
  final String brandId;
  final String title;
  final Map<String, String> description;
  final double priceOriginal;
  final double? pricePromo;
  final List<String> pictures;
  final String winnerName;
  final String winnerId;
  final DateTime? winAt;
  final DateTime startDate;
  final DateTime endDate;
  final String? timer;
  final int? timerStamp;
  final bool happed;
  final String? buyUrl;
  final String? promoCodeWinner;
  final int state;
  final DateTime createdAt;
  final DateTime updatedAt;

  WonProduct({
    required this.id,
    required this.brand,
    required this.brandId,
    required this.title,
    required this.description,
    required this.priceOriginal,
    this.pricePromo,
    required this.pictures,
    required this.winnerName,
    required this.winnerId,
    this.winAt,
    required this.startDate,
    required this.endDate,
    this.timer,
    this.timerStamp,
    required this.happed,
    this.buyUrl,
    this.promoCodeWinner,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getter to get the first image URL or empty string if none
  String get imageURL => pictures.isNotEmpty ? pictures[0] : '';

  // Calculate promo price if discount percentage is available
  double? get calculatedPromoPrice {
    if (pricePromo != null) {
      return pricePromo;
    }
    return null;
  }

  factory WonProduct.fromJson(Map<String, dynamic> json) {
    // Handle the brand which is an object in the API response
    final brandMap = json['brand'] as Map<String, dynamic>?;
    final String brandName = brandMap != null ? brandMap['name'] ?? '' : '';
    final String brandId = brandMap != null ? brandMap['id'] ?? '' : '';

    // Handle description which is an object with language keys
    final Map<String, dynamic>? descriptionMap = json['description'] as Map<String, dynamic>?;
    final Map<String, String> description = descriptionMap != null 
      ? Map<String, String>.fromEntries(
          descriptionMap.entries.map((e) => MapEntry(e.key, e.value.toString()))
        )
      : {'en': '', 'fr': ''};

    // Get the winner information from users_list if available
    String winnerId = '';
    String winnerName = 'You';
    
    if (json['users_list'] != null && (json['users_list'] as List).isNotEmpty) {
      final String userInfo = (json['users_list'] as List).first.toString();
      final parts = userInfo.split('/');
      if (parts.length > 1) {
        winnerId = parts[0];
        winnerName = parts[1];
      }
    }

    // Handle dates
    DateTime? winAt;
    if (json['win_at'] != null) {
      try {
        winAt = DateTime.parse(json['win_at'].toString());
      } catch (e) {
        winAt = null;
      }
    }

    DateTime startDate = DateTime.now();
    if (json['start_date'] != null) {
      try {
        startDate = DateTime.parse(json['start_date'].toString());
      } catch (e) {
        // Keep default value
      }
    }

    DateTime endDate = DateTime.now().add(Duration(days: 7));
    if (json['end_date'] != null) {
      try {
        endDate = DateTime.parse(json['end_date'].toString());
      } catch (e) {
        // Keep default value
      }
    }

    DateTime createdAt = DateTime.now();
    if (json['created_at'] != null) {
      try {
        createdAt = DateTime.parse(json['created_at'].toString());
      } catch (e) {
        // Keep default value
      }
    }

    DateTime updatedAt = DateTime.now();
    if (json['updated_at'] != null) {
      try {
        updatedAt = DateTime.parse(json['updated_at'].toString());
      } catch (e) {
        // Keep default value
      }
    }

    // Calculate promo price if discount percentage available
    double? promoPrice;
    if (json['discount_percentage'] != null && json['discount_percentage'] is num) {
      final double discountPercentage = (json['discount_percentage'] as num).toDouble();
      final double originalPrice = (json['price'] ?? 0).toDouble();
      if (discountPercentage > 0) {
        promoPrice = originalPrice - (originalPrice * discountPercentage / 100);
      }
    }

    return WonProduct(
      id: json['_id'] ?? '',
      brand: brandName,
      brandId: brandId,
      title: json['title'] ?? '',
      description: description,
      priceOriginal: (json['price'] ?? 0).toDouble(),
      pricePromo: promoPrice,
      pictures: json['pictures'] != null ? List<String>.from(json['pictures']) : [],
      winnerName: winnerName,
      winnerId: winnerId,
      winAt: winAt,
      startDate: startDate,
      endDate: endDate,
      timer: json['timer']?.toString(),
      timerStamp: json['timerstamp'] != null ? int.tryParse(json['timerstamp'].toString()) : null,
      happed: json['happed'] == true,
      buyUrl: json['buy_url']?.toString() ?? '',
      promoCodeWinner: json['promo_code_winner']?.toString() ?? '',
      state: (json['state'] ?? 0) as int,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
