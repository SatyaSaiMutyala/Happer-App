import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/creator/models/cart_model.dart';
import 'package:happer_app/features/dashboard/bindings/cart_binding.dart';
import 'package:happer_app/features/dashboard/data/repositories/cart_repository.dart';
import 'package:happer_app/features/profile/data/repositories/address_repository.dart';
import 'package:happer_app/features/profile/models/address_model.dart';

class AddressScreen extends StatefulWidget {
  final String cartId;

  AddressScreen({required this.cartId});

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _isLoading = true;
  bool _useProfileShippingAddress = false;
  bool _useProfileBillingAddress = false;
  Data? _cartData;
  AddressModel? _profileAddress;
  bool _mounted = true;

  // Text controllers for shipping address
  final TextEditingController _shippingNameController = TextEditingController();
  final TextEditingController _shippingFirstNameController =
      TextEditingController();
  final TextEditingController _shippingAddressController =
      TextEditingController();
  final TextEditingController _shippingPostalController =
      TextEditingController();
  final TextEditingController _shippingCityController = TextEditingController();
  final TextEditingController _shippingEmailController =
      TextEditingController();
  final TextEditingController _shippingPhoneController =
      TextEditingController();

  // Text controllers for billing address
  final TextEditingController _billingNameController = TextEditingController();
  final TextEditingController _billingFirstNameController =
      TextEditingController();
  final TextEditingController _billingAddressController =
      TextEditingController();
  final TextEditingController _billingPostalController =
      TextEditingController();
  final TextEditingController _billingCityController = TextEditingController();
  final TextEditingController _billingEmailController = TextEditingController();
  final TextEditingController _billingPhoneController = TextEditingController();

