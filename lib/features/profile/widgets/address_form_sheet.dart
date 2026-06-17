import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/profile/bindings/user_profile_binding.dart';
import 'package:happer_app/features/profile/controllers/user_profile_controller.dart';
import 'package:happer_app/features/profile/controllers/address_controller.dart';
import 'package:happer_app/features/profile/models/address_model.dart';
import 'package:happer_app/l10n/app_localizations.dart';

/// Shows the add / edit address form as a modal bottom sheet.
///
/// Returns `true` when an address was successfully saved, otherwise `null`
/// (sheet dismissed without saving).
Future<bool?> showAddressFormSheet(
  BuildContext context,
  AddressController controller, {
  AddressModel? address,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => AddressFormSheet(controller: controller, address: address),
  );
}

class AddressFormSheet extends StatefulWidget {
  final AddressController controller;
  final AddressModel? address;

  const AddressFormSheet({super.key, required this.controller, this.address});

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
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
      Navigator.pop(context, true);
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
