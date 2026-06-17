import 'package:flutter/material.dart';
import 'package:happer_app/features/profile/screens/wishlist_screen.dart';

class ProductWishlistButton extends StatefulWidget {
  final String productId;
  final bool isInWishlist;

  const ProductWishlistButton({
    Key? key,
    required this.productId,
    this.isInWishlist = false,
  }) : super(key: key);

  @override
  _ProductWishlistButtonState createState() => _ProductWishlistButtonState();
}

class _ProductWishlistButtonState extends State<ProductWishlistButton> {
  late bool _isInWishlist;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isInWishlist = widget.isInWishlist;
  }

  Future<void> _toggleWishlist() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    // Dummy: optimistic toggle
    setState(() {
      _isInWishlist = !_isInWishlist;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isInWishlist ? 'Added to wishlist' : 'Removed from wishlist'),
          action: SnackBarAction(
            label: 'VIEW WISHLIST',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => WishlistScreen()),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _toggleWishlist,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Icon(_isInWishlist ? Icons.favorite : Icons.favorite_border, size: 20),
            const SizedBox(width: 8),
            const Text('WISHLIST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
            if (_isInWishlist) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
