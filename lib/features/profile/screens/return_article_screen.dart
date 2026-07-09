import 'dart:io';

import 'package:flutter/material.dart';
import 'package:happer_app/features/profile/models/purchase_model.dart';
import 'package:happer_app/features/profile/screens/return_refund_screen_new.dart';
import 'package:happer_app/features/profile/screens/return_request_screen.dart';
import 'package:happer_app/features/profile/widgets/order_product_header.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:image_picker/image_picker.dart';

/// "RETOURNER CET ARTICLE" — the return-request form: pick a reason, optionally
/// add a comment and photos, then submit to open the return-status screen.
class ReturnArticleScreen extends StatefulWidget {
  final PurchasedProduct order;

  const ReturnArticleScreen({super.key, required this.order});

  @override
  State<ReturnArticleScreen> createState() => _ReturnArticleScreenState();
}

class _ReturnArticleScreenState extends State<ReturnArticleScreen> {
  static const _reasons = [
    (Icons.straighten, 'Taille incorrecte'),
    (Icons.dangerous_outlined, 'Article endommagé'),
    (Icons.inventory_2_outlined, 'Article non conforme à la description'),
    (Icons.sentiment_dissatisfied_outlined, 'L\'article ne me convient pas'),
    (Icons.chat_bubble_outline, 'Autre motif'),
  ];

  int _selected = 0;
  bool _commentExpanded = false;
  bool _photosExpanded = false;
  final _commentController = TextEditingController();
  final List<XFile> _photos = [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => _photos.addAll(picked));
    }
  }

  void _submit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReturnRequestScreen(
          order: widget.order,
          reason: _reasons[_selected].$2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(
        title: 'RETOURNER CET ARTICLE',
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrderProductHeader(order: widget.order),
                  const SizedBox(height: 20),
                  _infoBanner(),
                  const SizedBox(height: 18),
                  _reasonsCard(),
                  const SizedBox(height: 18),
                  _extrasCard(),
                ],
              ),
            ),
          ),
          _submitButton(),
        ],
      ),
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
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

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6EC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF9DD5A8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 22, color: Color(0xFF3B3B3B)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  height: 1.4,
                  color: Color(0xFF1A1A1A),
                ),
                children: [
                  TextSpan(text: 'Vous disposez de '),
                  TextSpan(
                      text: '14 jours',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(
                      text:
                          ' après réception pour effectuer une demande de retour'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reasonsCard() {
    return _card(
      child: Column(
        children: [
          for (int i = 0; i < _reasons.length; i++) ...[
            if (i > 0) _divider(),
            InkWell(
              onTap: () => setState(() => _selected = i),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    _radio(_selected == i),
                    const SizedBox(width: 16),
                    Icon(_reasons[i].$1, size: 26, color: Colors.black),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _reasons[i].$2,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _radio(bool selected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? Colors.black : const Color(0xFFBDBDBD),
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.black),
              ),
            )
          : null,
    );
  }

  Widget _extrasCard() {
    return _card(
      child: Column(
        children: [
          _expandableRow(
            icon: Icons.add_comment_outlined,
            title: 'Ajouter un commentaire',
            expanded: _commentExpanded,
            onTap: () => setState(() => _commentExpanded = !_commentExpanded),
          ),
          if (_commentExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: TextField(
                controller: _commentController,
                maxLines: 3,
                style: const TextStyle(fontFamily: 'Lato', fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Votre commentaire…',
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),
            ),
          _divider(),
          _expandableRow(
            icon: Icons.add_a_photo_outlined,
            title: 'Ajouter des photos de l\'article',
            expanded: _photosExpanded,
            onTap: () => setState(() => _photosExpanded = !_photosExpanded),
          ),
          if (_photosExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickPhotos,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCFCFCF)),
                      ),
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _photos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_photos[i].path),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _divider(),
          InkWell(
            onTap: () {
              // Opens the return policy — wire to the policy URL when available.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Conditions de retour bientôt disponibles')),
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.assignment_outlined,
                      size: 26, color: Colors.black),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Consulter les conditions de retour',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  _externalBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expandableRow({
    required IconData icon,
    required String title,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 26, color: Colors.black),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ),
            Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _externalBox() {
    return Container(
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
    );
  }

  Widget _divider() => const Divider(
      height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFEDEDED));

  Widget _submitButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'ENVOYER LA DEMANDE DE RETOUR',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
