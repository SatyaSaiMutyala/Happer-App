import 'package:flutter/material.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/profile/data/repositories/tickets_repository.dart';
import 'package:happer_app/features/profile/models/ticket_model.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:intl/intl.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _repo = TicketsRepository();
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();

  TicketModel? _ticket;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final ticket = await _repo.getTicketById(widget.ticketId);
      if (!mounted) return;
      setState(() {
        _ticket = ticket;
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppSnackBar(e.toString(), isSuccess: false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    if (_ticket?.isResolved == true) {
      showAppSnackBar('Ce ticket est résolu.', isSuccess: false);
      return;
    }
    setState(() => _sending = true);
    try {
      final updated = await _repo.replyTicket(
        ticketId: widget.ticketId,
        message: text,
      );
      _replyController.clear();
      if (!mounted) return;
      setState(() {
        _ticket = updated;
        _sending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      showAppSnackBar(e.toString(), isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: HapperAppBar(
        title: _ticket?.ticketNumber ?? 'TICKET',
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _headerCard(),
                        const SizedBox(height: 14),
                        if (_ticket!.messages.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'MESSAGES',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 0.8,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ),
                          ..._ticket!.messages.map(_messageBubble),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                ),
                if (!(_ticket?.isResolved ?? false)) _replyBar(),
                if (_ticket?.isResolved ?? false)
                  Container(
                    color: const Color(0xFFEEF8EE),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 16, color: Color(0xFF4CAF50)),
                        SizedBox(width: 6),
                        Text(
                          'Ticket résolu — aucune réponse possible',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 13,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  // ─── Header card ──────────────────────────────────────────────────────────
  Widget _headerCard() {
    final t = _ticket!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.subject,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _statusBadge(t.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            t.description,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 14,
              color: Color(0xFF444444),
              height: 1.5,
            ),
          ),
          if (t.orderId != null || t.itemOrderId != null) ...[
            const SizedBox(height: 10),
            _infoRow(
              Icons.receipt_long_outlined,
              'Commande : ${t.itemOrderId ?? t.orderId}',
            ),
          ],
          if (t.productName != null) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.inventory_2_outlined, t.productName!),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _priorityBadge(t.priority),
              const Spacer(),
              if (t.createdAt != null)
                Text(
                  DateFormat('d MMM yyyy', 'fr').format(t.createdAt!),
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 12,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
            ],
          ),
          if (t.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: t.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    t.images[i],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: const Color(0xFFEEEEEE),
                      child: const Icon(Icons.broken_image_outlined,
                          color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Message bubble ───────────────────────────────────────────────────────
  Widget _messageBubble(TicketMessage msg) {
    final isUser = msg.isFromUser;
    final time = msg.createdAt != null
        ? DateFormat('d MMM, HH:mm', 'fr').format(msg.createdAt!)
        : '';
    final senderName = msg.sender?.fullName.isNotEmpty == true
        ? msg.sender!.fullName
        : (isUser ? 'Vous' : 'Support');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF1A1A1A),
              backgroundImage: msg.sender?.profileImage != null
                  ? NetworkImage(msg.sender!.profileImage!)
                  : null,
              child: msg.sender?.profileImage == null
                  ? const Icon(Icons.support_agent, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  senderName,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.message,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      height: 1.45,
                      color: isUser ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 10,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ─── Reply bar ────────────────────────────────────────────────────────────
  Widget _replyBar() {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(fontFamily: 'Lato', fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Écrire un message…',
                  hintStyle: const TextStyle(
                      fontFamily: 'Lato', color: Color(0xFFAAAAAA)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  filled: true,
                  fillColor: const Color(0xFFF3F3F3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sending ? null : _sendReply,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _sending ? Colors.grey : Colors.black,
                  shape: BoxShape.circle,
                ),
                child: _sending
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static const _statusColor = {
    'open': Color(0xFF2196F3),
    'in_progress': Color(0xFFFF9800),
    'resolved': Color(0xFF4CAF50),
  };
  static const _statusLabel = {
    'open': 'Ouvert',
    'in_progress': 'En cours',
    'resolved': 'Résolu',
  };
  static const _priorityColor = {
    'high': Color(0xFFE53935),
    'medium': Color(0xFFFF9800),
    'low': Color(0xFF43A047),
  };
  static const _priorityLabel = {
    'high': 'Haute',
    'medium': 'Moyenne',
    'low': 'Faible',
  };

  Widget _statusBadge(String status) {
    final color = _statusColor[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel[status] ?? status,
        style: TextStyle(
          fontFamily: 'Lato',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _priorityBadge(String priority) {
    final color = _priorityColor[priority] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Priorité : ${_priorityLabel[priority] ?? priority}',
        style: TextStyle(
          fontFamily: 'Lato',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF888888)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 13,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      );
}
