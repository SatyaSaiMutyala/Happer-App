import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:happer_app/features/profile/data/repositories/purchases_repository.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/features/profile/models/purchase_model.dart';
import 'package:happer_app/features/profile/screens/invoice_webview_screen.dart';
import 'package:happer_app/features/profile/screens/return_refund_screen_new.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class MyPurchasesScreen extends StatefulWidget {
  final bool fromCart;
  const MyPurchasesScreen({super.key, this.fromCart = false});

  @override
  State<MyPurchasesScreen> createState() => _MyPurchasesScreenState();
}

class _MyPurchasesScreenState extends State<MyPurchasesScreen> {
  final _repository = PurchasesRepository();
  final _scrollController = ScrollController();

  final List<PurchasedProduct> _purchases = [];
  bool _isLoading = true;
  bool _hasMore = true;
  bool _isFetchingMore = false;
  String? _errorMessage;
  int _page = 1;
  static const _perPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchPurchases(firstLoad: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _hasMore &&
        !_isFetchingMore) {
      _fetchPurchases();
    }
  }

  Future<void> _fetchPurchases({bool firstLoad = false}) async {
    if (firstLoad) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _page = 1;
        _purchases.clear();
        _hasMore = true;
      });
    } else {
      if (!_hasMore || _isFetchingMore) return;
      setState(() => _isFetchingMore = true);
    }

    try {
      final list = await _repository.getPurchasedProducts(
        page: _page,
        perPage: _perPage,
      );

      setState(() {
        _purchases.addAll(list);
        _hasMore = list.length >= _perPage;
        _page++;
        _isLoading = false;
        _isFetchingMore = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(
        title: 'MES COMMANDES',
        onBack: widget.fromCart
            ? () => Navigator.of(context).popUntil((route) => route.isFirst)
            : null,
        actions: [
          IconButton(
            icon: SvgPicture.asset('assets/images/return_svg.svg',
                width: 20, height: 20),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReturnRefundScreen()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildShimmer()
          : _errorMessage != null
              ? _buildError()
              : _purchases.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context).noPurchasesFound,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 15,
                          color: Color(0xFF8D8D8D),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _fetchPurchases(firstLoad: true),
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount:
                            _purchases.length + (_isFetchingMore ? 1 : 0),
                        separatorBuilder: (_, __) => const Divider(
                            height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                        itemBuilder: (context, index) {
                          if (index == _purchases.length) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return _buildPurchaseCard(_purchases[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildPurchaseCard(PurchasedProduct p) {
    final imageUrl = p.displayImage;
    final formattedDate =
        p.paidAt != null ? DateFormat('dd MMM yyyy').format(p.paidAt!) : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 100,
                    height: 130,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        width: 100, height: 130, color: Colors.grey.shade200),
                    errorWidget: (_, __, ___) => Container(
                      width: 100,
                      height: 130,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 100,
                    height: 130,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand row
                if (p.brand != null)
                  Row(
                    children: [
                      if ((p.brand!.picture ?? '').isNotEmpty) ...[
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: p.brand!.picture!,
                            width: 20,
                            height: 20,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.store, size: 16),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        p.brand!.name,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.8,
                          color: Color(0xFF8D8D8D),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),

                // Product name
                Text(
                  p.product?.name ?? '',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Status + date row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge('PAID'),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 11,
                        color: Color(0xFF8D8D8D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Price
                if (p.displayCompareAtPrice != null &&
                    p.displayCompareAtPrice! > p.displayPrice) ...[
                  Text(
                    '${p.displayCompareAtPrice!.toStringAsFixed(2)} ${p.currency}',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 13,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  '${p.displayPrice.toStringAsFixed(2)} ${p.currency}',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),

                // Qty
                if (p.quantity > 1) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Qté : ${p.quantity}',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      color: Color(0xFF8D8D8D),
                    ),
                  ),
                ],

                // Affiliate
                if (p.affiliate != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if ((p.affiliate!.profileImage ?? '').isNotEmpty)
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: p.affiliate!.profileImage!,
                            width: 18,
                            height: 18,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.person, size: 14),
                          ),
                        )
                      else
                        const Icon(Icons.person,
                            size: 14, color: Color(0xFF8D8D8D)),
                      const SizedBox(width: 4),
                      Text(
                        '@${p.affiliate!.username}',
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 11,
                          color: Color(0xFF8D8D8D),
                        ),
                      ),
                    ],
                  ),
                ],

                // Invoice button
                if (p.invoiceUrl != null && p.invoiceUrl!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            InvoiceWebViewScreen(url: p.invoiceUrl!),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 14, color: Colors.black),
                          SizedBox(width: 5),
                          Text(
                            'Facture',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    switch (status.toUpperCase()) {
      case 'SENT':
        bgColor = Colors.lightBlue;
        break;
      case 'DELIVERED':
        bgColor = Colors.green;
        break;
      default:
        bgColor = Colors.deepPurple;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Lato',
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: 5,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12, width: 80, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 14, width: 140, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 60, color: Colors.white),
                    const SizedBox(height: 10),
                    Container(height: 16, width: 80, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Lato', fontSize: 14, color: Color(0xFF8D8D8D)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () => _fetchPurchases(firstLoad: true),
            child:
                const Text('Réessayer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
