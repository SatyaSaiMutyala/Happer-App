/// One entry in a cart item's fulfilment timeline.
///
/// Source: `GET /user/carts/order-logs/{cart_id}/{item_id}` — the API returns
/// them oldest-first. The backend writes one log per transition, across three
/// phases: `order` (placed → shipped → delivered / cancelled), `return`
/// (return_requested → … → return_received) and `refund`.
class OrderLog {
  /// One of: placed, shipped, delivered, cancelled, return_requested,
  /// return_approved, return_rejected, return_shipped, return_received,
  /// refund_initiated, refunded.
  final String status;

  /// order | return | refund
  final String phase;

  final DateTime? createdAt;

  // Outbound shipping (order phase)
  final String? carrier;
  final String? trackingNumber;
  final String? trackingUrl;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;

  // Return phase
  final String? returnReason;
  final String? returnTrackingUrl;
  final DateTime? returnRaisedAt;

  // Refund phase
  final double? refundAmount;
  final DateTime? refundedAt;

  // Cancellation
  final DateTime? cancelledAt;
  final String? cancelReason;

  final String? comments;

  const OrderLog({
    required this.status,
    required this.phase,
    this.createdAt,
    this.carrier,
    this.trackingNumber,
    this.trackingUrl,
    this.shippedAt,
    this.deliveredAt,
    this.returnReason,
    this.returnTrackingUrl,
    this.returnRaisedAt,
    this.refundAmount,
    this.refundedAt,
    this.cancelledAt,
    this.cancelReason,
    this.comments,
  });

  static DateTime? _date(dynamic raw) =>
      raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

  static String? _text(dynamic raw) {
    final s = (raw as String?)?.trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  factory OrderLog.fromJson(Map<String, dynamic> json) {
    return OrderLog(
      status: (json['status'] as String? ?? '').trim(),
      phase: (json['phase'] as String? ?? '').trim(),
      createdAt: _date(json['created_at']),
      carrier: _text(json['carrier']),
      trackingNumber: _text(json['tracking_number']),
      trackingUrl: _text(json['tracking_url']),
      shippedAt: _date(json['shipped_at']),
      deliveredAt: _date(json['delivered_at']),
      returnReason: _text(json['return_reason']),
      returnTrackingUrl: _text(json['return_tracking_url']),
      returnRaisedAt: _date(json['return_raised_at']),
      refundAmount: (json['refund_amount'] as num?)?.toDouble(),
      refundedAt: _date(json['refunded_at']),
      cancelledAt: _date(json['cancelled_at']),
      cancelReason: _text(json['cancel_reason']),
      comments: _text(json['comments']),
    );
  }

  /// The moment this step happened. Each status carries its own timestamp
  /// field; `created_at` is the fallback for the ones that don't.
  DateTime? get occurredAt => switch (status) {
        'shipped' => shippedAt ?? createdAt,
        'delivered' => deliveredAt ?? createdAt,
        'cancelled' => cancelledAt ?? createdAt,
        'return_requested' => returnRaisedAt ?? createdAt,
        'refunded' => refundedAt ?? createdAt,
        _ => createdAt,
      };
}

/// Reading a timeline: the screen only ever asks "did this happen, and when",
/// so keep that logic here instead of spreading `firstWhere` calls over the UI.
extension OrderTimeline on List<OrderLog> {
  OrderLog? withStatus(String status) {
    for (final log in this) {
      if (log.status == status) return log;
    }
    return null;
  }

  bool has(String status) => withStatus(status) != null;

  DateTime? dateOf(String status) => withStatus(status)?.occurredAt;

  /// Latest entry — the list arrives oldest-first.
  OrderLog? get latest => isEmpty ? null : last;

  /// Shipping details come from the `shipped` log; nothing else carries them.
  OrderLog? get shipment => withStatus('shipped');

  bool get isCancelled => has('cancelled');

  /// True once the item has entered the return or refund flow.
  bool get hasReturnActivity =>
      any((log) => log.phase == 'return' || log.phase == 'refund');
}
