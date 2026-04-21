// import 'package:flutter/material.dart';
// import 'package:happer_app/features/creator/screens/product_details_screen.dart';
// import 'package:happer_app/features/creator/api/creator_api.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ShopTheStyleScreen extends StatefulWidget {
//   final String selfieId;
//   final String categoryId; // Added categoryId field

//   const ShopTheStyleScreen({
//     super.key,
//     required this.selfieId,
//     required this.categoryId, // Initialize categoryId
//   });

//   @override
//   State<ShopTheStyleScreen> createState() => _ShopTheStyleScreenState();
// }

// class _ShopTheStyleScreenState extends State<ShopTheStyleScreen> {
//   List<dynamic> _products = []; // Store fetched products
//   bool _isLoading = true; // Loading state

//   @override
//   void initState() {
//     super.initState();

//     // Directly call fetchCreatorProductDetails in initState
//     _fetchCreatorProductDetails();
//   }

//   void _fetchCreatorProductDetails() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');

//       if (token == null || token.isEmpty) {
    
//         return;
//       }

//       final apiService = CreatorApiService(token: token);
//       final products = await apiService.fetchCreatorProductDetails(
//         widget.categoryId,
//       );

//       setState(() {
//         _products = products.map((product) {
//           return {
//             'imageUrl': product['imageUrl'],
//             'price': product['price'],
//             'name': product['name'] ?? 'Unknown',
//             'createdAt': product['created_at'] ?? DateTime.now().toIso8601String(),
//             'exactMatch': product['exact_match'] ?? false,
//             'isLiked': false, // Initialize like state
//             'likeCount': 0, // Initialize like count
//           };
//         }).toList();
//         _isLoading = false;
//       });
//     } catch (e) {
      
//       setState(() {
//         _isLoading = false; // Stop loading even on error
//       });
//     }
//   }

//   void _toggleLike(int index) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     if (token == null || token.isEmpty) return;
//     final apiService = CreatorApiService(token: token);
//     final product = _products[index];
//     bool isLiked = product['isLiked'] ?? false;
//     int likeCount = product['likeCount'] ?? 0;
//     final productId = product['id'] ?? product['productId'] ?? product['sId'];
//     if (productId == null) return;
//     try {
//       if (isLiked) {
//         await apiService.dislikeSelfie(productId);
//         likeCount = (likeCount - 1).clamp(0, 999999);
//       } else {
//         await apiService.likeSelfie(productId);
//         likeCount = likeCount + 1;
//       }
//       setState(() {
//         _products[index]['isLiked'] = !isLiked;
//         // Only update likeCount if the API call was successful and the heart icon was tapped
//         _products[index]['likeCount'] = likeCount;
//       });
//     } catch (e) {
     
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         centerTitle: true,
//         title: Text(
//           "SHOP THE STYLE",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _products.isEmpty
//               ? Center(child: Text('No products found.'))
//               : ListView.builder(
//                   itemCount: _products.length,
//                   itemBuilder: (context, index) {
//                     final product = _products[index];
//                     return _buildProductItem(
//                       context,
//                       product['imageUrl'],
//                       product['price'],
//                       product['name'],
//                       product['createdAt'],
//                       product['exactMatch'],
//                       index: index,
//                     );
//                   },
//                 ),
//     );
//   }

//   Widget _buildProductItem(
//     BuildContext context,
//     String imageUrl,
//     String price,
//     String name,
//     String createdAt,
//     bool exactMatch, {
//     int? index,
//   }) {
//     final isLiked = index != null ? (_products[index]['isLiked'] ?? false) : false;
//     final likeCount = index != null ? (_products[index]['likeCount'] ?? 0) : 0;
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.network(
//               imageUrl,
//               width: double.infinity,
//               height: 200,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) => Icon(
//                 Icons.broken_image,
//                 size: 100,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           SizedBox(height: 10),
//           Text(
//             name,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             price,
//             style: TextStyle(
//               color: Colors.green,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             _getTimeDifference(createdAt),
//             style: TextStyle(
//               color: Colors.grey,
//               fontSize: 14,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             exactMatch ? 'Exact Match: True' : 'Exact Match: False',
//             style: TextStyle(
//               color: Colors.blue,
//               fontSize: 14,
//             ),
//           ),
//           Row(
//             children: [
//               IconButton(
//                 icon: Icon(
//                   isLiked ? Icons.favorite : Icons.favorite_border,
//                   color: isLiked ? Colors.red : Colors.grey,
//                 ),
//                 onPressed: index != null ? () => _toggleLike(index) : null,
//               ),
//               Text('$likeCount'),
//             ],
//           ),
//           Divider(thickness: 1, color: Colors.grey[300]),
//         ],
//       ),
//     );
//   }

//   String _getTimeDifference(String createdAt) {
//     final createdTime = DateTime.parse(createdAt);
//     final currentTime = DateTime.now();
//     final difference = currentTime.difference(createdTime);

//     if (difference.inMinutes < 1) {
//       return 'Just Now';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes} min ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours} hours ago';
//     } else if (difference.inDays <= 7) {
//       return '${difference.inDays} days ago';
//     } else {
//       return '${createdTime.day}/${createdTime.month}/${createdTime.year}';
//     }
//   }
// }
