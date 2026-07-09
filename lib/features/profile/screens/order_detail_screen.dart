import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:happer_app/features/profile/models/purchase_model.dart';
import 'package:happer_app/features/profile/screens/invoice_webview_screen.dart';
import 'package:happer_app/features/profile/screens/return_article_screen.dart';
import 'package:happer_app/features/profile/screens/return_refund_screen_new.dart';
import 'package:happer_app/features/profile/widgets/order_product_header.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';

/// "DÉTAIL DE LA COMMANDE" — full order detail with product summary, a delivery
/// status tracker, delivery/address/order info, the affiliate the item was
/// bought via, and a return entry point.
class OrderDetailScreen extends StatelessWidget {
  final PurchasedProduct order;

  const OrderDetailScreen({super.key, required this.order});

  // ─── Formatting helpers ───────────────────────────────────────────────────

  static const _frMonths = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
  ];

  String _frDate(DateTime? d, {bool withYear = false}) {
    if (d == null) return '';
    final m = _frMonths[d.month - 1];
    return withYear ? '${d.day} $m ${d.year}' : '${d.day} $m';
  }

  // 0 = Confirmée, 1 = Expédiée, 2 = Livrée
  int _statusIndex(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('livr') || s.contains('deliver')) {
      return 2;
    }
    if (s.contains('exp') ||
        s.contains('ship') ||
        s.contains('sent') ||
        s.contains('dispatch')) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(
        title: 'DÉTAIL DE LA COMMANDE',
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined,
                color: Colors.black, size: 24),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReturnRefundScreen()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OrderProductHeader(order: order),
            const SizedBox(height: 20),
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildInfoCard(context),
            const SizedBox(height: 16),
            _buildBoughtViaCard(context),
            const SizedBox(height: 16),
            _buildReturnCard(context),
          ],
        ),
      ),
    );
  }

  // ─── Card wrapper ─────────────────────────────────────────────────────────

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  // ─── Status tracker card ──────────────────────────────────────────────────

  Widget _buildStatusCard() {
    final current = _statusIndex(order.orderStatus);
    // Per-step dates aren't in the model yet — derive from paid_at as a
    // placeholder. Replace with the API's status-history dates when available.
    final paidAt = order.paidAt;
    final stepDates = <DateTime?>[
      paidAt,
      paidAt?.add(const Duration(days: 1)),
      paidAt?.add(const Duration(days: 2)),
    ];
    const labels = ['Confirmée', 'Expédiée', 'Livrée'];

    final pillDate = _frDate(stepDates[current]);
    final pillText = current == 2
        ? 'Livré le $pillDate'
        : current == 1
            ? 'Expédié le $pillDate'
            : 'Confirmée le $pillDate';

    return _card(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF9DD5A8)),
            ),
            child: Text(
              pillText,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Circles + connecting lines
          Row(
            children: [
              _stepCircle(done: current >= 0),
              Expanded(child: _stepLine(active: current >= 1)),
              _stepCircle(done: current >= 1),
              Expanded(child: _stepLine(active: current >= 2)),
              _stepCircle(done: current >= 2),
            ],
          ),
          const SizedBox(height: 12),

          // Labels
          Row(
            children: [
              Expanded(child: _stepLabel(labels[0], TextAlign.left)),
              Expanded(child: _stepLabel(labels[1], TextAlign.center)),
              Expanded(child: _stepLabel(labels[2], TextAlign.right)),
            ],
          ),
          const SizedBox(height: 4),

          // Dates
          Row(
            children: [
              Expanded(
                  child: _stepDate(_frDate(stepDates[0]), TextAlign.left)),
              Expanded(
                  child: _stepDate(_frDate(stepDates[1]), TextAlign.center)),
              Expanded(
                  child: _stepDate(_frDate(stepDates[2]), TextAlign.right)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepCircle({required bool done}) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? Colors.black : Colors.white,
        border: done ? null : Border.all(color: const Color(0xFFCFCFCF), width: 2),
      ),
      child: done
          ? const Icon(Icons.check, color: Colors.white, size: 15)
          : null,
    );
  }

  Widget _stepLine({required bool active}) {
    return Container(
      height: 2,
      color: active ? const Color(0xFF22A45D) : const Color(0xFFE0E0E0),
    );
  }

  Widget _stepLabel(String text, TextAlign align) => Text(
        text,
        textAlign: align,
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: Colors.black,
        ),
      );

  Widget _stepDate(String text, TextAlign align) => Text(
        text,
        textAlign: align,
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: Color(0xFF8D8D8D),
        ),
      );

  // ─── Info card (delivery / address / order / invoice) ─────────────────────

  Widget _buildInfoCard(BuildContext context) {
    final addr = order.shippingAddress;
    final addressText = addr != null
        ? [
            addr.streetAddress,
            [addr.postalCode, addr.city].where((s) => s.isNotEmpty).join(' '),
          ].where((s) => s.isNotEmpty).join(', ')
        : '—';

    final trackingNo = order.paymentReference.isNotEmpty
        ? order.paymentReference
        : order.orderId;
    final orderNo =
        order.paymentReference.isNotEmpty ? order.paymentReference : order.orderId;

    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _infoRow(
            icon: Icons.inventory_2_outlined,
            title: 'Livraison',
            subtitle: 'N° de suivi $trackingNo',
            trailing: _externalButton(() => _openLink(context,
                order.deliveryLink ?? order.invoiceUrl ?? '')),
          ),
          _rowDivider(),
          _infoRow(
            icon: Icons.location_on_outlined,
            title: 'Adresse de livraison',
            subtitle: addressText,
          ),
          _rowDivider(),
          _infoRow(
            icon: Icons.info_outline,
            title: 'Informations de la commande',
            subtitle:
                'N° de la commande $orderNo${order.paidAt != null ? ' - ${_frDate(order.paidAt, withYear: true)}' : ''}',
          ),
          _rowDivider(),
          _infoRow(
            icon: Icons.receipt_long_outlined,
            title: 'Voir la facture (PDF)',
            onTap: (order.invoiceUrl != null && order.invoiceUrl!.isNotEmpty)
                ? () => _openLink(context, order.invoiceUrl!)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: Colors.black),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Color(0xFF8D8D8D),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing,
            ],
          ],
        ),
      ),
    );
  }

  Widget _rowDivider() => const Divider(
      height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFEDEDED));

  Widget _externalButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.open_in_new, size: 22, color: Colors.black),
      ),
    );
  }

  // ─── Bought via card ──────────────────────────────────────────────────────

  Widget _buildBoughtViaCard(BuildContext context) {
    final affiliate = order.affiliate;
    final avatar = affiliate?.profileImage ?? '';
    final name = affiliate?.username ?? '';

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acheté via',
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFEEEEEE),
                backgroundImage:
                    avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
                child: avatar.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified, size: 18, color: Colors.black),
              const Spacer(),
              _voirLeLookButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _voirLeLookButton(BuildContext context) {
    return GestureDetector(
      // Opens the creator's look — wire to the selfie/look id when the order
      // detail API exposes it.
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Look bientôt disponible')),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Voir le look',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.open_in_new, size: 18, color: Colors.black),
          ],
        ),
      ),
    );
  }

  // ─── Return card ──────────────────────────────────────────────────────────

  Widget _buildReturnCard(BuildContext context) {
    return _card(
      padding: EdgeInsets.zero,
      child: _infoRow(
        icon: Icons.assignment_return_outlined,
        title: 'Retourner ou remplacer l\'article',
        subtitle: 'Faire une demande de retour',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReturnArticleScreen(order: order)),
        ),
      ),
    );
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void _openLink(BuildContext context, String url) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lien indisponible')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InvoiceWebViewScreen(url: url)),
    );
  }
}
