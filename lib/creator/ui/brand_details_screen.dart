import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/creator/api/cart_api.dart';
import 'package:happer_app/creator/api/creator_api.dart';
import 'package:happer_app/creator/model/items_model.dart';
import 'package:happer_app/creator/ui/product_details_screen.dart';
import 'package:happer_app/dashboard/screens/cart_screen.dart';
import 'package:happer_app/utils/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class BrandDetailsScreen extends StatefulWidget {
  final String brandId;
  final String brandName;
  final String brandDescription;
  final String brandLogo;

  const BrandDetailsScreen({
    super.key,
    required this.brandId,
    required this.brandName,
    required this.brandDescription,
    required this.brandLogo,
  });

  @override
  _BrandDetailsScreenState createState() => _BrandDetailsScreenState();
}

class _BrandDetailsScreenState extends State<BrandDetailsScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreItems = true;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  List<ItemsModel> _brandItems = [];
  int cartItemCount = 0; // Track the number of items in the cart

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _init();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Trigger loading when 200px from bottom for smoother experience
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMoreItems && !_isLoadingMore) {
        _loadMoreItems();
      }
    }
  }

  Future<void> _init() async {
    await _fetchBrandItems();
    await _fetchCartItemCount();
  }

  // Method to fetch the cart count
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
    } catch (e) {
      print('Error fetching cart count: $e');
    }
  }

  Future<void> _fetchBrandItems() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final service = CreatorApiService(token: token);

    try {
      final response = await service.fetchBrandAllItems(widget.brandId);
      setState(() {
        _brandItems = response.items;
        _isLoading = false;
        _hasMoreItems = response.items.length >= _itemsPerPage;
      });
    } catch (error) {
      print('Error fetching brand items: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoadingMore || !_hasMoreItems) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final service = CreatorApiService(token: token);
      final nextPage = _currentPage + 1;

      final response = await service.fetchBrandAllItems(
        widget.brandId,
        page: nextPage,
        limit: _itemsPerPage,
      );

      if (response.items.isNotEmpty) {
        setState(() {
          _brandItems.addAll(response.items);
          _currentPage = nextPage;
          _hasMoreItems = response.items.length >= _itemsPerPage;
        });
      } else {
        setState(() {
          _hasMoreItems = false;
        });
      }
    } catch (error) {
      print('Error loading more items: $error');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient area
            Container(height: 80, color: Colors.white),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand logo circle
                    const CircleAvatar(radius: 40, backgroundColor: Colors.white),
                    const SizedBox(height: 16),
                    // Brand name
                    Container(height: 16, width: 140, color: Colors.white),
                    const SizedBox(height: 8),
                    // Description lines
                    Container(height: 12, width: double.infinity, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 12, width: 200, color: Colors.white),
                    const SizedBox(height: 32),
                    // Products count
                    Container(height: 12, width: 80, color: Colors.white),
                    const SizedBox(height: 20),
                    // Product grid shimmer (2 columns)
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image placeholder
                              Container(
                                height: 180,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(height: 14, width: 100, color: Colors.white),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  Widget _buildProductCard(ItemsModel item) {
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('myId') ?? '';

        if (!context.mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              itemId: item.id,
              userId: userId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: item.pictures.isNotEmpty
                        ? item.pictures.first
                        : '',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                  ),
                ),
                // Brand Logo overlay
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.brandLogo,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.store,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                // Price tag
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${item.price.toStringAsFixed(0)}€',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'LA COLLECTION',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.0,
            letterSpacing: 0.0,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              if (AppManager.isLoginAsGuest) {
                showAppSnackBar('Please Login to access Cart',
                    isSuccess: false);
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              ).then((_) {
                // Refresh cart count when returning from cart screen
                _fetchCartItemCount();
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/b2bag.png',
                    width: 24,
                    height: 24,
                    color: Colors.black,
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      top: 0,
                      right: -1,
                      child: Visibility(
                        visible: cartItemCount > 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            "$cartItemCount",
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildShimmerLoading()
          : SingleChildScrollView(
              controller: _scrollController, // Attach scroll controller here
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Black gradient section (from first code)
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Brand Logo (overlapping gradient) - from first code
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand Info Section with padding - from first code
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: widget.brandLogo,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.shade200,
                                    ),
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.image,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Brand Name - from first code
                              Text(
                                widget.brandName.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Brand Description - from first code
                              Text(
                                widget.brandDescription,
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12,
                                  color: Color(0xFFAAAAAA),
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),

                        // Products Count - from second code
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '${_brandItems.length} products',
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF8D8D8D),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Products Grid - from second code (but using SingleChildScrollView)
                        RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              _currentPage = 1;
                              _brandItems.clear();
                              _isLoading = true;
                              _hasMoreItems = true;
                            });
                            await _fetchBrandItems();
                          },
                          child: Column(
                            children: [
                              // Products Grid
                              GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: _brandItems.length,
                                itemBuilder: (context, index) {
                                  return _buildProductCard(_brandItems[index]);
                                },
                              ),
                              
                              // Loading shimmer cards for pagination
                              if (_isLoadingMore)
                                Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 0.75,
                                    ),
                                    itemCount: 4,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 180,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8),
                                                  topRight: Radius.circular(8),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Container(height: 14, width: 100, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              
                              // End of list message
                              if (!_hasMoreItems && _brandItems.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      'No more products',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              
                              // Empty state
                              if (!_isLoading && _brandItems.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inventory_outlined,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No products available',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Check back later for new arrivals',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}