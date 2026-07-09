import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:happer_app/features/profile/data/repositories/purchases_repository.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/features/profile/models/purchase_model.dart';
import 'package:happer_app/features/profile/screens/invoice_webview_screen.dart';
import 'package:happer_app/features/profile/screens/order_detail_screen.dart';
import 'package:happer_app/features/profile/screens/return_refund_screen_new.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:flutter_svg/svg.dart';
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
        // actions: [
        //   IconButton(
        //     icon: SvgPicture.asset('assets/images/return_svg.svg',
        //         width: 20, height: 20),
        //     onPressed: () => Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (_) => const ReturnRefundScreen()),
        //     ),
        //   ),
        // ],
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
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
                        itemCount:
                            _purchases.length + (_isFetchingMore ? 1 : 0),
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          if (index == _purchases.length) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final purchase = _purchases[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailScreen(order: purchase),
                              ),
                            ),
                            child: _buildPurchaseCard(purchase),
                          );
                        },
                      ),
                    ),
    );
  }

  // Formats a price in the French style, e.g. 789.0 -> "789,00 €".
  String _formatPrice(double value, String currency) {
    final symbol = currency.toUpperCase() == 'EUR' ? '€' : currency;
    return '${value.toStringAsFixed(2).replaceAll('.', ',')} $symbol';
  }

  void _openDeliveryLink(PurchasedProduct p) {
    final link = (p.deliveryLink != null && p.deliveryLink!.isNotEmpty)
        ? p.deliveryLink!
        : (p.invoiceUrl ?? '');
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lien de livraison indisponible')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InvoiceWebViewScreen(url: link)),
    );
  }

  Widget _buildPurchaseCard(PurchasedProduct p) {
    final imageUrl = p.displayImage;
    final brandName = (p.brand?.name ?? '').toUpperCase();
    final brandLogo = p.brand?.picture ?? '';
    final hasPromo = p.displayCompareAtPrice != null &&
        p.displayCompareAtPrice! > p.displayPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Brand heading above the card ──────────────────────────────────
        if (brandName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              brandName,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.2,
                color: Colors.black,
              ),
            ),
          ),

        // ── Card ──────────────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive image: scales with the card width, clamped so it
              // never gets tiny on small phones or huge on tablets.
              final imgW = (constraints.maxWidth * 0.36).clamp(96.0, 160.0);
              final imgH = imgW * 1.3;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: imgW,
                            height: imgH,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                                width: imgW,
                                height: imgH,
                                color: Colors.grey.shade100),
                            errorWidget: (_, __, ___) => Container(
                              width: imgW,
                              height: imgH,
                              color: Colors.grey.shade100,
                              child:
                                  const Icon(Icons.image, color: Colors.grey),
                            ),
                          )
                        : Container(
                            width: imgW,
                            height: imgH,
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 14),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + brand logo (top-right)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                p.product?.name ?? '',
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  height: 1.3,
                                  color: Color(0xFF1A1A1A),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (brandLogo.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 46,
                                height: 28,
                                child: CachedNetworkImage(
                                  imageUrl: brandLogo,
                                  fit: BoxFit.contain,
                                  errorWidget: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Status badge
                        _buildStatusBadge(p.orderStatus),
                        const SizedBox(height: 12),

                        const Divider(
                            height: 1, thickness: 1, color: Color(0xFFEDEDED)),
                        const SizedBox(height: 10),

                        // Prix réel (struck-through original price)
                        if (hasPromo)
                          Row(
                            children: [
                              const Text(
                                'Prix réel  ',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 13,
                                  color: Color(0xFF8D8D8D),
                                ),
                              ),
                              Text(
                                _formatPrice(
                                    p.displayCompareAtPrice!, p.currency),
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8D8D8D),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        if (hasPromo) const SizedBox(height: 4),

                        // Prix PROMO (or plain price when there's no discount)
                        Row(
                          children: [
                            Text(
                              hasPromo ? 'Prix PROMO ' : 'Prix ',
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              _formatPrice(p.displayPrice, p.currency),
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // LIEN LIVRAISON button
                        GestureDetector(
                          onTap: () => _openDeliveryLink(p),
                          child: Container(
                            width: double.infinity,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'LIEN LIVRAISON',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: 0.3,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Maps an order status to its French label + colour, matching the design:
  // CONFIRMÉE (purple), EXPÉDIÉE (blue), LIVRÉ (green).
  (String, Color) _statusStyle(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('livr') || s.contains('deliver')) {
      return ('LIVRÉ', const Color(0xFF1FA463));
    }
    if (s.contains('exp') ||
        s.contains('ship') ||
        s.contains('sent') ||
        s.contains('dispatch')) {
      return ('EXPÉDIÉE', const Color(0xFF2F6BEA));
    }
    return ('CONFIRMÉE', const Color(0xFF7B4DE3));
  }

  Widget _buildStatusBadge(String status) {
    final style = _statusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      decoration: BoxDecoration(
        color: style.$2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        style.$1,
        style: const TextStyle(
          fontFamily: 'Lato',
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0.3,
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
