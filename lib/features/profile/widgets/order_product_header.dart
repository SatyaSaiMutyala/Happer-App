import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:happer_app/features/profile/models/purchase_model.dart';

/// Shared product summary shown at the top of the order-detail and return
/// screens: image + brand logo + brand name + product name + size + quantity +
/// price.
class OrderProductHeader extends StatelessWidget {
  final PurchasedProduct order;

  const OrderProductHeader({super.key, required this.order});

  static const _infoStyle = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.35,
    color: Color(0xFF1A1A1A),
  );

  String _price(double v, String currency) {
    final symbol = currency.toUpperCase() == 'EUR' ? '€' : currency;
    return '${v.toStringAsFixed(2).replaceAll('.', ',')} $symbol';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = order.displayImage;
    final imgW =
        (MediaQuery.of(context).size.width * 0.36).clamp(120.0, 170.0);
    final imgH = imgW * 1.18;
    final brandLogo = order.brand?.picture ?? '';
    final size = order.variant?.size;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: imgW,
            height: imgH,
            color: const Color(0xFFF4F4F4),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.image, color: Colors.grey),
                  )
                : const Icon(Icons.image, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (brandLogo.isNotEmpty) ...[
                SizedBox(
                  height: 28,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CachedNetworkImage(
                      imageUrl: brandLogo,
                      height: 28,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                (order.brand?.name ?? '').toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(order.product?.name ?? '', style: _infoStyle),
              if (size != null && size.isNotEmpty)
                Text('Taille $size', style: _infoStyle),
              Text('Quantité ${order.quantity}', style: _infoStyle),
              const SizedBox(height: 8),
              Text(
                _price(order.unitPrice, order.currency),
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
