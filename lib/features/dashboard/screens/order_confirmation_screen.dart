import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/profile/screens/my_purchases_screen.dart';
import 'package:happer_app/features/profile/screens/return_refund_screen_new.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';

/// A product offered to round out the look that was just bought.
///
/// Deliberately a plain model with no API type behind it yet — see
/// [kUseMockLookSuggestions]. When the endpoint lands, map its response into
/// this and nothing in the UI has to change.
class LookSuggestion {
  const LookSuggestion({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.brandLabel,
    required this.image,
    required this.price,
    this.compareAtPrice,
  });

  final String id;
  final String name;
  final String subtitle;
  final String brandLabel;

  /// An asset path or a remote URL — [_SuggestionCard] handles both, so demo
  /// data and real data render through the same widget.
  final String image;

  final double price;
  final double? compareAtPrice;
}

/// ─────────────────────────────────────────────────────────────────────────
/// DEMO ONLY — set to `false` before release.
///
/// "Complétez votre look" cannot be driven by real data yet: the cart records
/// `product_id`, `variant_id` and `affiliate_id` but not the selfie an item was
/// bought from, so after checkout the app has no idea which look to complete.
/// Adding to an already-paid order needs a backend endpoint too — the
/// "vous ne payez que la différence" promise is a payment-flow change, not a
/// UI one.
///
/// Until both exist this flag feeds the section placeholder products so the
/// design can be reviewed and demoed. With it `false`, the screen renders the
/// plain thank-you page, which is also the correct real-world fallback for an
/// order that has no look behind it.
/// ─────────────────────────────────────────────────────────────────────────
const bool kUseMockLookSuggestions = true;

const List<LookSuggestion> _mockLookSuggestions = [
  LookSuggestion(
    id: 'mock-1',
    name: 'Pure Cachemire',
    subtitle: 'Carré Motif Blanc',
    brandLabel: 'PURE',
    image: 'assets/images/modelOne.png',
    price: 62,
    compareAtPrice: 125,
  ),
  LookSuggestion(
    id: 'mock-2',
    name: 'Blazer Maison Anje',
    subtitle: 'Printemps Marron',
    brandLabel: 'ANJE',
    image: 'assets/images/modelTwo.png',
    price: 135,
    compareAtPrice: 200,
  ),
];

