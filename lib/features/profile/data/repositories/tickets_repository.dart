import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/core/network/api_endpoints.dart';
import 'package:happer_app/features/profile/models/ticket_model.dart';

class TicketsRepository {
  final _client = ApiClient();

  // ── 1. Raise ticket ───────────────────────────────────────────────────────
  /// Creates a new support ticket.
  ///
  /// [cartId] and [itemId] are both required together to link the ticket to a
  /// purchased product (cart_id = Cart._id, item_id = CartItem._id).
  /// [priority] defaults to "medium" on the backend when omitted.
  Future<TicketModel> raiseTicket({
    required String subject,
    required String description,
    String? cartId,
    String? itemId,
    String priority = 'medium',
    List<String> images = const [],
  }) async {
    final body = <String, dynamic>{
      'subject': subject.trim(),
      'description': description.trim(),
      'priority': priority,
      if (images.isNotEmpty) 'images': images,
      if (cartId != null && cartId.isNotEmpty) 'cart_id': cartId,
      if (itemId != null && itemId.isNotEmpty) 'item_id': itemId,
    };

    final response = await _client.post(
      ApiEndpoints.raiseTicket,
      requiresAuth: true,
      body: body,
    );

    return TicketModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  // ── 2. Get my tickets (paginated) ─────────────────────────────────────────
  /// Returns the user's ticket list — messages are excluded for performance.
  ///
  /// [status] can be "open", "in_progress", "resolved", or null (all).
  Future<({List<TicketModel> tickets, int totalRecords, int totalPages})>
      getMyTickets({
    int page = 1,
    int perPage = 10,
    String? search,
    String? status,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'perPage': '$perPage',
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (status != null && status.isNotEmpty) 'status': status,
    };

    final response = await _client.get(
      ApiEndpoints.getMyTickets,
      requiresAuth: true,
      queryParams: params,
    );

    final outer = response['data'] as Map<String, dynamic>? ?? {};
    final tickets = (outer['data'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(TicketModel.fromJson)
        .toList();

    return (
      tickets: tickets,
      totalRecords: outer['totalRecords'] as int? ?? 0,
      totalPages: outer['totalPages'] as int? ?? 1,
    );
  }

  // ── 3. Get ticket detail ──────────────────────────────────────────────────
  /// Returns the full ticket with all messages and populated sender info.
  Future<TicketModel> getTicketById(String ticketId) async {
    final response = await _client.get(
      ApiEndpoints.getTicketById(ticketId),
      requiresAuth: true,
    );

    return TicketModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  // ── 4. Reply to ticket ────────────────────────────────────────────────────
  /// Adds a reply from the user and returns the refreshed ticket.
  Future<TicketModel> replyTicket({
    required String ticketId,
    required String message,
  }) async {
    final response = await _client.post(
      ApiEndpoints.replyTicket(ticketId),
      requiresAuth: true,
      body: {'message': message.trim()},
    );

    return TicketModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  // ── 5. Upload image (for raise-ticket form) ───────────────────────────────
  Future<String> uploadImage(String filePath) async {
    final response = await _client.multipart(
      ApiEndpoints.fileUpload,
      method: 'POST',
      filePaths: {'file': filePath},
      requiresAuth: true,
    );
    final data = response['data'];
    if (data is String) return data;
    if (data is Map) return data['url'] as String? ?? '';
    return response['url'] as String? ?? '';
  }
}
