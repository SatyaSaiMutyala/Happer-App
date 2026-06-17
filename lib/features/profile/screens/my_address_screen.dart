import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/shared/widgets/confirm_dialog.dart';
import 'package:happer_app/features/profile/bindings/address_binding.dart';
import 'package:happer_app/features/profile/controllers/address_controller.dart';
import 'package:happer_app/features/profile/models/address_model.dart';
import 'package:happer_app/features/profile/widgets/address_form_sheet.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';

class MyAddressScreen extends StatelessWidget {
  const MyAddressScreen({super.key});

  void _showForm(BuildContext context, AddressController controller,
      {AddressModel? address}) {
    showAddressFormSheet(context, controller, address: address);
  }

  Future<void> _confirmDelete(
      BuildContext context, AddressController controller, String id) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l.deleteAddressTitle,
      message: l.deleteAddressConfirm,
      confirmLabel: l.delete,
      cancelLabel: l.cancel,
      icon: Icons.delete_outline_rounded,
      isDangerous: true,
    );
    if (confirmed) {
      final ok = await controller.deleteAddress(id);
      if (ok) showAppSnackBar(l.addressDeleted);
    }
  }

  @override
  Widget build(BuildContext context) {
    AddressBinding().dependencies();
    final controller = Get.find<AddressController>();
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: HapperAppBar(
        title: l.myAddressesTitle,
        actions: [
          GestureDetector(
            onTap: () => _showForm(context, controller),
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
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }

        if (controller.errorMessage.value != null &&
            controller.addresses.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.wifi_off_outlined,
                        size: 32, color: Colors.black45),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    controller.errorMessage.value!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: controller.fetchAddresses,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l.tryAgainButton,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.addresses.isEmpty) {
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
                  Text(
                    l.noAddressRegistered,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      color: Color(0xFF888888),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => _showForm(context, controller),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            l.addAddress,
                            style: const TextStyle(
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

        return RefreshIndicator(
          color: Colors.black,
          onRefresh: controller.fetchAddresses,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            itemCount: controller.addresses.length,
            itemBuilder: (context, index) {
              final address = controller.addresses[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _AddressItem(
                  address: address,
                  onEdit: () =>
                      _showForm(context, controller, address: address),
                  onDelete: () =>
                      _confirmDelete(context, controller, address.id),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _AddressItem extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressItem({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDefault = address.isDefault;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault ? Colors.black : const Color(0xFFEEEEEE),
          width: isDefault ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDefault ? 0.08 : 0.04),
            blurRadius: isDefault ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDefault ? Colors.black : const Color(0xFFF8F8F8),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: isDefault ? Colors.white : Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  address.addressLabel.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDefault ? Colors.white : Colors.black,
                    letterSpacing: 1.2,
                  ),
                ),
                if (isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'Par défaut',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                _HeaderAction(
                  icon: Icons.edit_outlined,
                  tooltip: l.editAddressTitle,
                  onTap: onEdit,
                  isDefault: isDefault,
                ),
                const SizedBox(width: 6),
                _HeaderAction(
                  icon: Icons.delete_outline_rounded,
                  tooltip: l.deleteAddressTitle,
                  onTap: onDelete,
                  isDefault: isDefault,
                  isDanger: true,
                ),
              ],
            ),
          ),

          // ── Body ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 15, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 10),
                    Text(
                      '${address.firstName} ${address.lastName}',
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 10),
                // Street + Postal + City
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text:
                      '${address.streetAddress}\n${address.postalCode} ${address.city}',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.mail_outline_rounded,
                  text: address.email,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  text: address.mobileNumber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDefault;
  final bool isDanger;

  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.isDefault,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isDefault
                ? (isDanger
                    ? Colors.red.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.18))
                : (isDanger
                    ? const Color(0xFFFDECEC)
                    : const Color(0xFFEEEEEE)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 15,
            color: isDanger
                ? (isDefault ? Colors.red.shade200 : const Color(0xFFD32F2F))
                : (isDefault ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 14, color: const Color(0xFFBBBBBB)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF555555),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
