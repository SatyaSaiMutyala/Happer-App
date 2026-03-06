import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:happer_app/profile/api/profile_api.dart';
import 'package:happer_app/profile/model/purchase_model.dart';
import 'package:happer_app/profile/ui/return_refund_screen.dart';
import 'package:happer_app/profile/ui/invoice_viewer_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MyPurchasesScreen extends StatefulWidget {
  const MyPurchasesScreen({super.key});

  @override
  State<MyPurchasesScreen> createState() => _MyPurchasesScreenState();
}

class _MyPurchasesScreenState extends State<MyPurchasesScreen> {
  final ProfileApiService _profileApiService = ProfileApiService();
 
  bool _isLoading = true;
  String? _errorMessage;
  List<Datum> _orders =[];

  @override
  void initState() {
    super.initState();
    _fetchPurchases();
  }

  Future<void> _fetchPurchases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

   try {
  final allData = await _profileApiService.fetchUserPurchases();
// Sort orders by paidOn (or createdAt if paidOn is null), most recent first
allData.sort((a, b) {
  final aDate = a.paidOn ?? a.createdAt;
  final bDate = b.paidOn ?? b.createdAt;
  if (aDate == null && bDate == null) return 0;
  if (aDate == null) return 1;
  if (bDate == null) return -1;
  return bDate.compareTo(aDate); // Descending order
});
setState(() {
  _orders = allData;
  _isLoading = false;
});
  setState(() {
    _orders = allData;
    _isLoading = false;
  });
} catch (e) {
  setState(() {
    _errorMessage = 'Failed to load purchases: $e';
    _isLoading = false;
  });
}

  }

 Widget _buildStatusBadge(String? status) {
  Color bgColor;
  String displayStatus = (status ?? 'PAID').isNotEmpty ? status! : 'PAID';
  switch (displayStatus.toUpperCase()) {
    case 'SENT':
      bgColor = Colors.lightBlue;
      break;
    case 'DELIVERED':
      bgColor = Colors.green;
      break;
    case 'PAID':
      bgColor = Colors.deepPurple;
      break;
    default:
      bgColor = Colors.deepPurple;
      displayStatus = 'PAID'; // Default status is PAID
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      displayStatus.toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}
 Widget _buildItemCard(Item item) {
  final imageUrl = item.itemId?.pictures?.isNotEmpty == true
      ? item.itemId!.pictures!.first
      : null;
DateTime? paidOnDate;
  for (final order in _orders) {
    if (order.items != null && order.items!.contains(item)) {
      paidOnDate = order.paidOn;
      break;
    }
  }
  String? formattedPaidOn;
  if (paidOnDate != null) {
    formattedPaidOn = DateFormat('dd MMM yyyy').format(paidOnDate);
  }
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with PDF Icon in Stack
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 100,
                      height: 130,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 100,
                      height: 130,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 40),
                    ),
            ),
            if ((item.invoiceLink ?? '').isNotEmpty)
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => _openInvoiceInApp(item.invoiceLink!),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand or Subtitle
              Text(
                item.itemId?.subtitle ?? item.name ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),

              // Description
              if ((item.itemId?.description ?? '').isNotEmpty)
                Text(
                  item.itemId!.description!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),

              const SizedBox(height: 6),

              // Status Badge (shown below description)
              
                // Status Badge and Paid On Date in the same row
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    _buildStatusBadge(item.status),
    if (formattedPaidOn != null) ...[
      const SizedBox(width: 8),
      Text(
        formattedPaidOn,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    ],
  ],
),

              const SizedBox(height: 10),

              // Real Price
              Row(
                children: [
                  const Text('Prix réel',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(width: 8),
                  Text(
                    '${((item.price ?? 0) * 1.15).toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Promo Price
              Row(
                children: [
                  const Text('Prix PROMO',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(
                    '${(item.price ?? 0).toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Delivery Button
              if ((item.deliveryLink ?? '').isNotEmpty)
                ElevatedButton(
                  onPressed: () => _launchUrl(item.deliveryLink!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text("DELIVERY DETAILS"),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

 Widget _buildOrderCard(Datum order) {
  final firstItem = order.items?.isNotEmpty == true ? order.items!.first : null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (firstItem != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            firstItem.name?.toUpperCase() ?? 'PRODUCT',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ...order.items!.map((item) => _buildItemCard(item)).toList(),
      const Divider(thickness: 1, height: 30),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text(
      //     'MY ORDER',
      //     style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: Colors.white,
      //   elevation: 1,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.black),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      // ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MES COMMANDES',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.0,
            letterSpacing: 0.0,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/images/return_svg.svg',
              width: 20,
              height: 20,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReturnRefundScreen(),
                ),
              );
            },
          ),
          SizedBox(width: 10,)
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _orders.isEmpty
                  ? const Center(child: Text('No purchases found.'))
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(_orders[index]);
                      },
                    ),
    );
  }
  
  // Open invoice PDF in-app using custom viewer
  void _openInvoiceInApp(String url) {
    // Find the order title for the invoice
    String? orderTitle;
    for (final order in _orders) {
      if (order.items != null) {
        for (final item in order.items!) {
          if (item.invoiceLink == url) {
            orderTitle = item.name ?? item.itemId?.subtitle;
            break;
          }
        }
      }
      if (orderTitle != null) break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceViewerScreen(
          invoiceUrl: url,
          orderTitle: orderTitle,
        ),
      ),
    );
  }

  // Open delivery tracking link in external browser
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link')),
        );
      }
    }
  }

}
