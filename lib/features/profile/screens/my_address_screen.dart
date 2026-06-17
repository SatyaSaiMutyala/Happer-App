import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/profile/bindings/user_profile_binding.dart';
import 'package:happer_app/features/profile/controllers/user_profile_controller.dart';
import 'package:happer_app/shared/widgets/confirm_dialog.dart';
import 'package:happer_app/features/profile/bindings/address_binding.dart';
import 'package:happer_app/features/profile/controllers/address_controller.dart';
import 'package:happer_app/features/profile/models/address_model.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';

class MyAddressScreen extends StatelessWidget {
  const MyAddressScreen({super.key});

  void _showForm(BuildContext context, AddressController controller,
      {AddressModel? address}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _AddressFormSheet(controller: controller, address: address),
    );
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

class _AddressFormSheet extends StatefulWidget {
  final AddressController controller;
  final AddressModel? address;

  const _AddressFormSheet({required this.controller, this.address});

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _postalCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _mobileCtrl;
  late bool _isDefault;

  bool get _isEdit => widget.address != null;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _labelCtrl = TextEditingController(text: a?.addressLabel ?? '');
    _firstNameCtrl = TextEditingController(text: a?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: a?.lastName ?? '');
    _streetCtrl = TextEditingController(text: a?.streetAddress ?? '');
    _postalCtrl = TextEditingController(text: a?.postalCode ?? '');
    _cityCtrl = TextEditingController(text: a?.city ?? '');
    _emailCtrl = TextEditingController(text: a?.email ?? '');
    _mobileCtrl = TextEditingController(text: a?.mobileNumber ?? '');
    _isDefault = a?.isDefault ?? false;

    if (!_isEdit) _prefillFromProfile();
  }

  Future<void> _prefillFromProfile() async {
    try {
      UserProfileBinding().dependencies();
      final controller = Get.find<UserProfileController>();
      if (controller.user.value == null) await controller.fetchProfile();
      final user = controller.user.value;
      if (user == null || !mounted) return;
      if (_firstNameCtrl.text.isEmpty) _firstNameCtrl.text = user.firstName;
      if (_lastNameCtrl.text.isEmpty) _lastNameCtrl.text = user.lastName;
      if (_emailCtrl.text.isEmpty) _emailCtrl.text = user.email;
      if (_mobileCtrl.text.isEmpty) _mobileCtrl.text = user.phone ?? '';
    } catch (e) {
      debugPrint('Failed to prefill address from profile: $e');
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _streetCtrl.dispose();
    _postalCtrl.dispose();
    _cityCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _body => {
        'address_label': _labelCtrl.text.trim(),
        'first_name': _firstNameCtrl.text.trim(),
        'last_name': _lastNameCtrl.text.trim(),
        'street_address': _streetCtrl.text.trim(),
        'postal_code': _postalCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'mobile_number': _mobileCtrl.text.trim(),
        'is_default': _isDefault,
      };

  Future<void> _submit(AppLocalizations l) async {
    if (!_formKey.currentState!.validate()) return;
    final ok = _isEdit
        ? await widget.controller.editAddress(widget.address!.id, _body)
        : await widget.controller.addAddress(_body);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      showAppSnackBar(_isEdit ? l.addressUpdated : l.addressAdded);
    } else {
      showAppSnackBar(
        widget.controller.errorMessage.value ?? l.anErrorOccurred,
        isSuccess: false,
      );
    }
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType? keyboard, required String requiredMsg}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        style: const TextStyle(fontFamily: 'Lato', fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              fontFamily: 'Lato', color: Color(0xFFAAAAAA), fontSize: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE53935)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? requiredMsg : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEdit ? l.editAddressTitle : l.newAddressTitle,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _field(l.addressLabelField, _labelCtrl,
                  requiredMsg: l.fieldRequired),
              Row(
                children: [
                  Expanded(
                    child: _field(l.prenom, _firstNameCtrl,
                        requiredMsg: l.fieldRequired),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(l.nom, _lastNameCtrl,
                        requiredMsg: l.fieldRequired),
                  ),
                ],
              ),
              _field(l.adresse, _streetCtrl, requiredMsg: l.fieldRequired),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _field(l.codePostal, _postalCtrl,
                        keyboard: TextInputType.number,
                        requiredMsg: l.fieldRequired),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: _field(l.ville, _cityCtrl,
                        requiredMsg: l.fieldRequired),
                  ),
                ],
              ),
              _field(l.adresseEmail, _emailCtrl,
                  keyboard: TextInputType.emailAddress,
                  requiredMsg: l.fieldRequired),
              _field(l.phoneLabel, _mobileCtrl,
                  keyboard: TextInputType.phone, requiredMsg: l.fieldRequired),
              const SizedBox(height: 4),
              StatefulBuilder(
                builder: (_, setInner) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: SwitchListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    title: const Text(
                      'Adresse par défaut',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: const Text(
                      'Utilisée automatiquement lors du paiement',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 11,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    value: _isDefault,
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.black,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFCCCCCC),
                    onChanged: (v) => setInner(() => _isDefault = v),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => GestureDetector(
                  onTap: widget.controller.isSaving.value
                      ? null
                      : () => _submit(l),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.controller.isSaving.value
                          ? Colors.black45
                          : Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: widget.controller.isSaving.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isEdit ? l.updateButton : l.saveButton,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
