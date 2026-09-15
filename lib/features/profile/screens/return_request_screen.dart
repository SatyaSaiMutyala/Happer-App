import 'package:flutter/material.dart';
import 'package:happer_app/features/profile/models/purchase_model.dart';
import 'package:happer_app/features/profile/screens/return_refund_screen_new.dart';
import 'package:happer_app/features/profile/widgets/order_product_header.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:intl/intl.dart';

/// "DEMANDE DE RETOUR" — return-request status: confirmation banner, a 4-step
/// progress tracker, the return details, an expiry notice and a tracking entry.
class ReturnRequestScreen extends StatefulWidget {
  final PurchasedProduct order;
  final String reason;

  const ReturnRequestScreen({
    super.key,
    required this.order,
    required this.reason,
  });

  @override
  State<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends State<ReturnRequestScreen> {
  late final DateTime _requestDate;

  @override
  void initState() {
    super.initState();
    _requestDate = DateTime.now();
  }

  /// e.g. "5 janvier 2026" / "5 January 2026", in the current app language.
  String _frDate(DateTime d) =>
      DateFormat('d MMMM y', Localizations.localeOf(context).languageCode)
          .format(d);

  /// e.g. "14h05" / "14:05".
  String _frTime(DateTime d) => AppLocalizations.of(context)
      .orderTimeHourMinute('${d.hour}', d.minute.toString().padLeft(2, '0'));

  String _frDateTime(DateTime d) =>
      AppLocalizations.of(context).orderDateAtTime(_frDate(d), _frTime(d));

  String get _requestNumber =>
      'RET-${(_requestDate.millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0')}';

  DateTime get _deadline => _requestDate.add(const Duration(days: 14));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(
        title: AppLocalizations.of(context).returnRequest,
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
            OrderProductHeader(order: widget.order),
            const SizedBox(height: 20),
            _trackerCard(),
            const SizedBox(height: 16),
            _detailsCard(),
            const SizedBox(height: 16),
            _deadlineBanner(),
            const SizedBox(height: 16),
            _trackCard(),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) => Container(
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

  // ─── Tracker card ─────────────────────────────────────────────────────────

  Widget _trackerCard() {
    final l = AppLocalizations.of(context);
    final labels = [l.request, l.dispatch, l.receipt, l.refund];
    final subs = [l.inProgress, l.upcoming, l.upcoming, l.upcoming];
    final aligns = [
      TextAlign.left,
      TextAlign.center,
      TextAlign.center,
      TextAlign.right
    ];

    return _card(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Confirmation banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF9DD5A8)),
            ),
            child: Row(
              children: [
                const Icon(Icons.mark_email_read_outlined,
                    size: 22, color: Color(0xFF3B3B3B)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.returnRequestReceived(
                        _frDate(_requestDate), _frTime(_requestDate)),
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      height: 1.4,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Numbered circles + lines
          Row(
            children: [
              for (int i = 0; i < 4; i++) ...[
                if (i > 0) Expanded(child: _line()),
                _numCircle(i + 1, active: i == 0),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Labels
          Row(
            children: [
              for (int i = 0; i < 4; i++)
                Expanded(
                  child: Text(
                    labels[i],
                    textAlign: aligns[i],
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),

          // Sub-labels
          Row(
            children: [
              for (int i = 0; i < 4; i++)
                Expanded(
                  child: Text(
                    subs[i],
                    textAlign: aligns[i],
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF8D8D8D),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numCircle(int n, {required bool active}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.black : Colors.white,
        border:
            active ? null : Border.all(color: const Color(0xFFCFCFCF), width: 2),
      ),
      child: Center(
        child: Text(
          '$n',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: active ? Colors.white : const Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }

  Widget _line() =>
      Container(height: 2, color: const Color(0xFF22A45D));

  // ─── Details card ─────────────────────────────────────────────────────────

  Widget _detailsCard() {
    final l = AppLocalizations.of(context);
    final brand = widget.order.brand?.name ?? '';
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _detailRow(
            icon: Icons.inventory_2_outlined,
            title: l.returnReason,
            value: widget.reason,
          ),
          _divider(),
          _detailRow(
            icon: Icons.calendar_month_outlined,
            title: l.requestDate,
            value: _frDateTime(_requestDate),
          ),
          _divider(),
          _detailRow(
            icon: Icons.info_outline,
            title: l.requestNumber,
            value: _requestNumber,
          ),
          _divider(),
          _detailRow(
            icon: Icons.location_on_outlined,
            title: l.returnAddress,
            value: l.orderReturnAddressValue(brand.toUpperCase()),
          ),
          _divider(),
          _detailRow(
            icon: Icons.credit_card_outlined,
            title: l.returnFees,
            value: l.customerPays,
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 1.35,
                    color: Color(0xFF8D8D8D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
      height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFEDEDED));

  // ─── Deadline banner ──────────────────────────────────────────────────────

  Widget _deadlineBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 22, color: Color(0xFF3B3B3B)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)
                  .returnDeadlineNotice(_frDate(_deadline)),
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Track card ───────────────────────────────────────────────────────────

  Widget _trackCard() {
    final l = AppLocalizations.of(context);
    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.local_shipping_outlined,
              size: 26, color: Colors.black),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.trackMyReturn,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l.trackReturnDescription,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: Color(0xFF8D8D8D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