  bool _isButtonEnabled = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.cartId == 'profile' || widget.cartId == 'mock_cart') {
      if (_mounted) {
        setState(() => _isLoading = false);
      }
    } else {
      _fetchCartDetails();
      _loadProfileAddress();
    }

    // Add listeners to all controllers for robust validation
    _shippingNameController.addListener(_checkFieldsFilled);
    _shippingFirstNameController.addListener(_checkFieldsFilled);
    _shippingAddressController.addListener(_checkFieldsFilled);
    _shippingPostalController.addListener(_checkFieldsFilled);
    _shippingCityController.addListener(_checkFieldsFilled);
    _shippingEmailController.addListener(_checkFieldsFilled);
    _shippingPhoneController.addListener(_checkFieldsFilled);
    _billingNameController.addListener(_checkFieldsFilled);
    _billingFirstNameController.addListener(_checkFieldsFilled);
    _billingAddressController.addListener(_checkFieldsFilled);
    _billingPostalController.addListener(_checkFieldsFilled);
    _billingCityController.addListener(_checkFieldsFilled);
    _billingEmailController.addListener(_checkFieldsFilled);
    _billingPhoneController.addListener(_checkFieldsFilled);

    _checkFieldsFilled(); // initial check
  }

  void _checkFieldsFilled() {
    setState(() {
      _isButtonEnabled = true;
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _shippingNameController.dispose();
    _shippingFirstNameController.dispose();
    _shippingAddressController.dispose();
    _shippingPostalController.dispose();
    _shippingCityController.dispose();
    _shippingEmailController.dispose();
    _shippingPhoneController.dispose();

    _billingNameController.dispose();
    _billingFirstNameController.dispose();
    _billingAddressController.dispose();
    _billingPostalController.dispose();
    _billingCityController.dispose();
    _billingEmailController.dispose();
    _billingPhoneController.dispose();

    _mounted = false;
    super.dispose();
  }

  Future<void> _fetchCartDetails() async {
    try {
      CartBinding().dependencies();
      final repo = Get.find<CartRepository>();
      final cartData = await repo.getMyCart();
      final cartModel = cartData != null
          ? CartModel.fromJson({'status': 200, 'data': cartData})
          : null;

      if (_mounted) {
        setState(() {
          _cartData = cartModel?.data;
          _isLoading = false;
        });
        _checkFieldsFilled();
      }
    } catch (e) {
      debugPrint('Error fetching cart details: $e');
      if (_mounted) {
        _showErrorSnackbar('Could not load cart details. Please try again.');
      }
    }
  }

  Future<void> _loadProfileAddress() async {
    try {
      final addresses = await AddressRepository().getAllAddresses();
      if (addresses.isEmpty) return;

      final addr = addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses.first,
      );

      if (_mounted) {
        setState(() {
          _profileAddress = addr;
          _useProfileShippingAddress = true;
          _shippingFirstNameController.text = addr.firstName;
          _shippingNameController.text      = addr.lastName;
          _shippingAddressController.text   = addr.streetAddress;
          _shippingPostalController.text    = addr.postalCode;
          _shippingCityController.text      = addr.city;
          _shippingEmailController.text     = addr.email;
          _shippingPhoneController.text     = addr.mobileNumber;

          _useProfileBillingAddress = true;
          _billingFirstNameController.text = addr.firstName;
          _billingNameController.text      = addr.lastName;
          _billingAddressController.text   = addr.streetAddress;
          _billingPostalController.text    = addr.postalCode;
          _billingCityController.text      = addr.city;
          _billingEmailController.text     = addr.email;
          _billingPhoneController.text     = addr.mobileNumber;
        });
        _checkFieldsFilled();
      }
    } catch (e) {
      debugPrint('Error loading default address: $e');
    }
  }

  double _calculateSubTotal() {
    return _cartData?.items?.fold(0.0, (sum, item) {
          final price = item.price ?? 0.0;
          final quantity = item.quantity ?? 1;
          return sum! + (price * quantity);
        }) ??
        0.0;
  }

  double _calculateShipping() {
    return (_cartData?.totalShippingPrice ?? 0).toDouble();
  }


  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    // Dismiss any existing snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.visible,
                maxLines: 3,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // 'ADDRESS',
          'ADRESSE',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildContent(),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUseProfileShippingCheckbox(),
                  SizedBox(height: 12),
                  _builShippingAddressCard(),
                  SizedBox(height: 12),
                  _builBillingAddressCard(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Fixed checkout section at bottom
          // Container(
          //   color: Colors.white,
          //   padding: EdgeInsets.all(16),
          //   child: SafeArea(child: _buildCheckoutSection()),
          // ),
          SafeArea(
          top: false,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: _buildCheckoutSection(),
          ),
        )
        ],
      ),
    );
  }

  Widget _buildUseProfileShippingCheckbox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _useProfileShippingAddress = !_useProfileShippingAddress;

            if (_useProfileShippingAddress && _profileAddress != null) {
              _shippingNameController.text      = _profileAddress!.lastName;
              _shippingFirstNameController.text = _profileAddress!.firstName;
              _shippingAddressController.text   = _profileAddress!.streetAddress;
              _shippingPostalController.text    = _profileAddress!.postalCode;
              _shippingCityController.text      = _profileAddress!.city;
              _shippingEmailController.text     = _profileAddress!.email;
              _shippingPhoneController.text     = _profileAddress!.mobileNumber;
            } else {
              _shippingNameController.clear();
              _shippingFirstNameController.clear();
              _shippingAddressController.clear();
              _shippingPostalController.clear();
              _shippingCityController.clear();
              _shippingEmailController.clear();
              _shippingPhoneController.clear();
            }
          });
        },
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: _useProfileShippingAddress,
                onChanged: (value) {
                  setState(() {
                    _useProfileShippingAddress = value ?? false;

                    if (_useProfileShippingAddress && _profileAddress != null) {
                      _shippingNameController.text      = _profileAddress!.lastName;
                      _shippingFirstNameController.text = _profileAddress!.firstName;
                      _shippingAddressController.text   = _profileAddress!.streetAddress;
                      _shippingPostalController.text    = _profileAddress!.postalCode;
                      _shippingCityController.text      = _profileAddress!.city;
                      _shippingEmailController.text     = _profileAddress!.email;
                      _shippingPhoneController.text     = _profileAddress!.mobileNumber;
                    } else {
                      _shippingNameController.clear();
                      _shippingFirstNameController.clear();
                      _shippingAddressController.clear();
                      _shippingPostalController.clear();
                      _shippingCityController.clear();
                      _shippingEmailController.clear();
                      _shippingPhoneController.clear();
                    }
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(color: Colors.grey[400]!),
                activeColor: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Utiliser l'adresse de mon profil",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _builShippingAddressCard() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              _buildAddressField('Nom', _shippingFirstNameController),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              _buildAddressField('Prénom', _shippingNameController),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              _buildAddressField('Adresse', _shippingAddressController),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              _buildAddressField('Code postal', _shippingPostalController),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              _buildAddressField('Ville', _shippingCityController),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              _buildAddressField('E-mail', _shippingEmailController),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              _buildAddressField('Phone', _shippingPhoneController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _builBillingAddressCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          'ADDRESSE DE FACTURATION',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            setState(() {
              _useProfileBillingAddress = !_useProfileBillingAddress;
              if (_useProfileBillingAddress &&
                  _profileAddress != null) {
                // Update billing address fields with profile data
                _billingNameController.text =
                    _shippingNameController.text;
                _billingFirstNameController.text =
                    _shippingFirstNameController.text;
                _billingAddressController.text =
                    _shippingAddressController.text;
                _billingPostalController.text =
                    _shippingPostalController.text;
                _billingCityController.text =
                    _shippingCityController.text;
                _billingEmailController.text =
                    _shippingEmailController.text;
                _billingPhoneController.text =
                    _shippingPhoneController.text;
              } else {
                // Clear billing address fields when unchecked
                _billingNameController.text = '';
                _billingFirstNameController.text = '';
                _billingAddressController.text = '';
                _billingPostalController.text = '';
                _billingCityController.text = '';
                _billingEmailController.text = '';
                _billingPhoneController.text = '';
              }
            });
          },
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _useProfileBillingAddress,
                  onChanged: (value) {
                    setState(() {
                      _useProfileBillingAddress = value ?? false;
                      if (_useProfileBillingAddress &&
                          _profileAddress != null) {
                        // Update billing address fields with profile data
                        _billingNameController.text =
                            _shippingNameController.text;
                        _billingFirstNameController.text =
                            _shippingFirstNameController.text;
                        _billingAddressController.text =
                            _shippingAddressController.text;
                        _billingPostalController.text =
                            _shippingPostalController.text;
                        _billingCityController.text =
                            _shippingCityController.text;
                        _billingEmailController.text =
                            _shippingEmailController.text;
                        _billingPhoneController.text =
                            _shippingPhoneController.text;
                      } else {
                        // Clear billing address fields when unchecked
                        _billingNameController.text = '';
                        _billingFirstNameController.text = '';
                        _billingAddressController.text = '';
                        _billingPostalController.text = '';
                        _billingCityController.text = '';
                        _billingEmailController.text = '';
                        _billingPhoneController.text = '';
                      }
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(color: Colors.grey[400]!),
                  activeColor: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Utiliser l'adresse saisie dans Mon Profil",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Lato',
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildAddressField('Nom', _billingFirstNameController),
              Divider(height: 1, color: Colors.grey[300]),
              _buildAddressField('Prénom', _billingNameController),
              Divider(height: 1, color: Colors.grey[300]),
              _buildAddressField('Adresse', _billingAddressController),
              Divider(height: 1, color: Colors.grey[300]),
              _buildAddressField('Code postal', _billingPostalController),
              Divider(height: 1, color: Colors.grey[300]),
              _buildAddressField('Ville', _billingCityController),
              Divider(height: 1, color: Colors.grey[300]),
              _buildAddressField('E-mail', _billingEmailController),
              Divider(height: 1, color: Colors.grey[300]),
              _buildAddressField('Phone', _billingPhoneController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutSection() {
    debugPrint('Building checkout section - Button enabled: $_isButtonEnabled');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: Colors.grey[300], height: 1),
        _buildSummaryRow(
            'Sous-total TTC', "${_calculateSubTotal().toStringAsFixed(2)} €"),
        _buildSummaryRow(
            'Frais de Livraison',
            _cartData?.totalShippingPrice == null || _cartData!.totalShippingPrice == 0
                ? "Offerts"
                : "${_cartData!.totalShippingPrice!.toStringAsFixed(2)} €"),
        SizedBox(height: 8),
        Divider(color: Colors.grey[300], height: 1),
        SizedBox(height: 8),
        _buildSummaryRow('Total TTC', '${_cartData?.total?.toStringAsFixed(2) ?? '0.00'} €', isBold: true),
        
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'ENREGISTRER',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField(String label, TextEditingController controller) {
    String getHintText() {
      switch (label) {
        case 'Name':
          return 'Enter your last name';
        case 'Prénom':
          return 'Enter your first name';
        case 'Adresse':
          return 'Enter your street address';
        case 'Code postal':
          return 'Enter postal code';
        case 'Ville':
          return 'Enter city name';
        case 'E-mail':
          return 'Enter email address';
        case 'Phone':
          return 'Enter phone number';
        default:
          return '';
      }
    }

    String? validator(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Required';
      }
      if (label == 'Nom' || label == 'Prénom') {
        if (value.trim().length < 2) {
          return 'Minimum 2 characters';
        }
      }
      if (label == 'Adresse') {
        if (value.trim().length < 5) {
          return 'Enter a valid address';
        }
      }
      if (label == 'Code postal') {
        if (!RegExp(r'^\d{4,10}$').hasMatch(value.trim())) {
          return 'Enter a valid postal code';
        }
      }
      if (label == 'Ville') {
        if (value.trim().length < 2) {
          return 'Enter a valid city name';
        }
      }
      if (label == 'E-mail') {
        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Enter a valid email';
        }
      }
      if (label == 'Phone') {
        if (value.trim().length < 8) {
          return 'Enter a valid phone number';
        }
      }
      return null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Lato',
                color: Color(0xFF5C5C5C),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              cursorColor: Colors.black,
              keyboardType: label == 'Code postal'
                  ? TextInputType.number
                  : label == 'E-mail'
                      ? TextInputType.emailAddress
                      : label == 'Phone'
                          ? TextInputType.phone
                          : TextInputType.text,
              inputFormatters: (label == 'Code postal' || label == 'Phone')
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Lato',
                color: Colors.black,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
                hintText: getHintText(),
                hintStyle: const TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: 14,
                  fontFamily: 'Lato',
                ),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: isBold ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: isBold ? Colors.black : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
