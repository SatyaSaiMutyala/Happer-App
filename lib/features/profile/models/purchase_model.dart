class PurchasedProduct {
  final String paymentReference;
  final DateTime? paidAt;
  final String currency;
  final ShippingAddress? shippingAddress;
  final PurchasedProductInfo? product;
  final PurchasedVariant? variant;
  final PurchasedAffiliate? affiliate;
  final PurchasedBrand? brand;
  final String orderId;
  final String cartItemId;
  final int quantity;
  final double unitPrice;
  final double? compareAtPrice;
  final double promoPercent;
  final double discount;
  final double shippingPrice;
  final double total;
  final String? invoiceUrl;

  /// Order/delivery status (e.g. confirmed / shipped / delivered). Parsed
  /// defensively from several possible keys — see [fromJson].
  final String orderStatus;

  /// Delivery/tracking link shown by the "LIEN LIVRAISON" button.
  final String? deliveryLink;

  PurchasedProduct({
    required this.paymentReference,
    this.paidAt,
    required this.currency,
    this.shippingAddress,
    this.product,
    this.variant,
    this.affiliate,
    this.brand,
    required this.orderId,
    required this.cartItemId,
    required this.quantity,
    required this.unitPrice,
    this.compareAtPrice,
    required this.promoPercent,
    required this.discount,
    required this.shippingPrice,
    required this.total,
    this.invoiceUrl,
    required this.orderStatus,
    this.deliveryLink,
  });

  factory PurchasedProduct.fromJson(Map<String, dynamic> json) {
    return PurchasedProduct(
      paymentReference: json['payment_reference'] as String? ?? '',
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'] as String)
          : null,
      currency: json['currency'] as String? ?? 'EUR',
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddress.fromJson(
              json['shipping_address'] as Map<String, dynamic>)
          : null,
      product: json['product_id'] != null
          ? PurchasedProductInfo.fromJson(
              json['product_id'] as Map<String, dynamic>)
          : null,
      variant: json['variant_id'] != null
          ? PurchasedVariant.fromJson(
              json['variant_id'] as Map<String, dynamic>)
          : null,
      affiliate: json['affiliate_id'] != null
          ? PurchasedAffiliate.fromJson(
              json['affiliate_id'] as Map<String, dynamic>)
          : null,
      brand: json['brand_id'] != null
          ? PurchasedBrand.fromJson(json['brand_id'] as Map<String, dynamic>)
          : null,
      orderId: json['order_id'] as String? ?? '',
      cartItemId: json['cart_item_id'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: ((json['unit_price'] as num?) ?? 0).toDouble(),
      compareAtPrice: json['compare_at_price'] != null
          ? (json['compare_at_price'] as num).toDouble()
          : null,
      promoPercent: ((json['promo_percent'] as num?) ?? 0).toDouble(),
      discount: ((json['discount'] as num?) ?? 0).toDouble(),
      shippingPrice: ((json['shipping_price'] as num?) ?? 0).toDouble(),
      total: ((json['total'] as num?) ?? 0).toDouble(),
      invoiceUrl: json['invoice_url'] as String? ?? json['invoice_link'] as String?,
      // Order/delivery status — try the likely keys (confirm exact key against
      // the live response).
      orderStatus: (json['order_status'] ??
              json['delivery_status'] ??
              json['status'] ??
              '') as String,
      // Delivery/tracking link for the "LIEN LIVRAISON" button.
      deliveryLink: (json['delivery_link'] ??
          json['delivery_url'] ??
          json['tracking_url'] ??
          json['tracking_link'] ??
          json['shipping_link']) as String?,
    );
  }

  String get displayImage {
    if (variant?.images.isNotEmpty == true) return variant!.images.first;
    return product?.productImage ?? '';
  }

  double get displayPrice => unitPrice;
  double? get displayCompareAtPrice => compareAtPrice;
}

class ShippingAddress {
  final String firstName;
  final String lastName;
  final String streetAddress;
  final String postalCode;
  final String city;
  final String email;
  final String mobileNumber;

  ShippingAddress({
    required this.firstName,
    required this.lastName,
    required this.streetAddress,
    required this.postalCode,
    required this.city,
    required this.email,
    required this.mobileNumber,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      streetAddress: json['street_address'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      city: json['city'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobileNumber: json['mobile_number'] as String? ?? '',
    );
  }
}

class PurchasedProductInfo {
  final String id;
  final String name;
  final String productImage;
  final String productUrl;
  final String status;

  PurchasedProductInfo({
    required this.id,
    required this.name,
    required this.productImage,
    required this.productUrl,
    required this.status,
  });

  factory PurchasedProductInfo.fromJson(Map<String, dynamic> json) {
    return PurchasedProductInfo(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      productImage: (json['product_image'] as String? ?? '').trim(),
      productUrl: json['product_url'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class PurchasedVariant {
  final String id;
  final double price;
  final List<String> images;
  final String? size;

  PurchasedVariant({
    required this.id,
    required this.price,
    required this.images,
    this.size,
  });

  factory PurchasedVariant.fromJson(Map<String, dynamic> json) {
    return PurchasedVariant(
      id: json['_id'] as String? ?? '',
      price: ((json['price'] as num?) ?? 0).toDouble(),
      images: (json['images'] as List<dynamic>? ?? []).cast<String>(),
      size: (json['size'] ?? json['variant_size'] ?? json['option']) as String?,
    );
  }
}

class PurchasedAffiliate {
  final String id;
  final String username;
  final String? profileImage;

  PurchasedAffiliate({
    required this.id,
    required this.username,
    this.profileImage,
  });

  factory PurchasedAffiliate.fromJson(Map<String, dynamic> json) {
    return PurchasedAffiliate(
      id: json['_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      profileImage: json['profile_image'] as String?,
    );
  }
}

class PurchasedBrand {
  final String id;
  final String name;
  final String? picture;

  PurchasedBrand({
    required this.id,
    required this.name,
    this.picture,
  });

  factory PurchasedBrand.fromJson(Map<String, dynamic> json) {
    return PurchasedBrand(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      picture: json['picture'] as String?,
    );
  }
}
