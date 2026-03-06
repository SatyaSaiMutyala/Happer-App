import 'package:flutter/material.dart';
import 'package:happer_app/profile/api/won_products_api.dart';
import 'package:happer_app/profile/model/won_product_model.dart';

class WonProductsScreen extends StatefulWidget {
  const WonProductsScreen({Key? key}) : super(key: key);

  @override
  _WonProductsScreenState createState() => _WonProductsScreenState();
}

class _WonProductsScreenState extends State<WonProductsScreen> {
  late Future<List<WonProduct>> _wonProducts;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWonProducts();
  }

  Future<void> _loadWonProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final api = WonProductsApiService();
      _wonProducts = api.getWonProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load won products: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'WON PRODUCTS',
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
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF465A)),
              ),
            )
          : FutureBuilder<List<WonProduct>>(
              future: _wonProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF465A)),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Error loading won products',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadWonProducts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'You haven\'t won any products yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Participate in contests to win amazing products',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final items = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 24),
                          child: _buildWonProductItem(item),
                        ),
                        if (index < items.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFEEEEEE),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildWonProductItem(WonProduct product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.brand.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: 0.7,
            height: 1.2,
          ),
        ),
        SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                product.imageURL,
                width: 120,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 150,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
            SizedBox(width: 16),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  // Winner name with shopping bag icon
                  Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.black87),
                      SizedBox(width: 4),
                      Text(
                        product.winnerName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Original price
                  Row(
                    children: [
                      Text(
                        'Prix réel',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                       Text(
                    '${product.priceOriginal.toStringAsFixed(2)}€',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.black54,
                    ),
                  ),
                    ],
                  ),
                 
                  SizedBox(height: 8),
                  // Promo price
                  Row(
                    children: [
                      Text(
                        'Prix PROMO',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                    '${product.pricePromo?.toStringAsFixed(2) ?? product.priceOriginal.toStringAsFixed(2)}€',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                 
                    ],
                  ),
                   SizedBox(height: 16),
                  // RÉCUPÉRÉ button
                  Container(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE0E0E0),
                        disabledBackgroundColor: Color(0xFFE0E0E0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        'RÉCUPÉRÉ',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
