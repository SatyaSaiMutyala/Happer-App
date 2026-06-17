import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/auth/controllers/auth_controller.dart';
import 'package:happer_app/features/auth/screens/contract_webview_screen.dart';
import 'package:happer_app/features/profile/bindings/user_profile_binding.dart';
import 'package:happer_app/features/profile/controllers/user_profile_controller.dart';
import 'package:happer_app/features/profile/models/user_profile_model.dart';

class EsignPopup extends StatefulWidget {
  final UserProfileModel user;
  final VoidCallback onDone;

  const EsignPopup({super.key, required this.user, required this.onDone});

  @override
  State<EsignPopup> createState() => _EsignPopupState();
}

class _EsignPopupState extends State<EsignPopup>
    with SingleTickerProviderStateMixin {
  late int _step;
  bool _checked = false;
  bool _isSaving = false;
  late AnimationController _animCtrl;
  late Animation<Offset> _slideIn;

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _phoneCtrl;
  late String _countryCode;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _postalCtrl;
  late final TextEditingController _cityCtrl;
  final _formKey = GlobalKey<FormState>();

  bool _usernameError = false;
  bool _isCheckingUsername = false;
  final FocusNode _usernameFocusNode = FocusNode();

  static final _usernameRegex = RegExp(r'^[a-z0-9_.]{3,20}$');

  // Only show the username field when the user hasn't set one yet
  bool get _needsUsername => widget.user.username.trim().isEmpty;

  bool get _profileComplete {
    final u = widget.user;
    return u.username.trim().isNotEmpty &&
        u.firstName.trim().isNotEmpty &&
        u.lastName.trim().isNotEmpty &&
        (u.phone?.trim().isNotEmpty ?? false) &&
        (u.streetAddress?.trim().isNotEmpty ?? false) &&
        (u.postalCode?.trim().isNotEmpty ?? false) &&
        (u.city?.trim().isNotEmpty ?? false);
  }

  @override
  void initState() {
    super.initState();
    _step = _profileComplete ? 2 : 1;
    _firstNameCtrl = TextEditingController(text: widget.user.firstName);
    _lastNameCtrl = TextEditingController(text: widget.user.lastName);
    _usernameCtrl = TextEditingController(text: widget.user.username);
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _countryCode = widget.user.countryCode?.trim().isNotEmpty == true
        ? widget.user.countryCode!
        : '+33';
    _streetCtrl = TextEditingController(text: widget.user.streetAddress ?? '');
    _postalCtrl = TextEditingController(text: widget.user.postalCode ?? '');
    _cityCtrl = TextEditingController(text: widget.user.city ?? '');
    _usernameFocusNode.addListener(_onUsernameFocusChange);

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _animCtrl.value =
        1.0; // always start fully visible; only animated on step transition
  }

  void _onUsernameFocusChange() {
    if (!_usernameFocusNode.hasFocus) {
      _checkUsernameAvailability();
    }
  }

  Future<void> _checkUsernameAvailability() async {
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty || !_usernameRegex.hasMatch(username)) return;
    setState(() => _isCheckingUsername = true);
    try {
      final authCtrl = Get.find<AuthController>();
      final available = await authCtrl.checkUsernameAvailability(username);
      if (mounted) setState(() => _usernameError = !available);
    } catch (_) {
      if (mounted) setState(() => _usernameError = false);
    } finally {
      if (mounted) setState(() => _isCheckingUsername = false);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _usernameFocusNode.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _postalCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _goToStep2() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_needsUsername) {
      final username = _usernameCtrl.text.trim();
      if (username.isEmpty || !_usernameRegex.hasMatch(username)) {
        setState(() => _usernameError = true);
        return;
      }
      if (_usernameError) return;
      // Run availability check if not already done
      if (!_isCheckingUsername) await _checkUsernameAvailability();
      if (_usernameError || !mounted) return;
    }

    setState(() => _isSaving = true);
    try {
      UserProfileBinding().dependencies();
      final ctrl = Get.find<UserProfileController>();
      final success = await ctrl.editProfile(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        username:
            _needsUsername ? _usernameCtrl.text.trim() : widget.user.username,
        mobileNumber: _phoneCtrl.text.trim(),
        countryCode: _countryCode,
        streetAddress: _streetCtrl.text.trim(),
        postalCode: _postalCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
      );
      if (!success || !mounted) return;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }

    _animCtrl.reset();
    setState(() => _step = 2);
    _animCtrl.forward();
  }

  Future<void> _activate() async {
    setState(() => _isSaving = true);
    try {
      UserProfileBinding().dependencies();
      final ctrl = Get.find<UserProfileController>();
      final success = await ctrl.completeEsign();
      if (!mounted) return;
      if (success) {
        Navigator.of(context).pop();
        widget.onDone();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: SlideTransition(
            position: _slideIn,
            child: _step == 1 ? _buildStep1() : _buildStep2(),
          ),
        ),
      ),
    );
  }

  // ─── Step 1: Required profile fields ──────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(step: 1),
            const SizedBox(height: 8),
            const Text(
              'Ces informations sont requises pour établir votre contrat Creator.',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _field(_firstNameCtrl, 'Prénom')),
                const SizedBox(width: 12),
                Expanded(child: _field(_lastNameCtrl, 'Nom')),
              ],
            ),
            if (_needsUsername) ...[
              const SizedBox(height: 12),
              _buildUsernameField(),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    onSelect: (country) =>
                        setState(() => _countryCode = '+${country.phoneCode}'),
                  ),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_countryCode,
                            style: const TextStyle(
                                fontFamily: 'Lato', fontSize: 14)),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_drop_down,
                            size: 18, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _field(_phoneCtrl, 'Téléphone',
                      keyboardType: TextInputType.phone),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _field(_streetCtrl, 'Adresse'),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: _field(_postalCtrl, 'Code Postal',
                      keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(child: _field(_cityCtrl, 'Ville')),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _goToStep2,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SUIVANT',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward,
                              size: 16, color: Colors.white),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 2: Contract + checkbox ──────────────────────────────────────────

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(step: 2),
          const SizedBox(height: 16),
          const Text(
            'Vous pouvez désormais activer votre compte de créateur Happer.',
            style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                color: Colors.black,
                height: 1.5),
          ),
          const SizedBox(height: 10),
          const Text(
            'Vous pourrez recevoir des produits de nos marques partenaires, les partager sur Happer et générer des revenus sur les ventes réalisées via votre contenu.',
            style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                color: Colors.black,
                height: 1.5),
          ),
          const SizedBox(height: 14),
          const Text(
            'En acceptant, vous confirmez :',
            style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                color: Colors.black,
                height: 1.5),
          ),
          const SizedBox(height: 8),
          _bullet('Publier les produits reçus selon les délais convenus'),
          _bullet('Respecter les règles de collaboration'),
          _bullet('Garantir l\'authenticité de votre contenu'),
          _bullet(
              'Autoriser Happer à exploiter le contenu conformément au contrat'),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  color: Colors.black,
                  height: 1.5),
              children: [
                const TextSpan(
                    text: 'Cette collaboration est encadrée par le '),
                TextSpan(
                  text: 'Contrat Happer Creator',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ContractWebViewScreen()),
                        ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => setState(() => _checked = !_checked),
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _checked ? Colors.black : Colors.white,
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _checked
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Je reconnais avoir pris connaissance du Contrat Happer Creator, l\'accepter sans réserve et m\'engager à le respecter.',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Back button (only if started from step 1)
          if (!_profileComplete)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  _animCtrl.reset();
                  setState(() => _step = 1);
                  _animCtrl.forward();
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 14, color: Colors.black54),
                    SizedBox(width: 4),
                    Text(
                      'Modifier mes informations',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 12,
                        color: Colors.black54,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (_checked && !_isSaving) ? _activate : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : Text(
                      'ACTIVER MON COMPTE CREATOR',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _checked ? Colors.white : Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared widgets ────────────────────────────────────────────────────────

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _usernameCtrl,
          focusNode: _usernameFocusNode,
          style: const TextStyle(fontFamily: 'Lato', fontSize: 14),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            // Only allow lowercase letters, digits, underscore, dot
            FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_.]')),
          ],
          onChanged: (_) {
            if (_usernameError) setState(() => _usernameError = false);
          },
          decoration: InputDecoration(
            labelText: 'Nom d\'utilisateur',
            labelStyle: const TextStyle(
                fontFamily: 'Lato', fontSize: 13, color: Colors.black54),
            hintText: 'ex: jean.dupont_12',
            hintStyle: const TextStyle(
                fontFamily: 'Lato', fontSize: 13, color: Colors.black26),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: _usernameError ? Colors.red : Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: _usernameError ? Colors.red : Colors.black,
                  width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            isDense: true,
            suffixIcon: _isCheckingUsername
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black54)),
                    ),
                  )
                : _usernameError
                    ? const Icon(Icons.close, color: Colors.red, size: 18)
                    : null,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Requis';
            if (!_usernameRegex.hasMatch(v.trim())) {
              return '3–20 caractères : lettres minuscules, chiffres, _ ou .';
            }
            return null;
          },
        ),
        if (_usernameError)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 4),
            child: Text(
              'Ce nom d\'utilisateur est déjà pris',
              style: TextStyle(
                  fontFamily: 'Lato', fontSize: 11, color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader({required int step}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'ACTIVEZ VOTRE COMPTE\nHAPPER CREATOR',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: Colors.black,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Step indicator
        Row(
          children: [
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                decoration: BoxDecoration(
                  color: step == 2 ? Colors.black : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Étape $step sur 2',
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 11,
            color: Colors.black54,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'Lato', fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontFamily: 'Lato', fontSize: 13, color: Colors.black54),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        isDense: true,
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(
                  fontFamily: 'Lato', fontSize: 14, color: Colors.black)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  color: Colors.black,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
