import 'package:flutter/material.dart';
import 'package:happer_app/profile/api/profile_api.dart';

class MyAddressScreen extends StatefulWidget {
  const MyAddressScreen({Key? key}) : super(key: key);

  @override
  _MyAddressScreenState createState() => _MyAddressScreenState();
}

class _MyAddressScreenState extends State<MyAddressScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _addressData;
  String? _errorMessage;
  String? _userId;
  
  // Text controllers for all editable fields
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _hasInitializedControllers = false;

  @override
  void initState() {
    super.initState();
    _loadAddressData();
  }
  
  @override
  void dispose() {
    // Dispose of all controllers when the widget is removed
    _lastNameController.dispose();
    _firstNameController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadAddressData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load user profile which should contain address data
      final profileApiService = ProfileApiService();
      final userData = await profileApiService.fetchCurrentUserProfile();
      
      setState(() {
        _addressData = userData;
        _userId = userData['_id']; // Store the user ID
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load address: $e';
        _isLoading = false;
      });
    }
  }

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            // Save changes before popping the screen
            await _saveAddressData();
            if (mounted) Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'MON ADDRESSE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.0,
            letterSpacing: 0.0,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
        ),
      ),
      body: Stack(
        children: [
          // Main content
          _isLoading && !_isSaving
              ? Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_errorMessage!),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadAddressData,
                            child: Text('Try Again'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: _buildAddressFields(),
                    ),
          
          // Overlay saving indicator
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Saving changes...',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressFields() {
    // Placeholder data in case real data is not available
    final Map<String, dynamic> addressData = _addressData ?? {};
    // Initialize controllers with current data if not done already
    if (!_hasInitializedControllers) {
      _userNameController.text = addressData['username'] ?? '' ;
      _lastNameController.text = addressData['last_name'] ?? '';
      _firstNameController.text = addressData['first_name'] ?? '';
      _addressController.text = addressData['address'] ?? '';
      _postalCodeController.text = addressData['postal_code'] ?? '';
      _cityController.text = addressData['city'] ?? '';
      _emailController.text = addressData['email'] ?? '';
      _phoneController.text = addressData['phone'] ?? '';
      _bioController.text = addressData['bio'] ?? '';
      _hasInitializedControllers = true;
    }
    
    return Column(
      children: [
        
      if (_userNameController.text.isNotEmpty)
        _buildReadOnlyFieldItem('User Name', _userNameController),
        _buildEditableFieldItem('Name', _firstNameController),
        _buildEditableFieldItem('Prénom', _lastNameController),
        _buildEditableFieldItem('Adresse', _addressController),
        _buildEditableFieldItem('Code postal', _postalCodeController),
        _buildEditableFieldItem('Ville', _cityController),
        _buildEditableFieldItem('E-mail', _emailController),
        _buildEditableFieldItem('Télephone', _phoneController),
        // _buildEditableFieldItem('Bio', _bioController),
      if (addressData['users_type'] == 1)
        _buildEditableFieldItem('Bio', _bioController),
        
      ],
    );
  }

  Future<bool> _saveAddressData() async {
    // Don't try to save if we're already in the process of saving
    if (_isSaving) return false;
    
    // Show loading indicator
    setState(() {
      _isSaving = true;
    });

    try {
      // Create updated data map
      final updatedData = {
        'last_name': _lastNameController.text,
        'first_name': _firstNameController.text,
        'address': _addressController.text,
        'postal_code': _postalCodeController.text,
        'city': _cityController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'bio': _bioController.text,
      };

      if (_userId == null) {
        throw Exception('User ID not found');
      }

      // Update user profile with new address data
      final profileApiService = ProfileApiService();
      await profileApiService.updateUserProfile(updatedData, _userId!);
      
      // Don't need to fetch updated data since we already have it in the controllers
      
      setState(() {
        _isSaving = false;
      });
      
      // Show success message (subtle, not as intrusive)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Votre adresse a été mis à jour',
              style: TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true;
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update address',
              style: TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return false;
    }
  }

  Widget _buildReadOnlyFieldItem(String label, TextEditingController controller) {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF5C5C5C),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: false, // 👈 read-only field
                readOnly: true,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF5C5C5C),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
    ],
  );
}


  Widget _buildEditableFieldItem(String label, TextEditingController controller) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF5C5C5C),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF5C5C5C),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onEditingComplete: () async {
                    await _saveAddressData();
                  },
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
      ],
    );
  }
}
