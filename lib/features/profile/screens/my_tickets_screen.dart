import 'package:flutter/material.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/profile/data/repositories/tickets_repository.dart';
import 'package:happer_app/features/profile/models/ticket_model.dart';
import 'package:happer_app/features/profile/screens/raise_ticket_screen.dart';
import 'package:happer_app/features/profile/screens/ticket_detail_screen.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:intl/intl.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final _repo = TicketsRepository();
  final _scrollController = ScrollController();

  List<TicketModel> _tickets = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  int _totalPages = 1;
  String? _statusFilter; // null = all

  static const _statuses = [null, 'open', 'in_progress', 'resolved'];
  static const _statusLabels = {
    null: 'Tous',
    'open': 'Ouvert',
    'in_progress': 'En cours',
    'resolved': 'Résolu',
  };

  @override
  void initState() {
    super.initState();
    _load(firstLoad: true);
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
        !_loadingMore &&
        _page < _totalPages) {
      _loadMore();
    }
  }

  Future<void> _load({bool firstLoad = false}) async {
    if (firstLoad) setState(() => _loading = true);
    try {
      final result = await _repo.getMyTickets(
        page: 1,
        perPage: 10,
        status: _statusFilter,
      );
      if (!mounted) return;
      setState(() {
        _tickets = result.tickets;
        _totalPages = result.totalPages;
        _page = 1;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppSnackBar(e.toString(), isSuccess: false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final result = await _repo.getMyTickets(
        page: _page + 1,
        perPage: 10,
        status: _statusFilter,
      );
      if (!mounted) return;
      setState(() {
        _tickets.addAll(result.tickets);
        _page++;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: HapperAppBar(
        title: 'MES TICKETS',
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RaiseTicketScreen()),
              );
              _load(firstLoad: true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _filterBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _tickets.isEmpty
                    ? _empty()
                    : RefreshIndicator(
                        onRefresh: () => _load(firstLoad: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _tickets.length + (_loadingMore ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i == _tickets.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return _TicketCard(
                              ticket: _tickets[i],
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TicketDetailScreen(
                                      ticketId: _tickets[i].id,
                                    ),
                                  ),
                                );
                                _load(firstLoad: true);
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterBar() {
    return Container(
      color: Colors.white,
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: _statuses.map((s) {
          final selected = _statusFilter == s;
          return GestureDetector(
            onTap: () {
              if (_statusFilter == s) return;
              setState(() => _statusFilter = s);
              _load(firstLoad: true);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? Colors.black : const Color(0xFFDDDDDD),
                ),
              ),
              child: Center(
                child: Text(
                  _statusLabels[s]!,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.support_agent_outlined, size: 56, color: Color(0xFFBBBBBB)),
            const SizedBox(height: 16),
            Text(
              'Aucun ticket trouvé',
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez un ticket pour contacter le support.',
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RaiseTicketScreen()),
                );
                _load(firstLoad: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('CRÉER UN TICKET',
                  style: TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}

// ─── Ticket card widget ────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

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

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor[ticket.status] ?? Colors.grey;
    final priorityColor = _priorityColor[ticket.priority] ?? Colors.grey;
    final date = ticket.createdAt != null
        ? DateFormat('d MMM yyyy', 'fr').format(ticket.createdAt!)
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                    ticket.ticketNumber,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
                _badge(
                    _statusLabel[ticket.status] ?? ticket.status, statusColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket.subject,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              ticket.description,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 13,
                color: Color(0xFF555555),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (ticket.orderId != null || ticket.itemOrderId != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 14, color: Color(0xFF888888)),
                  const SizedBox(width: 4),
                  Text(
                    ticket.itemOrderId ?? ticket.orderId ?? '',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                _badge(
                    _priorityLabel[ticket.priority] ?? ticket.priority,
                    priorityColor),
                const Spacer(),
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 12,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 18, color: Color(0xFFAAAAAA)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      );
}
