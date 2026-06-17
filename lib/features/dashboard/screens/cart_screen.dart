import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/profile/data/repositories/address_repository.dart';
import 'package:happer_app/features/dashboard/bindings/cart_binding.dart';
import 'package:happer_app/features/dashboard/screens/select_address_screen.dart';
import 'package:happer_app/features/profile/models/address_model.dart';
import 'package:happer_app/features/dashboard/data/repositories/cart_repository.dart';
import 'package:happer_app/features/profile/screens/my_purchases_screen.dart';
import 'package:happer_app/shared/controllers/cart_controller.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:happer_app/l10n/app_localizations.dart';

class _CartItem {
  final String id;
  final String productName;
  final String brandName;
  final String brandPicture;
  final String imageUrl;
  final double price;
  final int quantity;
  final String color;
  final String size;

  const _CartItem({
    required this.id,
    required this.productName,
    required this.brandName,
    required this.brandPicture,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.color,
    required this.size,
  });

  static _CartItem fromJson(Map<String, dynamic> json) {
    // product_id is a populated object
    final productRaw = json['product_id'];
    final productName =
        productRaw is Map ? (productRaw['name'] as String? ?? '') : '';
    final productImage = productRaw is Map
        ? (productRaw['product_image'] as String? ?? '').trim()
        : '';

    // brand_id is a top-level field on the cart item
    final brandRaw = json['brand_id'];
    final brandName =
        brandRaw is Map ? (brandRaw['name'] as String? ?? '') : '';
    final brandPicture =
        brandRaw is Map ? (brandRaw['picture'] as String? ?? '') : '';

    // variant_id: use first image if available, fall back to product_image
    final variantRaw = json['variant_id'];
    final variantImages = variantRaw is Map
        ? (variantRaw['images'] as List<dynamic>? ?? [])
            .whereType<String>()
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];
    final imageUrl =
        variantImages.isNotEmpty ? variantImages.first : productImage;

    // unit_price is the correct price field
    final price = (json['unit_price'] as num?)?.toDouble() ??
        (variantRaw is Map
            ? (variantRaw['price'] as num?)?.toDouble()
            : null) ??
        0.0;

    return _CartItem(
      id: json['_id'] as String? ?? '',
      productName: productName,
      brandName: brandName,
      brandPicture: brandPicture,
      imageUrl: imageUrl,
      price: price,
      quantity: json['quantity'] as int? ?? 1,
      color: '',
      size: '',
    );
  }
}

enum _PaymentMethod { applePay, googlePay, klarna, card }

extension _PaymentMethodExt on _PaymentMethod {
  String get label {
    switch (this) {
      case _PaymentMethod.applePay:
        return 'Apple Pay';
      case _PaymentMethod.googlePay:
        return 'Google Pay';
      case _PaymentMethod.klarna:
        return 'Klarna';
      case _PaymentMethod.card:
        return 'Carte';
    }
  }

