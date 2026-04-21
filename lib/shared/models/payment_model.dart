/// Payment model class to store payment information
class PaymentModel {
  final String? clientSecret;
  final String? customer;
  final String? ephemeralKey;
  final String? publishableKey;
  final String? paymentIntentId;
  final bool isSuccess;
  final String? errorMessage;

  PaymentModel({
    this.clientSecret,
    this.customer,
    this.ephemeralKey,
    this.publishableKey,
    this.paymentIntentId,
    this.isSuccess = false,
    this.errorMessage,
  });

  /// Create a PaymentModel from API response
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      clientSecret: json['client_secret'],
      customer: json['customer'],
      ephemeralKey: json['ephemeralKey'],
      publishableKey: json['publishableKey'],
      paymentIntentId: json['paymentIntentId'],
      isSuccess: json['success'] ?? false,
      errorMessage: json['error'],
    );
  }

  /// Create a success model
  factory PaymentModel.success({
    String? clientSecret,
    String? customer,
    String? ephemeralKey,
    String? publishableKey,
    String? paymentIntentId,
  }) {
    return PaymentModel(
      clientSecret: clientSecret,
      customer: customer,
      ephemeralKey: ephemeralKey,
      publishableKey: publishableKey,
      paymentIntentId: paymentIntentId,
      isSuccess: true,
    );
  }

  /// Create an error model
  factory PaymentModel.error(String message) {
    return PaymentModel(
      isSuccess: false,
      errorMessage: message,
    );
  }
  
  /// Convert the model to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'client_secret': clientSecret,
      'customer': customer,
      'ephemeralKey': ephemeralKey,
      'publishableKey': publishableKey,
      'paymentIntentId': paymentIntentId,
      'success': isSuccess,
      'error': errorMessage,
    };
  }
}
