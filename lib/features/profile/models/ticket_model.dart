/// Support ticket models — mirrors the backend's `tickets.model.ts`.
///
/// Status: open | in_progress | resolved
/// Priority: low | medium | high
/// Sender: User | Admin

// ─── Sender (populated on message entries) ────────────────────────────────
class TicketSender {
  final String id;
  final String fullName;
  final String? email;
  final String? profileImage;
  final String? role;

  const TicketSender({
    required this.id,
    required this.fullName,
    this.email,
    this.profileImage,
    this.role,
  });

  factory TicketSender.fromJson(Map<String, dynamic> json) => TicketSender(
        id: json['_id'] as String? ?? '',
        fullName: json['full_name'] as String? ?? '',
        email: json['email'] as String?,
        profileImage: json['profile_image'] as String?,
        role: json['role'] as String?,
      );
}

// ─── Message ──────────────────────────────────────────────────────────────
class TicketMessage {
  final String id;
  final String message;

  /// "User" or "Admin"
  final String senderModel;
  final DateTime? createdAt;
  final TicketSender? sender;

  bool get isFromUser => senderModel == 'User';

  const TicketMessage({
    required this.id,
    required this.message,
    required this.senderModel,
    this.createdAt,
    this.sender,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) => TicketMessage(
        id: json['_id'] as String? ?? '',
        message: json['message'] as String? ?? '',
        senderModel: json['sender_model'] as String? ?? 'User',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        sender: json['sender'] is Map<String, dynamic>
            ? TicketSender.fromJson(json['sender'] as Map<String, dynamic>)
            : null,
      );
}

// ─── Ticket (both list item and detail) ───────────────────────────────────
class TicketModel {
  final String id;
  final String ticketNumber;

  // Optional linked purchase
  final String? cartId;
  final String? itemId;
  final String? orderId;
  final String? itemOrderId;

  // Populated product info (present in list & detail)
  final String? productName;
  final String? productImage;
  final String? variantTitle;
  final List<String> variantImages;

  // Populated brand info (detail only)
  final String? brandName;
  final String? brandPicture;

  final String subject;
  final String description;
  final List<String> images;

  /// open | in_progress | resolved
  final String status;

  /// low | medium | high
  final String priority;

  final DateTime? slaDueAt;
  final DateTime? resolvedAt;
  final DateTime? lastUpdatedAt;
  final DateTime? createdAt;

  /// Populated only on the detail endpoint.
  final List<TicketMessage> messages;

  const TicketModel({
    required this.id,
    required this.ticketNumber,
    this.cartId,
    this.itemId,
    this.orderId,
    this.itemOrderId,
    this.productName,
    this.productImage,
    this.variantTitle,
    this.variantImages = const [],
    this.brandName,
    this.brandPicture,
    required this.subject,
    required this.description,
    this.images = const [],
    required this.status,
    required this.priority,
    this.slaDueAt,
    this.resolvedAt,
    this.lastUpdatedAt,
    this.createdAt,
    this.messages = const [],
  });

  bool get isResolved => status == 'resolved';
  bool get isOpen => status == 'open';

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    // product_id may be a populated object or a bare id string
    final product = json['product_id'] is Map<String, dynamic>
        ? json['product_id'] as Map<String, dynamic>
        : null;
    // variant_id same
    final variant = json['variant_id'] is Map<String, dynamic>
        ? json['variant_id'] as Map<String, dynamic>
        : null;
    // brand_id same (detail only)
    final brand = json['brand_id'] is Map<String, dynamic>
        ? json['brand_id'] as Map<String, dynamic>
        : null;

    return TicketModel(
      id: (json['_id'] as Object?)?.toString() ?? '',
      ticketNumber: json['ticket_number'] as String? ?? '',
      cartId: (json['cart_id'] as Object?)?.toString(),
      itemId: (json['item_id'] as Object?)?.toString(),
      orderId: json['order_id'] as String?,
      itemOrderId: json['item_order_id'] as String?,
      productName: product?['name'] as String?,
      productImage: product?['product_image'] as String?,
      variantTitle: variant?['title'] as String?,
      variantImages: (variant?['images'] as List<dynamic>? ?? [])
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toList(),
      brandName: brand?['name'] as String?,
      brandPicture: brand?['picture'] as String?,
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? [])
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toList(),
      status: json['status'] as String? ?? 'open',
      priority: json['priority'] as String? ?? 'medium',
      slaDueAt: json['sla_due_at'] != null
          ? DateTime.tryParse(json['sla_due_at'] as String)
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'] as String)
          : null,
      lastUpdatedAt: json['last_updated_at'] != null
          ? DateTime.tryParse(json['last_updated_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      messages: (json['messages'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TicketMessage.fromJson)
          .toList(),
    );
  }
}
