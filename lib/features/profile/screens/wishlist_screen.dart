import 'package:flutter/material.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:happer_app/features/profile/models/wishlist_model.dart';
import 'package:happer_app/l10n/app_localizations.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late Future<List<WishlistItem>> _wishlistItems;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWishlistItems();
  }

  Future<void> _loadWishlistItems() async {
  setState(() {
    _isLoading = true;
  });

  setState(() {
    _wishlistItems = Future.value([]);
    _isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(title: AppLocalizations.of(context).wishlistTitle),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF465A)),
              ),
            )
          : FutureBuilder<List<WishlistItem>>(
              future: _wishlistItems,
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
                          'Error loading wishlist items',
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
                          onPressed: _loadWishlistItems,
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
                        Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Your wishlist is empty',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Items you add to your wishlist will appear here',
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
                  padding: EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildWishlistItem(context, item);
                  },
                );
              },
            ),
    );
  }  Widget _buildWishlistItem(BuildContext context, WishlistItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand name in uppercase
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              item.brand.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // Product image and details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with heart icon overlay
              Stack(
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: item.imageURL.isNotEmpty
                        ? Image.network(
                            item.imageURL,
                            width: 150,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          )
                        : _buildPlaceholderImage(),
                  ),
                  
                  // Heart icon overlay
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.favorite,
                        color: Color(0xFFFF465A),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(width: 16),
              
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product title
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Original price label
                    Row(
                      children: [
                        Text(
                          'Prix réel',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            color: Colors.grey[600],
                          ),
                        ),
                       // Original price
                        SizedBox(width: 6),
                        Text(
                          '${item.price.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                            decoration: item.pricePromo != null ? TextDecoration.lineThrough : null,
                            color: item.pricePromo != null ? Colors.grey[600] : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    
                    // Promo price if available
                    if (item.pricePromo != null) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Prix PROMO',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Inter',
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${item.pricePromo!.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                              color: Color(0xFFFF465A),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    SizedBox(height: 16),
                    
                    // Wishlist button (as shown in screenshot)
                    Container(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          // Already in wishlist - showing check mark as in screenshot
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Item is already in your wishlist'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'WISHLIST',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: 1,
                                fontFamily: 'Inter',
                                color: Colors.white
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.check, size: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }
  // Removed _happerProduct function as it's not needed for the wishlist UI
  
  Widget _buildPlaceholderImage() {
    return Container(
      width: 150,
      height: 180,
      color: Colors.white,
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[400],
          size: 30,
        ),
      ),
    );
  }
}
