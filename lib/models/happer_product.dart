// Model class for Happer Product data from WebSocket

/// Represents the different states of a product in the bidding process
/// 
/// AVAILABLE (0): Active bidding is happening, "HAPP" button is enabled, timer countdown shown (using time_to_rest from SharedPreferences), users can place bids
/// SOON (1): Pre-bidding state, "HAPP" button is disabled, shows "Starting soon" message, no active bidding
/// WIN (2): Bidding has ended, winner is determined, app shows appropriate screen based on result
/// EXPIRED (3): Contest ended without bids, no winner determined
enum ProductState {
  AVAILABLE, // 0: Active bidding state
  SOON,      // 1: Pre-bidding state
  WIN,       // 2: Bidding ended with a winner
  EXPIRED    // 3: Contest ended without bids
}

extension ProductStateExtension on ProductState {
  static ProductState fromInt(int state) {
    switch (state) {
      case 0:
        return ProductState.AVAILABLE;
      case 1:
        return ProductState.SOON;
      case 2:
        return ProductState.WIN;
      case 3:
        return ProductState.EXPIRED;
      default:
        throw ArgumentError('Invalid state value: $state');
    }
  }
  
  /// Returns the integer representation of the product state
  int toInt() {
    switch (this) {
      case ProductState.AVAILABLE: return 0;
      case ProductState.SOON: return 1;
      case ProductState.WIN: return 2;
      case ProductState.EXPIRED: return 3;
    }
  }
  
  /// Returns a user-friendly description of the product state
  String get description {
    switch (this) {
      case ProductState.AVAILABLE:
        return "Active bidding";
      case ProductState.SOON:
        return "Starting soon";
      case ProductState.WIN:
        return "Bidding ended";
      case ProductState.EXPIRED:
        return "Contest expired";
    }
  }
}

class HapperProduct {
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
  final String? userId;
  final String? country;
  final int? timerstamp; // Add timerstamp from backend
  final String? timer;   // Add timer (as String, since it's a timestamp in ms)

  HapperProduct({
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
    this.userId,
    this.country,
    this.timerstamp, // new
    this.timer,      // new
  });

  factory HapperProduct.fromJson(Map<String, dynamic> json) {
    return HapperProduct(
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
          : Description(fr: '', en: ''),
      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      brand: json['brand'] != null
          ? Brand.fromJson(json['brand'])
          : Brand(name: '', id: ''),
      discountPercentage: json['discount_percentage'] != null
          ? double.tryParse(json['discount_percentage'].toString()) ?? 0.0
          : 0.0,
      v: json['__v'] ?? 0,
      userId: json['user_id'],
      country: json['country'],
      timerstamp: json['timerstamp'], // new
      timer: json['timer'],           // new
    );
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
      'user_id': userId,
      'country': country,
      'timerstamp': timerstamp, // new
      'timer': timer,           // new
    };
  }

  // Utility method to get first image or placeholder URL
  String getFirstImageUrl() {
    return pictures.isNotEmpty ? pictures[0] : 'https://via.placeholder.com/120';
  }

  // Utility method to get description text in English or French
  String getDescription() {
    if (description.en != null && description.en!.isNotEmpty) {
      return description.en!;
    } else if (description.fr != null && description.fr!.isNotEmpty) {
      return description.fr!;
    }
    return 'No Description';
  }
  
  // Get the brand name or a default value
  String getBrandName() {
    return brand.name.isNotEmpty ? brand.name : 'Unknown Brand';
  }
  
  // Get first user from users list
String getFirstUserName() {
  if (usersList.isNotEmpty) {
    final first = usersList.first;
    if (first.contains('/')) {
      return first.split('/').last;
    }
    return first;
  }
  return '';
}
  
  /// Returns the product state as an enum value
  ProductState get productState => ProductStateExtension.fromInt(state);
  
  /// Checks if bidding is currently active for this product
  bool get isAvailableForBidding => state == 0; // AVAILABLE
  
  /// Checks if product is in pre-bidding state
  bool get isComingSoon => state == 1; // SOON
  
  /// Checks if bidding has ended with a winner
  bool get hasBiddingEnded => state == 2; // WIN
  
  /// Checks if the contest expired without bids
  bool get isExpired => state == 3; // EXPIRED
  
  /// Checks if the HAPP button should be enabled
  bool get isHappButtonEnabled => state == 0; // Only enabled for AVAILABLE state
  
  /// Returns the appropriate message based on product state
  String get stateMessage {
    switch (state) {
      case 0: return "Place your bid now!";
      case 1: return "Starting soon";
      case 2: return "Bidding ended";
      case 3: return "Contest expired";
      default: return "Unknown state";
    }
  }
  
  /// Calculates the time remaining for bidding (in seconds)
  int get timeRemainingSeconds {
    if (endDate == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 0;
    return endDate!.difference(now).inSeconds;
  }

  /// Returns the progress as a value between 0.0 and 1.0 based on timerstamp (0-100)
  double get progressPercent {
    if (timerstamp == null) return 0.0;
    if (timerstamp! <= 0) return 0.0;
    if (timerstamp! >= 100) return 1.0;
    return (timerstamp! / 100).clamp(0.0, 1.0);
  }

  /// Returns the remaining seconds for the countdown (max 30 seconds, 0 when timerstamp is 100)
  int get remainingSeconds {
    if (timerstamp == null) return 30;
    if (timerstamp! <= 0) return 30;
    if (timerstamp! >= 100) return 0;
    return ((30 * (100 - timerstamp!) / 100).round()).clamp(0, 30);
  }

  /// Returns the remaining duration for the countdown (as Duration)
  Duration get progressDuration => Duration(seconds: remainingSeconds);
}

class HighlightBy {
  final String id;
  final String? picture;
  final String? lastName;
  final String? firstName;

  HighlightBy({
    required this.id,
    this.picture,
    this.lastName,
    this.firstName,
  });

  factory HighlightBy.fromJson(Map<String, dynamic> json) {
    return HighlightBy(
      id: json['_id'] ?? '',
      picture: json['picture'],
      lastName: json['last_name'],
      firstName: json['first_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'picture': picture,
      'last_name': lastName,
      'first_name': firstName,
    };
  }
  
  // Get the full name
  String getFullName() {
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }
}

class Description {
  final String? fr;
  final String? en;

  Description({
    this.fr,
    this.en,
  });

  factory Description.fromJson(Map<String, dynamic> json) {
    return Description(
      fr: json['fr'],
      en: json['en'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fr': fr,
      'en': en,
    };
  }
}

class Brand {
  final String name;
  final String id;

  Brand({
    required this.name,
    required this.id,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }
}
