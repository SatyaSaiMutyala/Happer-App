import 'dart:io';

import 'package:flutter/material.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/profile/data/repositories/tickets_repository.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:image_picker/image_picker.dart';

class RaiseTicketScreen extends StatefulWidget {
  /// Pre-fill purchase link when navigating from a purchase item.
  final String? cartId;
  final String? itemId;

  const RaiseTicketScreen({super.key, this.cartId, this.itemId});

  @override
  State<RaiseTicketScreen> createState() => _RaiseTicketScreenState();
}

class _RaiseTicketScreenState extends State<RaiseTicketScreen> {
  final _repo = TicketsRepository();
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _priority = 'medium';
  final List<XFile> _photos = [];
  bool _submitting = false;

  static const _priorities = ['low', 'medium', 'high'];
  static const _priorityLabels = {
    'low': 'Faible',
    'medium': 'Moyenne',
    'high': 'Haute',
  };
  static const _priorityColors = {
    'low': Color(0xFF43A047),
    'medium': Color(0xFFFF9800),
    'high': Color(0xFFE53935),
  };

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        // Cap at 5 images total
        final remaining = 5 - _photos.length;
        _photos.addAll(picked.take(remaining));
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      // Upload images first, collect URLs
      final imageUrls = <String>[];
      for (final photo in _photos) {
        final url = await _repo.uploadImage(photo.path);
        if (url.isNotEmpty) imageUrls.add(url);
      }

      await _repo.raiseTicket(
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        cartId: widget.cartId,
        itemId: widget.itemId,
        images: imageUrls,
      );

      if (!mounted) return;
      showAppSnackBar('Ticket créé avec succès', isSuccess: true);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showAppSnackBar(e.toString(), isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: HapperAppBar(title: 'NOUVEAU TICKET'),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.cartId != null) _purchaseLinkedBanner(),
                    _sectionLabel('SUJET *'),
                    const SizedBox(height: 6),
                    _textField(
                      controller: _subjectController,
                      hint: 'Décrivez votre problème en une ligne…',
                      maxLines: 1,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Le sujet est obligatoire';
                        }
                        if (v.trim().length < 5) {
                          return 'Sujet trop court (min. 5 caractères)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('DESCRIPTION *'),
                    const SizedBox(height: 6),
                    _textField(
                      controller: _descriptionController,
                      hint: 'Décrivez votre problème en détail…',
                      maxLines: 5,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'La description est obligatoire';
                        }
                        if (v.trim().length < 10) {
                          return 'Description trop courte (min. 10 caractères)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('PRIORITÉ'),
                    const SizedBox(height: 8),
                    _priorityPicker(),
                    const SizedBox(height: 16),
                    _sectionLabel('PHOTOS (optionnel, max. 5)'),
                    const SizedBox(height: 8),
                    _photoSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _submitBar(),
          ],
        ),
      ),
    );
  }

  // ─── Purchase linked banner ───────────────────────────────────────────────
  Widget _purchaseLinkedBanner() => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF4FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFBBD1FF)),
        ),
        child: const Row(
          children: [
            Icon(Icons.link_rounded, size: 16, color: Color(0xFF3B7BF5)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ce ticket sera lié à votre commande.',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 13,
                  color: Color(0xFF3B7BF5),
                ),
              ),
            ),
          ],
        ),
      );

  // ─── Section label ────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.6,
          color: Color(0xFF888888),
        ),
      );

  // ─── Text field ───────────────────────────────────────────────────────────
  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        minLines: 1,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(fontFamily: 'Lato', fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'Lato', fontSize: 14, color: Color(0xFFBBBBBB)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE53935)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
          ),
        ),
      );

  // ─── Priority picker ──────────────────────────────────────────────────────
  Widget _priorityPicker() => Row(
        children: _priorities.map((p) {
          final selected = _priority == p;
          final color = _priorityColors[p]!;
          return GestureDetector(
            onTap: () => setState(() => _priority = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? color : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected ? color : const Color(0xFFDDDDDD),
                  width: 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Text(
                _priorityLabels[p]!,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: selected ? Colors.white : const Color(0xFF555555),
                ),
              ),
            ),
          );
        }).toList(),
      );

  // ─── Photo section ────────────────────────────────────────────────────────
  Widget _photoSection() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ..._photos.asMap().entries.map((entry) {
          final i = entry.key;
          final photo = entry.value;
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(photo.path),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _photos.removeAt(i)),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),
        if (_photos.length < 5)
          GestureDetector(
            onTap: _pickPhotos,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFDDDDDD), style: BorderStyle.solid),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 26, color: Color(0xFFAAAAAA)),
                  SizedBox(height: 4),
                  Text(
                    'Ajouter',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 11,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ─── Submit bar ───────────────────────────────────────────────────────────
  Widget _submitBar() => SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'SOUMETTRE LE TICKET',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      );
}
