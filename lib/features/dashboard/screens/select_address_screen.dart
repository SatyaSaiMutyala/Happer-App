import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/profile/bindings/address_binding.dart';
import 'package:happer_app/features/profile/controllers/address_controller.dart';
import 'package:happer_app/features/profile/models/address_model.dart';
import 'package:happer_app/features/profile/widgets/address_form_sheet.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:shimmer/shimmer.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({super.key});

  @override
  State<SelectAddressScreen> createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  late AddressController _controller;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    AddressBinding().dependencies();
    _controller = Get.find<AddressController>();
  }

  void _confirm() {
    final selected = _controller.addresses.firstWhereOrNull(
      (a) => a.id == _selectedId,
    );
    if (selected != null) Navigator.pop(context, selected);
  }

  void _openAddAddress() async {
    final existingIds = _controller.addresses.map((a) => a.id).toSet();
    final saved = await showAddressFormSheet(context, _controller);
    if (saved != true || !mounted) return;
    // The form's controller already refreshed the list; auto-select the
    // newly added address (or fall back to the default / first one).
    final added = _controller.addresses
        .firstWhereOrNull((a) => !existingIds.contains(a.id));
    final toSelect = added ??
        _controller.addresses.firstWhereOrNull((a) => a.isDefault) ??
        (_controller.addresses.isNotEmpty
            ? _controller.addresses.first
            : null);
    if (toSelect != null) setState(() => _selectedId = toSelect.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: HapperAppBar(
        title: 'MES ADRESSES',
        actions: [
          GestureDetector(
            onTap: _openAddAddress,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, color: Colors.white, size: 15),
                  SizedBox(width: 4),
                  Text(
                    'Ajouter',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) return _buildShimmer();

        final addresses = _controller.addresses;
        if (addresses.isEmpty) return _buildEmpty();

        // Auto-select default address (or first) on first load
        if (_selectedId == null) {
          final def =
              addresses.firstWhereOrNull((a) => a.isDefault) ?? addresses.first;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedId = def.id);
          });
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                itemCount: addresses.length,
                itemBuilder: (_, i) => _buildAddressCard(addresses[i]),
              ),
            ),
            _buildConfirmBar(),
          ],
        );
      }),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    final isSelected = _selectedId == address.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedId = address.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFEEEEEE),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.03),
              blurRadius: isSelected ? 16 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : const Color(0xFFF8F8F8),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  // Radio indicator
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    address.addressLabel.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (address.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        'Par défaut',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Body ──
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    '${address.firstName} ${address.lastName}',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 8),
                  // Street
                  _InfoLine(
                    icon: Icons.location_on_outlined,
                    text:
                        '${address.streetAddress}, ${address.postalCode} ${address.city}',
                  ),
                  if (address.mobileNumber.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _InfoLine(
                      icon: Icons.phone_outlined,
                      text: address.mobileNumber,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmBar() {
    final canConfirm = _selectedId != null;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: GestureDetector(
            onTap: canConfirm ? _confirm : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              decoration: BoxDecoration(
                color: canConfirm ? Colors.black : const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: canConfirm ? Colors.white : Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CONFIRMER',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: canConfirm ? Colors.white : Colors.white70,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.location_off_outlined,
                  size: 40, color: Colors.black38),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucune adresse',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez une adresse pour continuer votre commande',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                color: Color(0xFF888888),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _openAddAddress,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Ajouter une adresse',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 14, color: const Color(0xFFBBBBBB)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 13,
              color: Color(0xFF666666),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
