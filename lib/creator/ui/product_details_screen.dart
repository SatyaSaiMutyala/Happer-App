import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/creator/api/cart_api.dart';
import 'package:happer_app/creator/api/creator_api.dart';
import 'package:happer_app/creator/model/items_model.dart'; // Import the Product model
import 'package:happer_app/dashboard/screens/cart_screen.dart';
import 'package:happer_app/providers/cart_provider.dart';
import 'package:happer_app/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:happer_app/profile/api/profile_api.dart' as profile;
import 'package:happer_app/profile/ui/image_grid_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String itemId; // Changed to String to match the expected type
  final String userId;
  // Add this field to hold the product data

  const ProductDetailsScreen({
    Key? key,
    required this.itemId, // Changed to accept only itemId
    required this.userId,
    // Add this parameter to pass product data
  }) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Map<String, dynamic> selectedOptions = {'size': null, 'color': null};
  int _currentPage = 0; // Add this state variable
  ItemsModel? itemDetails; // Add a state variable to hold item details
  int cartItemCount = 0; // Track the number of items in the cart
  String? _creatorName;
  String? _creatorPicture;
  String? _creatorId;

  @override
  void initState() {
    super.initState();
    _fetchTokenAndCartDetails();
    _fetchItemDetails(); // Call fetchItemDetails API function
    _fetchCreatorProfile();
  }

  @override
  void didUpdateWidget(ProductDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-select the product's color when details are loaded
    if (itemDetails?.colorOfProduct != null &&
        selectedOptions['color'] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedOptions['color'] =
              _capitalizeFirstLetter(itemDetails!.colorOfProduct!);
        });
      });
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    // Trim whitespace and handle case normalization
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
  }

  void _fetchTokenAndCartDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      return;
    }

    // Fetch the cart details to get the item count
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
    } catch (e) {}
  }

  Future<void> _fetchCreatorProfile() async {
    if (widget.userId.isEmpty) return;
    try {
      final profileApi = profile.ProfileApiService();
      final data = await profileApi.fetchUserProfile(widget.userId);
      setState(() {
        _creatorName = data['user_name'] ?? data['first_name'] ?? '';
        _creatorPicture = data['picture'] ?? '';
        _creatorId = data['_id'] ?? widget.userId;
      });
    } catch (e) {
      debugPrint('Error fetching creator profile: $e');
    }
  }

  void _fetchItemDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return;
      }

      final creatorApiService = CreatorApiService(token: token);
      final item = await creatorApiService.fetchItemDetails(
        widget.itemId,
      ); // Use itemId directly

      setState(() {
        itemDetails = item; // Update the state with fetched item details
        // Auto-select the product's color
        if (item.colorOfProduct != null) {
          selectedOptions['color'] =
              _capitalizeFirstLetter(item.colorOfProduct!);
        }
      });
    } catch (e) {}
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
          onPressed: () {
            Navigator.pop(context);
            _fetchCartItemCount(); // Refresh cart count when returning
          },
        ),
        title: const Text(
          "DÉTAILS PRODUIT",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.0,
            letterSpacing: 0.0,
          ),
        ),
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
              padding: EdgeInsets.only(right: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Icon(
                  //   Icons.shopping_bag_outlined,
                  //   size: 24,
                  //   color: Colors.black,
                  // ),

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
                          // padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            "$cartItemCount",
                            style: TextStyle(
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildImageCarousel(),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemDetails?.brandId?.name ??
                            'Unknown Brand', // Display brand name
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        itemDetails?.name ??
                            'Unknown Item', // Display product name
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 5),
                      // Text(
                      //   itemDetails?.description ??
                      //       'No description available', // Use itemDetails to display the description
                      //   style: TextStyle(color: Colors.grey, fontSize: 14),
                      // ),
                      if ((itemDetails?.description ?? '').isNotEmpty)
                        ExpandableDescription(text: itemDetails?.description!),
                      SizedBox(height: 10),
                      Text(
                        '${itemDetails?.price.toStringAsFixed(0) ?? '0'}€', // Use itemDetails to display the price
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 20),
                      // Color Selection Section
                      if (itemDetails?.colorOfProduct != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SELECTION COULEUR',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            _buildColorSelector(),
                            SizedBox(height: 20),
                          ],
                        ),
                      Text(
                        // "SELECT SIZE",
                        'SELECTION TAILLE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: itemDetails?.sizeOfProduct.keys
                                .map((size) => _buildSizeChip(size))
                                .toList() ??
                            [],
                      ),
                      SizedBox(height: 20),
                      if (itemDetails?.brandId?.name != null &&
                          itemDetails!.brandId!.name.isNotEmpty)
                        Text(
                          'Vendu par ${itemDetails!.brandId!.name}',
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            color: Color(0xFF8D8D8D),
                          ),
                        ),
                      Divider(),
                      if (_creatorName != null && _creatorName!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: GestureDetector(
                            onTap: () {
                              if (_creatorId != null && _creatorId!.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageGridScreen(
                                      userId: _creatorId!,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: (_creatorPicture != null && _creatorPicture!.isNotEmpty)
                                      ? CachedNetworkImageProvider(_creatorPicture!)
                                      : null,
                                  child: (_creatorPicture == null || _creatorPicture!.isEmpty)
                                      ? const Icon(Icons.person, size: 20)
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 14,
                                        color: Color(0xFF8D8D8D),
                                        fontStyle: FontStyle.italic,
                                      ),
                                      children: [
                                        const TextSpan(text: 'Ce produit a été sélectionné par '),
                                        TextSpan(
                                          text: _creatorName!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Divider(),
                      SizedBox(height: 100), // Extra space before fixed button
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (selectedOptions['size'] != null &&
                          (itemDetails?.colorOfProduct == null ||
                              selectedOptions['color'] != null))
                      ? Colors.black
                      : Colors.grey.shade300,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (AppManager.isLoginAsGuest) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(
                    //     content: Text('Please log in to Add to Cart'),
                    //   ),
                    // );
                    showAppSnackBar('Please Login to Add to Cart',
                        isSuccess: false);
                    return;
                  }
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('token');

                  if (token == null || token.isEmpty) {
                    print('Token is null or empty ----> ${token}');
                    return;
                  }

                  final cartApi = CartApi(token: token);
                  try {
                    print('this is try block of add to cart');
                    // Add to cart using API
                    await cartApi.addToCart(
                      itemId: itemDetails?.id ?? '',
                      quantity: 1,
                      size: selectedOptions['size'] ?? '',
                      userId: widget.userId,
                    );

                    // Navigate to the cart screen immediately after adding the item
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    ).then((_) {
                      // Refresh cart count when returning
                      _fetchCartItemCount();
                    });

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Item added to cart successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    // Show error message to user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Failed to add item to cart: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    print('ERROR adding to cart: $e');
                  }
                },
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: (selectedOptions['size'] != null &&
                          (itemDetails?.colorOfProduct == null ||
                              selectedOptions['color'] != null))
                      ? Colors.white
                      : Colors.black,
                ),
                label: Text(
                  // "ADD TO CART",
                  'AJOUTER AU PANIER',
                  style: TextStyle(
                    color: (selectedOptions['size'] != null &&
                            (itemDetails?.colorOfProduct == null ||
                                selectedOptions['color'] != null))
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final pictures = itemDetails?.pictures ?? [];

    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: 490,
              width: double.infinity,
              child: PageView.builder(
                itemCount: pictures.length,
                itemBuilder: (context, index) {
                  return PinchZoom(
                    maxScale: 4.0,
                    child: Image.network(
                      pictures[index],
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  );
                },
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
              ),
            ),

            /// Brand logo overlay
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    itemDetails?.brandId?.picture ?? '',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.store, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDotsIndicator(pictures.length),
      ],
    );
  }

  Widget _buildDotsIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 10 : 6,
          height: _currentPage == index ? 10 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.black : Colors.grey,
          ),
        );
      }),
    );
  }

  Widget _buildColorSelector() {
    // Map of color names to their Color objects
    final Map<String, Color> colorMap = {
      'black': Colors.black,
      'white': Colors.white,
      'blue': Color(0xFF0000FF),
      'gray': Color(0xFF5A5A5A),
      'grey': Color(0xFF5A5A5A),
      'gold': Color(0xFFD4AF37),
      'red': Colors.red,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'brown': Colors.brown,
    };

    // Get the product's color and normalize it
    final productColor = itemDetails?.colorOfProduct ?? '';
    final colorKey = productColor.trim().toLowerCase();
    final colorValue = colorMap[colorKey] ?? Colors.grey;
    final colorName = _capitalizeFirstLetter(productColor);
    final isSelected = selectedOptions['color'] == colorName;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOptions['color'] = colorName;
        });
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colorValue,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: colorValue == Colors.white ||
                        colorValue == Color(0xFFD4AF37) ||
                        colorValue == Colors.yellow
                    ? Colors.black
                    : Colors.white,
                size: 24,
              )
            : null,
      ),
    );
  }

  Widget _buildSizeChip(String size) {
    final isAvailable = itemDetails!.sizeOfProduct[size]! > 0;
    return ChoiceChip(
      color: MaterialStateProperty.all<Color>(Colors.white),
      label: Text(
        size,
        style: TextStyle(
          color: isAvailable ? Colors.black : Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      selected: selectedOptions['size'] == size,
      onSelected: isAvailable
          ? (isSelected) {
              setState(() {
                if (isSelected) {
                  selectedOptions['size'] = size;
                } else {
                  selectedOptions['size'] = null;
                }
              });
            }
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isAvailable ? Colors.black : Colors.grey),
      ),
      backgroundColor: Colors.white,
      selectedColor: Colors.black,
    );
  }
}

class DotsIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: index == 0 ? 10 : 6,
          height: index == 0 ? 10 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == 0 ? Colors.black : Colors.grey,
          ),
        );
      }),
    );
  }
}

class ExpandableDescription extends StatefulWidget {
  final String? text;

  const ExpandableDescription({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription>
    with TickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final String displayText = widget.text?.trim().isNotEmpty == true
        ? widget.text!
        : 'No description available';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Text(
            displayText,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Row(
            children: [
              Text(
                _expanded ? 'Voir moins' : 'Voir plus',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.black,
                size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
