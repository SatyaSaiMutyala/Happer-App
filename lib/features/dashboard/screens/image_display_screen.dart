// lib/screens/camera_flow/image_crop_screen.dart
import 'dart:io';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:happer_app/features/product/api/api_client.dart';
import 'package:happer_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:happer_app/l10n/app_localizations.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  bool isSelected;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.isSelected = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle nested item_id structure from item_users/me endpoint
    final itemData = json['item_id'] ?? json;

    return Product(
      id: itemData['_id'] ?? json['_id'] ?? '',
      name: itemData['name'] ?? json['name'] ?? 'Unknown',
      price: (itemData['price'] ?? json['price'] ?? 0).toDouble(),
      imageUrl: itemData['pictures'] != null &&
              (itemData['pictures'] as List).isNotEmpty
          ? itemData['pictures'][0]
          : json['pictures'] != null && (json['pictures'] as List).isNotEmpty
              ? json['pictures'][0]
              : '',
    );
  }
}

class ImageCropScreen extends StatefulWidget {
  final File imageFile;

  ImageCropScreen({required this.imageFile});

  @override
  _ImageCropScreenState createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  bool _isLoading = true;
  bool _isUploading = false;
  List<Product> _products = [];
  Set<String> _selectedProductIds = {};
  ApiClient apiClient = ApiClient();
  int userType = 0; // Default userType, update this based on actual logic

  @override
  void initState() {
    super.initState();
    _fetchAndStoreUserType();
    _loadUserType();
    _loadUserProducts();
    print(
        'User typeee: ' + userType.toString()); // Print user type for debugging
  }

  Future<void> _fetchAndStoreUserType() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final token = prefs.getString('token');
      if (token != null) {
        final userData = await apiClient.getUserData(token);

        final fetchedUserType =
            userData['users_type'] ?? 0; // Updated to use 'users_type'
        await prefs.setInt('userType', fetchedUserType);
        setState(() {
          userType = fetchedUserType;
        });
      } else {
        setState(() {
          userType = 0;
        });
      }
    } catch (e) {
      setState(() {
        userType = 0;
      });
    }
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getInt('userType') ??
          0; // Fetch userType from shared preferences
    });
  }

  Future<void> _loadUserProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token found');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('Fetching products from API...');
      final productsData = await apiClient.getUserItems(token);
      print('Received ${productsData.length} products from API');
      print('Raw products data: $productsData');

      final products = productsData.map((data) {
        print('Parsing product: $data');
        final product = Product.fromJson(data);
        print(
            'Parsed product: id=${product.id}, name=${product.name}, price=${product.price}, imageUrl=${product.imageUrl}');
        return product;
      }).toList();

      print('Total products parsed: ${products.length}');

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleProductSelection(Product product) {
    setState(() {
      product.isSelected = !product.isSelected;
      if (product.isSelected) {
        _selectedProductIds.add(product.id);
      } else {
        _selectedProductIds.remove(product.id);
      }
    });
  }

  Future<void> _uploadSelfie() async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).authErrorLogin)),
        );
        return;
      }

      final imageBytes = await widget.imageFile.readAsBytes();
      final success = await apiClient.uploadSelfie(
        token,
        imageBytes,
        _selectedProductIds.toList(),
      );

      setState(() {
        _isUploading = false;
      });

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).selfieUploadSuccess)),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen(refreshAfterUpload: true)),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).selfieUploadFailed)),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error uploading selfie: ${e.toString().substring(0, Math.min(e.toString().length, 100))}',
          ),
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    if (_isUploading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: HapperAppBar(title: AppLocalizations.of(context).sharePhotoTitle),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Image with grid overlay
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Stack(
                      children: [
                        // Image
                        Image.file(
                          widget.imageFile,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        // Grid overlay
                        CustomPaint(
                          size: Size(double.infinity, double.infinity),
                          painter: GridPainter(),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (userType == 1) ...[
                          Text(
                            'Select Extra Products',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : _buildProductList(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Share button at the bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _uploadSelfie,
              child: Text(AppLocalizations.of(context).shareButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (userType == 0) {
      return Center(
          child: Text(AppLocalizations.of(context).productsNotAvailable));
    }

    if (_products.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context).noProductAvailable));
    }

    return Container(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Container(
            width: 150,
            margin: EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              height: 150,
                              width: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  width: 110,
                                  color: Colors.grey.shade300,
                                  child:
                                      Icon(Icons.image_not_supported, size: 40),
                                );
                              },
                            )
                          : Container(
                              height: 150,
                              width: 110,
                              color: Colors.grey.shade300,
                              child: Icon(Icons.image_not_supported, size: 40),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 12,
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _toggleProductSelection(product),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: product.isSelected
                                ? Colors.black
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                          child: product.isSelected
                              ? Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  product.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${product.price.toStringAsFixed(2)}€',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.0;

    // Draw horizontal lines
    for (int i = 1; i < 3; i++) {
      double y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (int i = 1; i < 3; i++) {
      double x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