/// "MERCI" — the page that closes a purchase.
///
/// Checkout used to drop the user straight into "MES COMMANDES", which reads as
/// a list of admin rather than a confirmation: nothing on that screen says the
/// payment went through. This one confirms it, offers a last chance to complete
/// the look, then points at the order and at support.
class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({
    super.key,
    this.orderReference,
    this.lookSuggestions,
  });

  /// Shown as "Commande #…". Hidden when checkout didn't return one, rather
  /// than printing an empty reference.
  final String? orderReference;

  /// Products to complete the look. Null falls back to the demo data while
  /// [kUseMockLookSuggestions] is on; an empty list forces the plain page.
  final List<LookSuggestion>? lookSuggestions;

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final Set<String> _selectedIds = {};

  List<LookSuggestion> get _suggestions =>
      widget.lookSuggestions ??
      (kUseMockLookSuggestions ? _mockLookSuggestions : const []);

  bool get _hasLook => _suggestions.isNotEmpty;

  void _toggle(LookSuggestion product) {
    setState(() {
      if (!_selectedIds.remove(product.id)) _selectedIds.add(product.id);
    });
  }

  /// TODO: replace with the order-amend call once the backend exposes it —
  /// the selected ids should be added to the paid order, charging only the
  /// difference. Until then this is a demo stub.
  void _confirmAddition() {
    showAppSnackBar(
      'Ajout à la commande bientôt disponible',
      isSuccess: false,
    );
    _openOrders();
  }

  @override
  Widget build(BuildContext context) {
    final reference = widget.orderReference?.trim() ?? '';

    return PopScope(
      // Nothing behind this screen but the emptied cart, so back means home.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: HapperAppBar(
          title: 'MERCI',
          showBack: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black, size: 24),
              onPressed: _goHome,
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
            child: Column(
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 44, color: Colors.black),
                const SizedBox(height: 20),
                const Text(
                  'Merci pour votre commande !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Votre paiement a été confirmé et votre commande\n'
                  'est en cours de préparation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
                const SizedBox(height: 28),
                _InfoTile(
                  icon: Icons.shopping_bag_outlined,
                  title: reference.isEmpty
                      ? 'Commande confirmée'
                      : 'Commande #$reference',
                  subtitle: 'Un email de confirmation vous a été envoyé.',
                  onTap: _openOrders,
                ),
                if (_hasLook) ...[
                  const SizedBox(height: 28),
                  _buildLookSection(),
                ],
                const SizedBox(height: 12),
                const _InfoTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'Livraison offerte',
                  subtitle: 'Votre commande bénéficie de la livraison offerte.\n'
                      'Délai estimé : 3 à 5 jours ouvrés.',
                ),
                const SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'Suivre ma commande',
                  subtitle: 'Suivez l\'expédition et la livraison de votre '
                      'commande en temps réel.',
                  onTap: _openOrders,
                ),
                const SizedBox(height: 28),
                // With a look on offer the primary action belongs to that
                // section, so this pair steps down to a single quiet link.
                if (!_hasLook) ...[
                  _primaryButton('Voir ma commande', _openOrders),
                  const SizedBox(height: 16),
                ],
                _quietLink('Retourner à l\'accueil', _goHome),
                const SizedBox(height: 28),
                _InfoTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'Besoin d\'aide ?',
                  subtitle: 'Notre équipe est disponible pour vous aider.\n'
                      'Contactez-nous à tout moment.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ReturnRefundScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── "Complétez votre look" ───────────────────────────────────────────────

  Widget _buildLookSection() {
    final anySelected = _selectedIds.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.favorite_border, size: 20, color: Colors.black),
            const SizedBox(width: 8),
            const Text(
              'Complétez votre look',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(left: 28, top: 2),
          child: Text(
            'Ajoutez 1 ou 2 pièces à votre commande en un clic.',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 12,
              color: Color(0xFF8D8D8D),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Two per row, matching the design. Any extras wrap onto the next line
        // rather than scrolling off the side unseen.
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final product in _suggestions)
              SizedBox(
                width: (MediaQuery.of(context).size.width - 32 - 12) / 2,
                child: _SuggestionCard(
                  product: product,
                  isSelected: _selectedIds.contains(product.id),
                  onToggle: () => _toggle(product),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 13, color: Color(0xFF8D8D8D)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Aucun paiement supplémentaire. Vous ne payez que la différence.',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _primaryButton(
          'Confirmer et ajouter à ma commande',
          anySelected ? _confirmAddition : null,
        ),
        const SizedBox(height: 14),
        Center(
          child: _quietLink('Non merci, aller à ma commande', _openOrders),
        ),
      ],
    );
  }

  // ─── Shared bits ──────────────────────────────────────────────────────────

  Widget _primaryButton(String label, VoidCallback? onTap) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? Colors.black : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: enabled ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _quietLink(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            color: Color(0xFF6B6B6B),
          ),
        ),
      ),
    );
  }

  /// Back to the dashboard. `popUntil` rather than a push: the cart and this
  /// screen both belong to a finished transaction and shouldn't stay on the
  /// stack behind the feed.
  void _goHome() => Navigator.of(context).popUntil((route) => route.isFirst);

  void _openOrders() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MyPurchasesScreen(fromCart: true),
        ),
      );
}

/// One "complete the look" product: shot with a brand chip and a select
/// control, then name, price, and a button that mirrors the same selection.
class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.product,
    required this.isSelected,
    required this.onToggle,
  });

  final LookSuggestion product;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final compare = product.compareAtPrice;
    final hasDiscount = compare != null && compare > product.price;

    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _image(),
                  ),
                ),
                if (product.brandLabel.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.brandLabel,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          letterSpacing: 0.5,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      isSelected ? Icons.check : Icons.add,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
          Text(
            product.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 12,
              color: Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_fmt(product.price)}€',
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              if (hasDiscount) ...[
                const SizedBox(width: 6),
                Text(
                  '${_fmt(compare)}€',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black87),
            ),
            child: Text(
              isSelected ? 'Ajouté' : 'Ajouter à ma commande',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bundled asset or remote URL — demo data uses the former, the API the
  /// latter.
  Widget _image() {
    if (product.image.startsWith('assets/')) {
      return Image.asset(product.image, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: product.image,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: Colors.grey.shade200),
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, size: 32, color: Colors.grey),
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}

/// One bordered row: icon, title, supporting line, and a chevron when it leads
/// somewhere. Rows with no destination (the delivery notice) simply omit it.
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.black),
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
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      height: 1.45,
                      color: Color(0xFF8D8D8D),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right,
                  size: 22, color: Color(0xFF8D8D8D)),
            ],
          ],
        ),
      ),
    );
  }
}
