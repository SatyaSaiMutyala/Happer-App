import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/creator/api/cart_api.dart';
import 'package:happer_app/creator/model/cart_model.dart';
import 'package:happer_app/profile/ui/my_purchases_screen.dart';
import 'package:happer_app/providers/cart_provider.dart';
import 'package:happer_app/services/payment_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:happer_app/dashboard/screens/dashboard_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'address_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final PaymentService _paymentService = PaymentService();
  CartModel? _cartModel;
  bool _isLoading = true;
  int cartItemCount = 0;
  bool _isTermsAccepted = false;

  @override
  void initState() {
    super.initState();
    _fetchCartDetails();
  }

  Future<void> handlePayment() async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Happer',
          paymentIntentClientSecret: '', // TODO: Get from server
          style: ThemeMode.light,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'IN', // or your country code
            currencyCode: 'INR', // or your currency
            testEnv: true, // set to false in production
          ),
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'IN'),
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      await _paymentService.handlePaymentSuccess(context);
      await _paymentService.clearCart();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyPurchasesScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    }
  }

  void _fetchCartDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print('DEBUG: No token found');
      setState(() => _isLoading = false);
      return;
    }

    final cartApi = CartApi(token: token);

    try {
      final cartModel = await cartApi.getCartDetails();
      print('DEBUG: Fetched cart model: ${cartModel.data?.items}');
      setState(() {
        _cartModel = cartModel;
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error fetching cart details: $e');
      setState(() => _isLoading = false);
    }
  }

  double _calculateSubTotal() {
    return _cartModel?.data?.items?.fold(0.0, (sum, item) {
          final price = item.price ?? 0.0;
          final quantity = item.quantity ?? 1;
          return sum! + (price * quantity);
        }) ??
        0.0;
  }

  double _calculateShipping() {
    return _cartModel?.data?.items?.fold(0.0, (sum, item) {
          final shipping = (item.shippingPrice is num)
              ? (item.shippingPrice as num).toDouble()
              : 0.0;
          return sum! + shipping;
        }) ??
        0.0;
  }

  Future<void> _deleteCartItem(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: No token found. Please log in again.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    final cartApi = CartApi(token: token);

    try {
      bool success = await cartApi.deleteCartItem(itemId);

      if (success) {
        setState(() {
          _cartModel?.data?.items?.removeWhere((e) => e.id == itemId);
          if (_cartModel?.data?.total != null) {
            _cartModel!.data!.total = _calculateSubTotal();
          }
          // Also update the shipping price when items are removed
          if (_cartModel?.data?.totalShippingPrice != null) {
            _cartModel!.data!.totalShippingPrice = _calculateShipping().toInt();
          }
        });

        // Update cart provider
        if (mounted) {
          context.read<CartProvider>().fetchCartItemCount();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Article retiré du panier'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black,
            margin: EdgeInsets.all(16),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la suppression de l\'article'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            margin: EdgeInsets.all(16),
          ),
        );
        _fetchCartDetails();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression de l\'article'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          margin: EdgeInsets.all(16),
        ),
      );
      _fetchCartDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      'DEBUG: Building cart screen with _cartModel: ${_cartModel?.data?.items}',
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
            // _fetchCartItemCount(); // Refresh cart count when returning
          },
        ),
        title: const Text(
          'PANIER',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.0,
            letterSpacing: 0.0,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 10),
                Text(
                  "${_cartModel?.data?.items?.length ?? 0} Produits Ajoutés",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: _cartModel?.data?.items == null ||
                          _cartModel!.data!.items!.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Votre panier est vide",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Ajoutez des articles à votre panier pour les voir ici",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _cartModel!.data!.items!.length,
                          itemBuilder: (context, index) {
                            final item = _cartModel!.data!.items![index];
                            print('DEBUG: Rendering item: $item');
                            return Dismissible(
                              key: Key(item.id ?? '$index'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 20),
                                color: Colors.red,
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    title: Text(
                                      "Confirmer",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    content: Text(
                                      "Êtes-vous sûr de vouloir retirer cet article de votre panier ?",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(
                                          context,
                                          false,
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: Text(
                                          "Annuler",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () => Navigator.pop(
                                          context,
                                          true,
                                        ),
                                        child: Text(
                                          "Supprimer",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) {
                                _deleteCartItem(item.id ?? '');
                              },
                              child: Container(
                                width: 500,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        item.itemId?.pictures?.isNotEmpty == true
                                            ? item.itemId!.pictures![0]
                                            : '',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, _, __) =>
                                            Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey.shade200,
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.itemId?.brandId?.name?.toUpperCase() ??
                                                '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              letterSpacing: 0.5,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            item.name ?? 'Unknown Item',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "${item.price?.toStringAsFixed(2) ?? '0.00'} €",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            "x ${item.quantity ?? 1}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          item.size ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        if (item.itemId?.brandId?.picture != null)
                                          Container(
                                            width: 50,
                                            height: 50,
                                            padding: EdgeInsets.all(4),
                                            child: Image.network(
                                              item.itemId!.brandId!.picture!,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, _, __) =>
                                                  SizedBox.shrink(),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Divider(),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                //   child: Column(
                //     children: [
                //       _buildPriceRow(
                //         "Sous-total",
                //         "€${_calculateSubTotal().toStringAsFixed(2)}",
                //         false,
                //       ),
                //       // _buildPriceRow("Shipping", "Free", true),
                //       _buildPriceRow(
                //         "Frais de Livraison",
                //         _calculateShipping() == 0
                //             ? "Free"
                //             : "€${_calculateShipping().toStringAsFixed(2)}",
                //         true,
                //       ),
                //       Divider(),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text('Total'),
                //           Text(
                //             "€${_cartModel?.data?.total?.toStringAsFixed(2) ?? '0.00'}",
                //             style: TextStyle(
                //               fontSize: 16,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //         ],
                //       ),
                //       SizedBox(height: 15),
                //       Padding(
                //         padding: const EdgeInsets.only(bottom: 16.0),
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: Colors.black,
                //             minimumSize: Size(double.infinity, 50),
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(10),
                //             ),
                //           ),
                //           onPressed: () {
                //             if (AppManager.isLoginAsGuest) {
                //               ScaffoldMessenger.of(context).showSnackBar(
                //                 const SnackBar(
                //                   content: Text('Please log in to Continue'),
                //                 ),
                //               );
                //               return;
                //             }
                //             if (_cartModel?.data?.items?.isEmpty ?? true) {
                //               ScaffoldMessenger.of(context).showSnackBar(
                //                 SnackBar(
                //                   content: Text(
                //                     'Please add items to your cart first',
                //                   ),
                //                   backgroundColor: Colors.red,
                //                   behavior: SnackBarBehavior.floating,
                //                   margin: EdgeInsets.all(16),
                //                   shape: RoundedRectangleBorder(
                //                     borderRadius: BorderRadius.circular(8),
                //                   ),
                //                 ),
                //               );
                //               return;
                //             }

                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                 builder: (context) => AddressScreen(
                //                   cartId: _cartModel?.data?.id ?? '',
                //                 ),
                //               ),
                //             ).then((_) {
                //               Navigator.pushAndRemoveUntil(
                //                 context,
                //                 MaterialPageRoute(
                //                   builder: (_) => DashboardScreen(),
                //                 ),
                //                 (route) => false,
                //               );
                //             });
                //           },
                //           child: Text(
                //             "CONTINUER →",
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 16,
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
            bottomNavigationBar: SafeArea(
  child: Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, -2),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPriceRow(
          "Sous-total TTC",
          "${_calculateSubTotal().toStringAsFixed(2)} €",
          false,
        ),
        _buildPriceRow(
          "Frais de Livraison",
          _cartModel?.data?.totalShippingPrice == null ||
                  _cartModel!.data!.totalShippingPrice == 0
              ? "Gratuit"
              : "${_cartModel!.data!.totalShippingPrice!.toStringAsFixed(2)} €",
          true,
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total TTC',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${_cartModel?.data?.total?.toStringAsFixed(2) ?? '0.00'} €",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Terms and conditions checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _isTermsAccepted,
                onChanged: (value) {
                  setState(() {
                    _isTermsAccepted = value ?? false;
                  });
                },
                activeColor: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CgvWebViewScreen(),
                    ),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: "J'accepte les ",
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                    children: [
                      TextSpan(
                        text: 'Conditions générales de vente',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isTermsAccepted ? Colors.black : Colors.grey.shade400,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _isTermsAccepted
              ? () {
                  if (AppManager.isLoginAsGuest) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please log in to Continue'),
                      ),
                    );
                    return;
                  }

                  if (_cartModel?.data?.items?.isEmpty ?? true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please add items to your cart first'),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddressScreen(
                        cartId: _cartModel?.data?.id ?? '',
                      ),
                    ),
                  );
                }
              : null,
          child: const Text(
            "CONTINUER →",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    ),
  ),
),

    );
  }

  Widget _buildPriceRow(
    String title,
    String value,
    bool isItalic, {
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchCartItemCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return;
      }

      final cartApi = CartApi(token: token);
      final cartDetails = await cartApi.getCartDetails();

      setState(() {
        cartItemCount = cartDetails.data?.items?.length ?? 0;
      });
    } catch (e) {}
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CONDITIONS GÉNÉRALES DE VENTE',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
            gestureRecognizers: {
              Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
              ),
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
