// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../model/user.dart';


class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  
  Future<void> fetchUserData(String token) async {
    if (token.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final userData = await ApiClient().getUserData(token);
      _user = User.fromJson(userData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  int get coins => _user?.credits ?? 0;
  
  bool get canUploadSelfie {
    // Logic to determine if user can upload a selfie today
    return true; // Simplified for this example
  }
}