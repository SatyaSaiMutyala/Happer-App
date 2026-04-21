import 'dart:async';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:happer_app/features/creator/api/cart_api.dart';
import 'package:happer_app/features/creator/models/cart_model.dart';
import 'package:happer_app/features/creator/models/address_model.dart' as address_model;
import 'package:happer_app/features/dashboard/screens/dashboard_screen.dart';

import 'package:happer_app/features/profile/api/profile_api.dart';
import 'package:happer_app/features/profile/screens/my_purchases_screen.dart';
import 'package:happer_app/core/services/payment_service.dart';
import 'package:happer_app/core/network/stripe_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressScreen extends StatefulWidget {
  final String cartId;

  AddressScreen({required this.cartId});

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _isLoading = true;
  bool _isProcessingPayment = false;
  bool _useProfileAddress = false;
  bool _useProfileShippingAddress = false;
  bool _useProfileBillingAddress = false;
  Data? _cartData;
  Map<String, dynamic>? _profileAddress;
  bool _mounted = true;
  final PaymentService _paymentService = PaymentService();

  // Text controllers for shipping address
  final TextEditingController _shippingNameController = TextEditingController();
  final TextEditingController _shippingFirstNameController =
      TextEditingController();
  final TextEditingController _shippingAddressController =
      TextEditingController();
  final TextEditingController _shippingPostalController =
      TextEditingController();
  final TextEditingController _shippingCityController = TextEditingController();
  final TextEditingController _shippingEmailController =
      TextEditingController();
  final TextEditingController _shippingPhoneController =
      TextEditingController();

  // Text controllers for billing address
  final TextEditingController _billingNameController = TextEditingController();
  final TextEditingController _billingFirstNameController =
      TextEditingController();
  final TextEditingController _billingAddressController =
      TextEditingController();
  final TextEditingController _billingPostalController =
      TextEditingController();
  final TextEditingController _billingCityController = TextEditingController();
  final TextEditingController _billingEmailController = TextEditingController();
  final TextEditingController _billingPhoneController = TextEditingController();

  // Payment-related state
  String? _customerId;
  String? _ephemeralKey;
  String? _clientSecret;
  String? _publishableKey;

  bool _isButtonEnabled = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.cartId == 'profile') {
      if (_mounted) {
        setState(() => _isLoading = false);
      }
    } else {
      _fetchCartDetails();
      _loadProfileAddress();
    }

    // Add listeners to all controllers for robust validation
    _shippingNameController.addListener(_checkFieldsFilled);
    _shippingFirstNameController.addListener(_checkFieldsFilled);
    _shippingAddressController.addListener(_checkFieldsFilled);
    _shippingPostalController.addListener(_checkFieldsFilled);
    _shippingCityController.addListener(_checkFieldsFilled);
    _shippingEmailController.addListener(_checkFieldsFilled);
    _shippingPhoneController.addListener(_checkFieldsFilled);
    _billingNameController.addListener(_checkFieldsFilled);
    _billingFirstNameController.addListener(_checkFieldsFilled);
    _billingAddressController.addListener(_checkFieldsFilled);
    _billingPostalController.addListener(_checkFieldsFilled);
    _billingCityController.addListener(_checkFieldsFilled);
    _billingEmailController.addListener(_checkFieldsFilled);
    _billingPhoneController.addListener(_checkFieldsFilled);

    _checkFieldsFilled(); // initial check
  }

  void _checkFieldsFilled() {
    setState(() {
      _isButtonEnabled = true;
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _shippingNameController.dispose();
    _shippingFirstNameController.dispose();
    _shippingAddressController.dispose();
    _shippingPostalController.dispose();
    _shippingCityController.dispose();
    _shippingEmailController.dispose();
    _shippingPhoneController.dispose();

    _billingNameController.dispose();
    _billingFirstNameController.dispose();
    _billingAddressController.dispose();
    _billingPostalController.dispose();
    _billingCityController.dispose();
    _billingEmailController.dispose();
    _billingPhoneController.dispose();

    _mounted = false;
    super.dispose();
  }

  Future<void> _fetchCartDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found. Please log in again.');
      }

      final CartApi cartApi = CartApi(token: token);
      final cartModel = await cartApi.getCartDetails();

      if (_mounted) {
        setState(() {
          _cartData = cartModel.data;
          _isLoading = false;

          // Initialize shipping address controllers
          // _shippingNameController.text = _cartData?.shippingAddress?.name ?? '';
          // _shippingFirstNameController.text =
          //     _cartData?.shippingAddress?.name ?? '';
          // _shippingAddressController.text =
          //     _cartData?.shippingAddress?.address ?? '';
          // _shippingPostalController.text =
          //     _cartData?.shippingAddress?.zip ?? '';
          // _shippingCityController.text = _cartData?.shippingAddress?.city ?? '';
          // _shippingPhoneController.text =
          //     _cartData?.shippingAddress?.phone ?? '';

          // Billing controllers fallback
          // _billingNameController.text = _cartData?.billingAddress?.name ??
          //     _cartData?.shippingAddress?.name ??
          //     '';
          // _billingFirstNameController.text = _cartData?.billingAddress?.name ??
          //     _cartData?.shippingAddress?.name ??
          //     '';
          // _billingAddressController.text = _cartData?.billingAddress?.address ??
          //     _cartData?.shippingAddress?.address ??
          //     '';
          // _billingPostalController.text = _cartData?.billingAddress?.zip ??
          //     _cartData?.shippingAddress?.zip ??
          //     '';
          // _billingCityController.text = _cartData?.billingAddress?.city ??
          //     _cartData?.shippingAddress?.city ??
          //     '';
          // _billingPhoneController.text = _cartData?.billingAddress?.phone ??
          //     _cartData?.shippingAddress?.phone ??
          //     '';
        });
        _checkFieldsFilled();
      }
    } catch (e) {
      debugPrint('Error fetching cart details: $e');
      if (_mounted) {
        _showErrorSnackbar('Could not load cart details. Please try again.');
      }
    }
  }

  Future<void> _loadProfileAddress() async {
    try {
      final profileApiService = ProfileApiService();
      final userData = await profileApiService.fetchCurrentUserProfile();

      if (_mounted) {
        setState(() {
          _profileAddress = userData;

          // Auto-fill shipping if profile has address data
          final hasAddress = (userData['address'] ?? '').toString().trim().isNotEmpty ||
              (userData['city'] ?? '').toString().trim().isNotEmpty;

          if (hasAddress) {
            _useProfileShippingAddress = true;
            _shippingNameController.text = userData['last_name'] ?? '';
            _shippingFirstNameController.text = userData['first_name'] ?? '';
            _shippingAddressController.text = userData['address'] ?? '';
            _shippingPostalController.text = userData['postal_code'] ?? '';
            _shippingCityController.text = userData['city'] ?? '';
            _shippingEmailController.text = userData['email'] ?? '';
            _shippingPhoneController.text = userData['phone'] ?? '';

            // Auto-fill billing with same data
            _useProfileBillingAddress = true;
            _billingNameController.text = userData['last_name'] ?? '';
            _billingFirstNameController.text = userData['first_name'] ?? '';
            _billingAddressController.text = userData['address'] ?? '';
            _billingPostalController.text = userData['postal_code'] ?? '';
            _billingCityController.text = userData['city'] ?? '';
            _billingEmailController.text = userData['email'] ?? '';
            _billingPhoneController.text = userData['phone'] ?? '';
          }
        });
        _checkFieldsFilled();
      }
    } catch (e) {
      debugPrint('Error loading profile address: $e');
    }
  }

  double _calculateSubTotal() {
    return _cartData?.items?.fold(0.0, (sum, item) {
          final price = item.price ?? 0.0;
          final quantity = item.quantity ?? 1;
          return sum! + (price * quantity);
        }) ??
        0.0;
  }

  double _calculateShipping() {
    return (_cartData?.totalShippingPrice ?? 0).toDouble();
  }

  Future<bool> _initializePaymentFlow() async {
    if (!_mounted) return false;

    try {
      // Create Customer if not exists
      _customerId = await StripeApi.createCustomer();

      // Create Payment Intent
      final totalAmount = _calculateSubTotal() + _calculateShipping();
      final amount = (totalAmount * 100).toInt();

      debugPrint('=== PAYMENT AMOUNT CHECK ===');
      debugPrint('Subtotal: €${_calculateSubTotal().toStringAsFixed(2)}');
      debugPrint('Shipping: €${_calculateShipping().toStringAsFixed(2)}');
      debugPrint('Total: €${totalAmount.toStringAsFixed(2)}');
      debugPrint('Amount in cents: $amount');
      debugPrint('Platform: ${Platform.isIOS ? "iOS" : "Android"}');
      debugPrint('⚠️ Klarna iOS minimum: Usually €35-€50 (3500-5000 cents)');
      if (amount < 3500) {
        debugPrint('❌ Amount too low for Klarna on iOS: $amount cents < 3500 cents');
        debugPrint('💡 Klarna may not appear on iOS for orders under €35');
      } else {
        debugPrint('✅ Amount meets typical Klarna iOS minimum');
      }
      debugPrint('============================');

      if (amount <= 0) {
        throw Exception('Invalid amount: Amount must be greater than 0');
      }

      final paymentData = await StripeApi.createPaymentIntent(
        _customerId!,
        amount,
      );

      // Set payment details from the API response
      _clientSecret = paymentData['paymentIntent'];
      _publishableKey = paymentData['publishableKey'];
      _ephemeralKey = paymentData['ephemeralKey'];

      // Update Stripe configuration if needed
      if (_publishableKey != Stripe.publishableKey) {
        Stripe.publishableKey = _publishableKey!;
        await Stripe.instance.applySettings();
      }

      debugPrint('Payment flow initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Error initializing payment flow: $e');
      if (_mounted) {
        _showErrorSnackbar('Failed to initialize payment: ${e.toString()}');
      }
      return false;
    }
  }
  

  Future<void> _handlePayment() async {
    if (_isLoading || _isProcessingPayment) return;

    setState(() {
      _isProcessingPayment = true;
      _isLoading = true;
    });

    try {
      // First update the cart with shipping and billing addresses
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final cartApi = CartApi(token: token);

      // Create shipping address object
      final shippingAddress = address_model.ShippingAddress(
        name:
            "${_shippingNameController.text} ${_shippingFirstNameController.text}",
        address: _shippingAddressController.text,
        zip: _shippingPostalController.text,
        city: _shippingCityController.text,
        phone: _shippingPhoneController.text,
        country: 'France',
      );

      // Create billing address object
      final billingAddress = address_model.ShippingAddress(
        name:
            "${_billingNameController.text} ${_billingFirstNameController.text}",
        address: _billingAddressController.text,
        zip: _billingPostalController.text,
        city: _billingCityController.text,
        phone: _billingPhoneController.text,
        country: 'France',
      );

      debugPrint(
        'CHECKOUT: Updating cart with shipping address: ${shippingAddress.toJson()}',
      );
      debugPrint(
        'CHECKOUT: Updating cart with billing address: ${billingAddress.toJson()}',
      );

      // Update the cart with both addresses before processing payment
      await cartApi.updateCartAddresses(
        id: widget.cartId,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
      );

      debugPrint('CHECKOUT: Cart addresses updated successfully');

      // Initialize payment flow after updating addresses
      final initialized = await _initializePaymentFlow();
      if (!initialized || !_mounted) return;
      print('this is stripe keys man -----> ${_publishableKey}');

      debugPrint('=== STRIPE CONFIGURATION CHECK ===');
      debugPrint('Publishable Key: $_publishableKey');
      debugPrint('Stripe.publishableKey: ${Stripe.publishableKey}');
      debugPrint('Client Secret: $_clientSecret');
      debugPrint('Customer ID: $_customerId');
      debugPrint('Ephemeral Key: $_ephemeralKey');
      debugPrint('==================================');
      debugPrint('=== PAYMENT SHEET CONFIG ===');
debugPrint('Platform: ${Platform.isIOS ? "iOS" : "Android"}');
debugPrint('Apple Pay enabled: ${Platform.isIOS}');
debugPrint('Google Pay enabled: ${Platform.isAndroid}');
debugPrint('Google Pay merchantCountryCode: FR');
debugPrint('Google Pay currencyCode: EUR');
debugPrint('Google Pay testEnv: true');
debugPrint('allowsDelayedPaymentMethods: false (Klarna disabled in client)');
debugPrint('Note: Backend must use automatic_payment_methods for Google Pay to work');
debugPrint('============================');

      // Configure payment sheet with platform-specific payment methods
      try {
        debugPrint('Initializing payment sheet...');
        await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: _clientSecret!,
          merchantDisplayName: 'Happer',
          customerId: _customerId,
          customerEphemeralKeySecret: _ephemeralKey,
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: Colors.black),
          ),
          billingDetails: _getBillingDetails(),

          // CRITICAL for Klarna on iOS: returnURL allows Stripe to redirect back
          // to the app after Klarna's external confirmation flow
          returnURL: 'happerapp://stripe-redirect',

          // Google Pay for Android only
          googlePay: Platform.isAndroid ? const PaymentSheetGooglePay(
            merchantCountryCode: 'FR',
            currencyCode: 'EUR',
            testEnv: true,
          ) : null,

          // Apple Pay for iOS only
          applePay: Platform.isIOS ? const PaymentSheetApplePay(
            merchantCountryCode: 'FR',
          ) : null,

          // Enable Klarna and other BNPL (Buy Now Pay Later) methods on both platforms
          allowsDelayedPaymentMethods: true,
        ),
      );
      debugPrint('Payment sheet initialized successfully');
      } catch (e) {
        debugPrint('❌ ERROR initializing payment sheet: $e');
        rethrow;
      }

      // Present payment sheet
      await Future.microtask(() async {
        try {
          await Stripe.instance.presentPaymentSheet();

          debugPrint('CHECKOUT: Payment successful!');
          debugPrint(
            'CHECKOUT: Order created with billing address: ${_billingNameController.text} ${_billingFirstNameController.text}',
          );

          if (_mounted) {
            // Handle successful payment
            await Future.wait([
              // Clear cart and show notification
              _paymentService.clearCart(),
              //_paymentService.showPurchaseConfirmationNotification(),
            ]);

            // Show success snackbar
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(
            //       'Payment successful! The invoice will include your billing address.',
            //     ),
            //     backgroundColor: Colors.green,
            //     behavior: SnackBarBehavior.floating,
            //     margin: EdgeInsets.all(16),
            //     duration: Duration(seconds: 3),
            //   ),
            // );

            // // Navigate to success screen
            // Navigator.pushAndRemoveUntil(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const MyPurchasesScreen(),
            //   ),
            //   (route) => false, // Remove all previous routes
            // );
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.scale,
              headerAnimationLoop: false,
              dismissOnTouchOutside: false,
              dismissOnBackKeyPress: false,
              dialogBackgroundColor: Colors.white,
              dialogBorderRadius: BorderRadius.circular(15),
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.85,
              customHeader: Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade50,
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              title: 'Paiement Réussi!',
              titleTextStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Lato',
              ),
              desc:
                  'Votre paiement a été effectué avec succès.',
              descTextStyle: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
                fontFamily: 'Lato',
              ),
              btnOkText: 'Accueil',
              btnOkColor: Colors.black,
              btnOkIcon: Icons.arrow_forward,
              buttonsBorderRadius: BorderRadius.circular(8),
              btnOkOnPress: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
              },
            ).show();
          }
        } catch (e) {
          if (e is StripeException) {
            if (e.error.code == FailureCode.Canceled) {
              debugPrint('Payment cancelled by user');
              return;
            }
          }
          rethrow;
        }
      });
    } catch (e) {
      debugPrint('Payment error occurred: $e');
      if (_mounted) {
        if (e is StripeException) {
          _handleStripeError(e);
        } else {
          _showErrorSnackbar(e.toString());
        }
      }
    } finally {
      if (_mounted) {
        setState(() {
          _isProcessingPayment = false;
          _isLoading = false;
        });
      }
      ;
    }
  }

  void _handleStripeError(StripeException e) {
    final error = e.error;
    debugPrint('Stripe error code: ${error.code}');
    debugPrint('Stripe error message: ${error.message}');
    debugPrint('Stripe error type: ${error.type}');

    String errorMessage = error.localizedMessage ?? 'Payment failed';

    if (error.code == FailureCode.Failed &&
        error.message?.contains('No such payment_intent') == true) {
      errorMessage = 'Payment session expired. Please try again.';
    }

    _showErrorSnackbar(errorMessage);
  }

  BillingDetails _getBillingDetails() {
    return BillingDetails(
      name: "${_billingNameController.text} ${_billingFirstNameController.text}"
          .trim(),
      email: _billingEmailController.text,
      phone: _billingPhoneController.text,
      address: Address(
        city: _billingCityController.text,
        postalCode: _billingPostalController.text,
        country: 'FR',
        line1: _billingAddressController.text,
        line2: '',
        state: '',
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    // Dismiss any existing snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.visible,
                maxLines: 3,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  bool isNotEmpty(String? value) {
    if (value == null) return false;
    String trimmed = value.trim();
    bool result = trimmed.isNotEmpty && trimmed != 'N/A';
    debugPrint('Validating field: "$value" - Valid: $result');
    return result;
  }

  void _showMissingFieldsError() {
    // List to collect missing field names
    List<String> missingFields = [];

    // Check shipping address fields
    if (_shippingNameController.text.trim().isEmpty)
      missingFields.add('Shipping Name');
    if (_shippingFirstNameController.text.trim().isEmpty)
      missingFields.add('Shipping First Name');
    if (_shippingAddressController.text.trim().isEmpty)
      missingFields.add('Shipping Address');
    if (_shippingPostalController.text.trim().isEmpty)
      missingFields.add('Shipping Postal Code');
    if (_shippingCityController.text.trim().isEmpty)
      missingFields.add('Shipping City');
    if (_shippingEmailController.text.trim().isEmpty)
      missingFields.add('Shipping Email');
    if (_shippingPhoneController.text.trim().isEmpty)
      missingFields.add('Shipping Phone');

    // Check billing address fields
    if (_billingNameController.text.trim().isEmpty)
      missingFields.add('Billing Name');
    if (_billingFirstNameController.text.trim().isEmpty)
      missingFields.add('Billing First Name');
    if (_billingAddressController.text.trim().isEmpty)
      missingFields.add('Billing Address');
    if (_billingPostalController.text.trim().isEmpty)
      missingFields.add('Billing Postal Code');
    if (_billingCityController.text.trim().isEmpty)
      missingFields.add('Billing City');
    if (_billingEmailController.text.trim().isEmpty)
      missingFields.add('Billing Email');
    if (_billingPhoneController.text.trim().isEmpty)
      missingFields.add('Billing Phone');

    // Check for email validity
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (_shippingEmailController.text.trim().isNotEmpty &&
        !emailRegex.hasMatch(_shippingEmailController.text.trim())) {
      missingFields.add('Valid Shipping Email');
    }
    if (_billingEmailController.text.trim().isNotEmpty &&
        !emailRegex.hasMatch(_billingEmailController.text.trim())) {
      missingFields.add('Valid Billing Email');
    }

    // Create appropriate error message based on missing fields
    String errorMessage;
    if (missingFields.isEmpty) {
      errorMessage = 'Please check the form for errors and try again';
    } else if (missingFields.length > 3) {
      errorMessage = 'Please complete all required fields';
    } else {
      errorMessage = 'Please provide: ${missingFields.join(', ')}';
    }

    _showErrorSnackbar(errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // 'ADDRESS',
          'ADRESSE',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildContent(),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUseProfileShippingCheckbox(),
                  SizedBox(height: 12),
                  _builShippingAddressCard(),
                  SizedBox(height: 12),
                  _builBillingAddressCard(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Fixed checkout section at bottom
          // Container(
          //   color: Colors.white,
          //   padding: EdgeInsets.all(16),
          //   child: SafeArea(child: _buildCheckoutSection()),
          // ),
          SafeArea(
          top: false,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: _buildCheckoutSection(),
          ),
        )
        ],
      ),
    );
  }

  Widget _buildUseProfileShippingCheckbox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _useProfileShippingAddress = !_useProfileShippingAddress;

            if (_useProfileShippingAddress && _profileAddress != null) {
              _shippingNameController.text =
                  _profileAddress!["last_name"] ?? "";
              _shippingFirstNameController.text =
                  _profileAddress!["first_name"] ?? "";
              _shippingAddressController.text =
                  _profileAddress!["address"] ?? "";
              _shippingPostalController.text =
                  _profileAddress!["postal_code"] ?? "";
              _shippingCityController.text =
                  _profileAddress!["city"] ?? "";
              _shippingEmailController.text =
                  _profileAddress!["email"] ?? "";
              _shippingPhoneController.text =
                  _profileAddress!["phone"] ?? "";
            } else {
              _shippingNameController.clear();
              _shippingFirstNameController.clear();
              _shippingAddressController.clear();
              _shippingPostalController.clear();
              _shippingCityController.clear();
              _shippingEmailController.clear();
              _shippingPhoneController.clear();
            }
          });
        },
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: _useProfileShippingAddress,
                onChanged: (value) {
                  setState(() {
                    _useProfileShippingAddress = value ?? false;

                    if (_useProfileShippingAddress && _profileAddress != null) {
                      _shippingNameController.text =
                          _profileAddress!["last_name"] ?? "";
                      _shippingFirstNameController.text =
                          _profileAddress!["first_name"] ?? "";
                      _shippingAddressController.text =
                          _profileAddress!["address"] ?? "";
                      _shippingPostalController.text =
                          _profileAddress!["postal_code"] ?? "";
                      _shippingCityController.text =
                          _profileAddress!["city"] ?? "";
                      _shippingEmailController.text =
                          _profileAddress!["email"] ?? "";
                      _shippingPhoneController.text =
                          _profileAddress!["phone"] ?? "";
                    } else {
                      _shippingNameController.clear();
                      _shippingFirstNameController.clear();
                      _shippingAddressController.clear();
                      _shippingPostalController.clear();
                      _shippingCityController.clear();
                      _shippingEmailController.clear();
                      _shippingPhoneController.clear();
                    }
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(color: Colors.grey[400]!),
                activeColor: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Utiliser l'adresse de mon profil",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _builShippingAddressCard() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              _buildAddressField('Nom', _shippingFirstNameController),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              _buildAddressField('Prénom', _shippingNameController),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              _buildAddressField('Adresse', _shippingAddressController),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              _buildAddressField('Code postal', _shippingPostalController),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              _buildAddressField('Ville', _shippingCityController),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              _buildAddressField('E-mail', _shippingEmailController),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              _buildAddressField('Phone', _shippingPhoneController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _builBillingAddressCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          'ADDRESSE DE FACTURATION',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            setState(() {
              _useProfileBillingAddress = !_useProfileBillingAddress;
              if (_useProfileBillingAddress &&
                  _profileAddress != null) {
                // Update billing address fields with profile data
                _billingNameController.text =
                    _shippingNameController.text;
                _billingFirstNameController.text =
                    _shippingFirstNameController.text;
                _billingAddressController.text =
                    _shippingAddressController.text;
                _billingPostalController.text =
                    _shippingPostalController.text;
                _billingCityController.text =
                    _shippingCityController.text;
                _billingEmailController.text =
                    _shippingEmailController.text;
                _billingPhoneController.text =
                    _shippingPhoneController.text;
              } else {
                // Clear billing address fields when unchecked
                _billingNameController.text = '';
                _billingFirstNameController.text = '';
                _billingAddressController.text = '';
                _billingPostalController.text = '';
                _billingCityController.text = '';
                _billingEmailController.text = '';
                _billingPhoneController.text = '';
              }
            });
          },
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _useProfileBillingAddress,
                  onChanged: (value) {
                    setState(() {
                      _useProfileBillingAddress = value ?? false;
                      if (_useProfileBillingAddress &&
                          _profileAddress != null) {
                        // Update billing address fields with profile data
                        _billingNameController.text =
                            _shippingNameController.text;
                        _billingFirstNameController.text =
                            _shippingFirstNameController.text;
                        _billingAddressController.text =
                            _shippingAddressController.text;
                        _billingPostalController.text =
                            _shippingPostalController.text;
                        _billingCityController.text =
                            _shippingCityController.text;
                        _billingEmailController.text =
                            _shippingEmailController.text;
                        _billingPhoneController.text =
                            _shippingPhoneController.text;
                      } else {
                        // Clear billing address fields when unchecked
                        _billingNameController.text = '';
                        _billingFirstNameController.text = '';
                        _billingAddressController.text = '';
                        _billingPostalController.text = '';
                        _billingCityController.text = '';
                        _billingEmailController.text = '';
                        _billingPhoneController.text = '';
                      }
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(color: Colors.grey[400]!),
                  activeColor: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Utiliser l'adresse saisie dans Mon Profil",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Lato',
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildAddressField('Nom', _billingFirstNameController),
              Divider(height: 1, color: Colors.grey[300]),
              _buildAddressField('Prénom', _billingNameController),
              Divider(height: 1, color: Colors.grey[300]),
              _buildAddressField('Adresse', _billingAddressController),
              Divider(height: 1, color: Colors.grey[300]),
              _buildAddressField('Code postal', _billingPostalController),
              Divider(height: 1, color: Colors.grey[300]),
              _buildAddressField('Ville', _billingCityController),
              Divider(height: 1, color: Colors.grey[300]),
              _buildAddressField('E-mail', _billingEmailController),
              Divider(height: 1, color: Colors.grey[300]),
              _buildAddressField('Phone', _billingPhoneController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutSection() {
    debugPrint('Building checkout section - Button enabled: $_isButtonEnabled');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: Colors.grey[300], height: 1),
        _buildSummaryRow(
            'Sous-total TTC', "${_calculateSubTotal().toStringAsFixed(2)} €"),
        _buildSummaryRow(
            'Frais de Livraison',
            _cartData?.totalShippingPrice == null || _cartData!.totalShippingPrice == 0
                ? "Offerts"
                : "${_cartData!.totalShippingPrice!.toStringAsFixed(2)} €"),
        SizedBox(height: 8),
        Divider(color: Colors.grey[300], height: 1),
        SizedBox(height: 8),
        _buildSummaryRow('Total TTC', '${_cartData?.total?.toStringAsFixed(2) ?? '0.00'} €', isBold: true),
        
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isProcessingPayment
              ? null
              : () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _handlePayment();
                  } else {
                    _showMissingFieldsError();
                  }
                },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessingPayment)
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              else ...[
                Text(
                  'CHECKOUT',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField(String label, TextEditingController controller) {
    String getHintText() {
      switch (label) {
        case 'Name':
          return 'Enter your last name';
        case 'Prénom':
          return 'Enter your first name';
        case 'Adresse':
          return 'Enter your street address';
        case 'Code postal':
          return 'Enter postal code';
        case 'Ville':
          return 'Enter city name';
        case 'E-mail':
          return 'Enter email address';
        case 'Phone':
          return 'Enter phone number';
        default:
          return '';
      }
    }

    String? validator(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Required';
      }
      if (label == 'E-mail') {
        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+ ?$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Enter a valid email';
        }
      }
      if (label == 'Phone') {
        if (value.trim().length < 8) {
          return 'Enter a valid phone number';
        }
      }
      return null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Lato',
                color: Color(0xFF5C5C5C),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              cursorColor: Colors.black,
              keyboardType: label == 'Code postal'
                  ? TextInputType.number
                  : label == 'E-mail'
                      ? TextInputType.emailAddress
                      : label == 'Phone'
                          ? TextInputType.phone
                          : TextInputType.text,
              inputFormatters: (label == 'Code postal' || label == 'Phone')
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Lato',
                color: Colors.black,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
                hintText: getHintText(),
                hintStyle: const TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: 14,
                  fontFamily: 'Lato',
                ),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: isBold ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: isBold ? Colors.black : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