  // Stripe paymentMethodOrder key for this method
  String get stripeKey {
    switch (this) {
      case _PaymentMethod.applePay:
        return 'apple_pay';
      case _PaymentMethod.googlePay:
        return 'google_pay';
      case _PaymentMethod.klarna:
        return 'klarna';
      case _PaymentMethod.card:
        return 'card';
    }
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = true;
  bool _isTermsAccepted = true;
  bool _isPaying = false;
  List<_CartItem> _items = [];
  double _subtotal = 0;
  double _total = 0;
  double _shippingAmount = 0;
  // Apple Pay on iOS, Google Pay on Android
  _PaymentMethod _selectedPaymentMethod =
      Platform.isIOS ? _PaymentMethod.applePay : _PaymentMethod.googlePay;

  // Methods available per platform
  List<_PaymentMethod> get _availablePaymentMethods => [
        if (Platform.isIOS) _PaymentMethod.applePay,
        if (Platform.isAndroid) _PaymentMethod.googlePay,
        _PaymentMethod.klarna,
        _PaymentMethod.card,
      ];
  AddressModel? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _fetchCart();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    try {
      final addresses = await AddressRepository().getAllAddresses();
      if (addresses.isEmpty || !mounted) return;
      final addr = addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses.first,
      );
      setState(() => _selectedAddress = addr);
    } catch (e) {
      debugPrint('Failed to load default address: $e');
    }
  }

  Future<bool> _removeItem(_CartItem item) async {
    try {
      CartBinding().dependencies();
      final repo = Get.find<CartRepository>();
      await repo.removeCartItem(item.id);
      if (!mounted) return false;
      setState(() {
        _items.removeWhere((i) => i.id == item.id);
        _subtotal =
            (_subtotal - item.price * item.quantity).clamp(0, double.infinity);
        _total = _subtotal + _shippingAmount;
      });
      showAppSnackBar(AppLocalizations.of(context).itemRemovedFromCart,
          isSuccess: true);
      return true;
    } catch (_) {
      if (mounted)
        showAppSnackBar(AppLocalizations.of(context).itemRemoveFailed,
            isSuccess: false);
      return false;
    }
  }

  Future<void> _fetchCart() async {
    try {
      CartBinding().dependencies();
      final repo = Get.find<CartRepository>();
      final data = await repo.getMyCart();
      if (!mounted) return;
      if (data == null) {
        setState(() => _isLoading = false);
        return;
      }
      final rawItems = (data['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(_CartItem.fromJson)
          .toList();
      setState(() {
        _items = rawItems;
        _subtotal = (data['subtotal'] as num?)?.toDouble() ?? 0.0;
        _shippingAmount = (data['shipping_amount'] as num?)?.toDouble() ?? 0.0;
        _total = (data['total'] as num?)?.toDouble() ?? 0.0;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pay() async {
    if (_selectedAddress == null) {
      showAppSnackBar(AppLocalizations.of(context).pleaseSelectShippingAddress,
          isSuccess: false);
      return;
    }
    setState(() => _isPaying = true);
    try {
      CartBinding().dependencies();
      final repo = Get.find<CartRepository>();
      final data = await repo.initiatePayment(_selectedAddress!.id);
      if (!mounted) return;

      final clientSecret = data['client_secret'] as String? ?? '';
      final publishableKey = data['publishable_key'] as String? ?? '';
      final amount = (data['amount'] as num?)?.toDouble() ?? _total;
      final currency = (data['currency'] as String? ?? 'eur').toUpperCase();

      if (clientSecret.isEmpty || publishableKey.isEmpty) {
        showAppSnackBar('Erreur: données de paiement manquantes',
            isSuccess: false);
        return;
      }

      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();

      if (_selectedPaymentMethod == _PaymentMethod.applePay) {
        await Stripe.instance.confirmPlatformPayPaymentIntent(
          clientSecret: clientSecret,
          confirmParams: PlatformPayConfirmParams.applePay(
            applePay: ApplePayParams(
              cartItems: [
                ApplePayCartSummaryItem.immediate(
                  label: 'Happer',
                  amount: (amount / 100).toStringAsFixed(2),
                ),
              ],
              merchantCountryCode: 'FR',
              currencyCode: currency,
            ),
          ),
        );
      } else if (_selectedPaymentMethod == _PaymentMethod.googlePay) {
        await Stripe.instance.confirmPlatformPayPaymentIntent(
          clientSecret: clientSecret,
          confirmParams: PlatformPayConfirmParams.googlePay(
            googlePay: GooglePayParams(
              testEnv: false,
              merchantCountryCode: 'FR',
              currencyCode: currency,
              merchantName: 'Happer',
            ),
          ),
        );
      } else {
        // Klarna and Card — use the standard payment sheet
        // Pre-fill billing details so Klarna can appear (it requires email + country)
        final addr = _selectedAddress;
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Happer',
            style: ThemeMode.light,
            paymentMethodOrder: [_selectedPaymentMethod.stripeKey],
            billingDetails: addr != null
                ? BillingDetails(
                    email: addr.email,
                    name: '${addr.firstName} ${addr.lastName}'.trim(),
                    phone: addr.mobileNumber,
                    address: Address(
                      city: addr.city,
                      postalCode: addr.postalCode,
                      line1: addr.streetAddress,
                      line2: '',
                      state: '',
                      country: 'FR',
                    ),
                  )
                : null,
          ),
        );
        await Stripe.instance.presentPaymentSheet();
      }

      if (!mounted) return;
      showAppSnackBar('Paiement effectué avec succès !');

      // Clear cart locally
      setState(() {
        _items = [];
        _subtotal = 0;
        _shippingAmount = 0;
        _total = 0;
      });
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().clearCart();
      }

      // Navigate to purchases screen, removing cart from the stack
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => const MyPurchasesScreen(fromCart: true)),
      );
    } on StripeException catch (e) {
      if (!mounted) return;
      if (e.error.code != FailureCode.Canceled) {
        showAppSnackBar(
            e.error.localizedMessage ?? e.error.message ?? 'Erreur de paiement',
            isSuccess: false);
      }
    } catch (e) {
      if (mounted) showAppSnackBar(e.toString(), isSuccess: false);
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  void _showPaymentMethodPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choisir un moyen de paiement',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lato'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              for (final method in _availablePaymentMethods)
                ListTile(
                  leading: _PaymentMethodIcon(method: method),
                  title: Text(method.label,
                      style: const TextStyle(fontFamily: 'Lato', fontSize: 14)),
                  trailing: _selectedPaymentMethod == method
                      ? const Icon(Icons.check_circle, color: Colors.black)
                      : null,
                  onTap: () {
                    setState(() => _selectedPaymentMethod = method);
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(title: 'MON PANIER'),
      body: _isLoading
          ? const _CartShimmer()
          : _items.isEmpty
              ? const _EmptyCartView()
              : ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _DeliveryBanner(itemCount: _items.length),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        '${_items.length} Produit${_items.length > 1 ? 's' : ''} Ajouté${_items.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final item in List.of(_items))
                      Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white, size: 28),
                        ),
                        confirmDismiss: (_) => _removeItem(item),
                        child: _CartItemCard(item: item),
                      ),
                    const SizedBox(height: 16),
                    // Price summary
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _CartPriceRow(
                              title: 'Sous-total TTC',
                              value: '${_subtotal.toStringAsFixed(2)} €',
                              isItalic: false),
                          _CartPriceRow(
                              title: 'Frais de Livraison',
                              value: _shippingAmount > 0
                                  ? '${_shippingAmount.toStringAsFixed(2)} €'
                                  : 'Gratuit',
                              isItalic: true),
                          const Divider(),
                          _CartPriceRow(
                              title: 'Total TTC',
                              value: '${_total.toStringAsFixed(2)} €',
                              isItalic: false,
                              isBold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Terms checkbox
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _isTermsAccepted,
                              onChanged: (v) =>
                                  setState(() => _isTermsAccepted = v ?? false),
                              activeColor: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: "J'accepte les ",
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black87),
                                children: [
                                  TextSpan(
                                    text: 'Conditions générales de vente',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const CgvWebViewScreen()),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: _isLoading || _items.isEmpty
          ? null
          : SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Address row — Blinkit style ──────────────────────
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push<AddressModel>(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SelectAddressScreen()),
                        );
                        if (result != null)
                          setState(() => _selectedAddress = result);
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                                color: Colors.grey.shade200, width: 1),
                            bottom: BorderSide(
                                color: Colors.grey.shade200, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.home_outlined,
                                  size: 20, color: Colors.black),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Livraison à',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontFamily: 'Lato'),
                                  ),
                                  Text(
                                    _selectedAddress != null
                                        ? (_selectedAddress!.city.isNotEmpty
                                            ? _selectedAddress!.city
                                            : _selectedAddress!.streetAddress)
                                        : 'Sélectionner une adresse',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Lato',
                                      color: _selectedAddress != null
                                          ? Colors.black
                                          : Colors.grey.shade500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_selectedAddress != null)
                                    Text(
                                      _selectedAddress!.streetAddress,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                          fontFamily: 'Lato'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedAddress != null ? 'Changer' : 'Choisir',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lato',
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ── Payment + Order row ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _showPaymentMethodPicker,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'PAY AVEC',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontFamily: 'Lato',
                                      letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _PaymentMethodIcon(
                                        method: _selectedPaymentMethod),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedPaymentMethod.label,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.keyboard_arrow_down,
                                        size: 16, color: Colors.black),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const _MastercardIcon(),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: Colors.green.shade200,
                                            width: 0.5),
                                      ),
                                      child: Text(
                                        'Sécurisé',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green.shade700,
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isTermsAccepted
                                    ? Colors.black
                                    : Colors.grey.shade400,
                                minimumSize: const Size(double.infinity, 62),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: (_isTermsAccepted && !_isPaying)
                                  ? _pay
                                  : null,
                              child: _isPaying
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${_total.toStringAsFixed(2)} €',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  fontFamily: 'Lato'),
                                            ),
                                            const Text(
                                              'TOTAL TTC',
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 10,
                                                  fontFamily: 'Lato'),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: 28,
                                          width: 1,
                                          color: Colors.white30,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                        ),
                                        const Text(
                                          'Commander',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              fontFamily: 'Lato'),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_forward,
                                            color: Colors.white, size: 16),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── Cart Widget Components ──────────────────────────────────────────────────

