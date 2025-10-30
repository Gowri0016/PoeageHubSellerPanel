import 'package:flutter/material.dart';
import '../models/seller.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Seller? _currentSeller;
  bool _isLoading = false;

  Seller? get currentSeller => _currentSeller;
  bool get isLoading => _isLoading;

  Future<void> signUp({
    required String email,
    required String password,
    required String sellerName,
    required String businessName,
    required String businessAddress,
    required String phone,
    required String gstNumber,
    required String aadharNumber,
    // images can be dart:io File (mobile/desktop) or XFile/Uint8List (web)
    required dynamic selfieImage,
    required dynamic aadharFrontImage,
    required dynamic aadharBackImage,
    required dynamic gstCertificateImage,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      debugPrint('AuthProvider.signUp: starting for $email');

      await _authService.signUp(
        email: email,
        password: password,
        sellerName: sellerName,
        businessName: businessName,
        businessAddress: businessAddress,
        phone: phone,
        gstNumber: gstNumber,
        aadharNumber: aadharNumber,
        selfieImage: selfieImage,
        aadharFrontImage: aadharFrontImage,
        aadharBackImage: aadharBackImage,
        gstCertificateImage: gstCertificateImage,
      );

      _isLoading = false;
      notifyListeners();
      debugPrint('AuthProvider.signUp: completed for $email');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('AuthProvider.signUp ERROR for $email: $e');
      rethrow;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      _isLoading = true;
      notifyListeners();
      debugPrint('AuthProvider.signIn: starting for $email');

      final seller = await _authService.signIn(
        email: email,
        password: password,
      );

      if (!seller.isApproved) {
        _isLoading = false;
        notifyListeners();
        // use a standardized token so UI can detect and route to waiting page
        throw Exception('PENDING_APPROVAL');
      }

      _currentSeller = seller;
      _isLoading = false;
      notifyListeners();
      debugPrint('AuthProvider.signIn: success for ${seller.id}');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('AuthProvider.signIn ERROR for $email: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentSeller = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadCurrentSeller() async {
    _currentSeller = await _authService.getCurrentSeller();
    notifyListeners();
  }
}