class _PaymentMethodIcon extends StatelessWidget {
  final _PaymentMethod method;
  const _PaymentMethodIcon({required this.method});

  @override
  Widget build(BuildContext context) {
    switch (method) {
      case _PaymentMethod.applePay:
        return const Icon(Icons.apple, size: 18, color: Colors.black);
      case _PaymentMethod.googlePay:
        return const Icon(Icons.g_mobiledata, size: 22, color: Colors.black);
      case _PaymentMethod.klarna:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB3C7),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('K',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
        );
      case _PaymentMethod.card:
        return const Icon(Icons.credit_card, size: 18, color: Colors.black);
    }
  }
}

class _CartShimmer extends StatelessWidget {
  const _CartShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 3,
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Votre panier est vide',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des produits pour commencer',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _DeliveryBanner extends StatelessWidget {
  final int itemCount;
  const _DeliveryBanner({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined,
              color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Livraison estimée : 2-5 jours',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Lato'),
              ),
              const SizedBox(height: 2),
              Text(
                'Expédition de $itemCount article${itemCount > 1 ? 's' : ''}',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12, fontFamily: 'Lato'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MastercardIcon extends StatelessWidget {
  const _MastercardIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 26,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                  color: Color(0xFFEB001B), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            left: 14,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final _CartItem item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final sizeLabel = [
      if (item.color.isNotEmpty) item.color,
      if (item.size.isNotEmpty) item.size,
    ].join(' / ');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 100,
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey.shade200),
                      errorWidget: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          size: 30,
                          color: Colors.grey),
                    )
                  : const Icon(Icons.image, size: 30, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.brandName.isNotEmpty)
                  Text(item.brandName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.3,
                          color: Colors.black)),
                const SizedBox(height: 2),
                Text(item.productName,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text('${item.price.toStringAsFixed(2)} €',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black)),
                const SizedBox(height: 2),
                const Text('Prix Spécial Happer',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                const Text('Livré dans 2-5 jours',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (sizeLabel.isNotEmpty)
                Text(sizeLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black54)),
              Text('x${item.quantity}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black54)),
              const SizedBox(height: 12),
              if (item.brandPicture.isNotEmpty)
                CachedNetworkImage(
                    imageUrl: item.brandPicture,
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) =>
                        const SizedBox(width: 44, height: 44))
              else
                const SizedBox(width: 44, height: 44),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartPriceRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isItalic;
  final bool isBold;

  const _CartPriceRow({
    required this.title,
    required this.value,
    required this.isItalic,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: isItalic ? FontStyle.italic : FontStyle.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class _PaymentWebViewScreen extends StatefulWidget {
  final String url;
  const _PaymentWebViewScreen({required this.url});

  @override
  State<_PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<_PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(title: 'Paiement'),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}

class CgvWebViewScreen extends StatefulWidget {
  const CgvWebViewScreen({super.key});

  @override
  State<CgvWebViewScreen> createState() => _CgvWebViewScreenState();
}

class _CgvWebViewScreenState extends State<CgvWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse('https://happer.fr/cgv'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          HapperAppBar(title: AppLocalizations.of(context).termsAndConditions),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
            gestureRecognizers: {
              Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer()),
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}
