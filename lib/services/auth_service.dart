import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/seller.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Accept either a dart:io File (mobile/desktop) or an XFile/Uint8List for web.
  // Files will be stored under SellerDocuments/<userId>/<filename>
  Future<String> uploadImage(
    dynamic image,
    String userId,
    String type,
    String sellerName,
  ) async {
    String sanitize(String s) {
      return s
          .toLowerCase()
          .replaceAll(RegExp(r"[^a-z0-9_\- ]"), '')
          .replaceAll(' ', '_');
    }

    String getExtension(dynamic img) {
      try {
        if (img is File || (img is XFile && img.path.isNotEmpty)) {
          final path = img is File ? img.path : (img as XFile).path;
          final parts = path.split('.');
          if (parts.length > 1) return parts.last.toLowerCase();
        }
      } catch (_) {}
      return 'jpg';
    }

    final ext = getExtension(image);
    final fileName = '${sanitize(sellerName)}_$type.$ext';
    final path = 'SellerDocuments/$userId/$fileName';
    final ref = _storage.ref().child(path);
    try {
      debugPrint('uploadImage: starting upload for $path');
      if (kIsWeb) {
        // On web use putData with bytes read from XFile or provided Uint8List
        Uint8List bytes;
        if (image is Uint8List) {
          bytes = image;
        } else if (image is XFile) {
          bytes = await image.readAsBytes();
        } else {
          throw Exception(
            'UNSUPPORTED_IMAGE_TYPE_FOR_WEB: ${image.runtimeType}',
          );
        }

        final metadata = SettableMetadata(contentType: 'image/jpeg');
        final uploadTask = ref.putData(bytes, metadata);
        final snapshot = await uploadTask;
        debugPrint(
          'uploadImage: upload complete for $path; bytesTransferred=${snapshot.bytesTransferred}',
        );
        final url = await ref.getDownloadURL();
        debugPrint('uploadImage: downloadURL for $path -> $url');
        return url;
      } else {
        // non-web platforms: expect a dart:io File
        if (image is File) {
          final uploadTask = ref.putFile(image);
          final snapshot = await uploadTask;
          debugPrint(
            'uploadImage: upload complete for $path; bytesTransferred=${snapshot.bytesTransferred}',
          );
          final url = await ref.getDownloadURL();
          debugPrint('uploadImage: downloadURL for $path -> $url');
          return url;
        } else if (image is XFile) {
          // In some cases ImagePicker returns XFile on mobile; convert to File via path
          final file = File(image.path);
          final uploadTask = ref.putFile(file);
          final snapshot = await uploadTask;
          debugPrint(
            'uploadImage: upload complete for $path; bytesTransferred=${snapshot.bytesTransferred}',
          );
          final url = await ref.getDownloadURL();
          debugPrint('uploadImage: downloadURL for $path -> $url');
          return url;
        } else {
          throw Exception('UNSUPPORTED_IMAGE_TYPE: ${image.runtimeType}');
        }
      }
    } catch (e, st) {
      debugPrint('uploadImage ERROR for $path: $e\n$st');
      rethrow;
    }
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String sellerName,
    required String businessName,
    required String businessAddress,
    required String phone,
    required String gstNumber,
    required String aadharNumber,
    // image parameters can be File (mobile/desktop) or XFile/Uint8List (web)
    required dynamic selfieImage,
    required dynamic aadharFrontImage,
    required dynamic aadharBackImage,
    required dynamic gstCertificateImage,
  }) async {
    try {
      debugPrint('signUp: creating firebase auth user for $email');
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      debugPrint(
        'signUp: firebase auth created user: ${userCredential.user?.uid}',
      );

      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;

        // Upload all images
        debugPrint('signUp: uploading selfie image for userId=$userId');
        final selfieUrl = await uploadImage(
          selfieImage,
          userId,
          'selfie',
          sellerName,
        );
        debugPrint('signUp: selfie uploaded -> $selfieUrl');
        final aadharFrontUrl = await uploadImage(
          aadharFrontImage,
          userId,
          'aadhar_front',
          sellerName,
        );
        debugPrint('signUp: aadhar front uploaded -> $aadharFrontUrl');
        final aadharBackUrl = await uploadImage(
          aadharBackImage,
          userId,
          'aadhar_back',
          sellerName,
        );
        debugPrint('signUp: aadhar back uploaded -> $aadharBackUrl');
        final gstCertificateUrl = await uploadImage(
          gstCertificateImage,
          userId,
          'gst_certificate',
          sellerName,
        );
        debugPrint('signUp: gst certificate uploaded -> $gstCertificateUrl');

        // Create seller profile in Firestore
        Seller seller = Seller(
          id: userId,
          sellerName: sellerName,
          email: email,
          businessName: businessName,
          businessAddress: businessAddress,
          phone: phone,
          gstNumber: gstNumber,
          aadharNumber: aadharNumber,
          selfieImage: selfieUrl,
          aadharFrontImage: aadharFrontUrl,
          aadharBackImage: aadharBackUrl,
          gstCertificateImage: gstCertificateUrl,
          // explicitly mark new sellers as pending approval
          approvalStatus: 'Pending',
        );

        debugPrint('signUp: seller.toMap -> ${seller.toMap()}');
        // Store new seller profile under collection 'Seller' inside a 'Pending' folder
        // Structure: Seller (collection) -> Pending (document) -> Sellers (subcollection) -> {userId}
        debugPrint(
          'signUp: writing seller doc to Firestore Seller/Pending/Sellers/$userId',
        );
        await _firestore
            .collection('Sellers')
            .doc('Pending')
            .collection('Sellers')
            .doc(userId)
            .set(seller.toMap());
        debugPrint(
          'signUp: Firestore write complete for Seller/Pending/Sellers/$userId',
        );
      }

      return userCredential;
    } catch (e, st) {
      debugPrint('signUp ERROR for $email: $e\n$st');
      rethrow;
    }
  }

  Future<Seller> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('signIn: attempting sign in for $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Authentication failed');
      }

      final sellerDoc = await _firestore
          .collection('Sellers')
          .doc(userCredential.user!.uid)
          .get();

      if (!sellerDoc.exists) {
        throw Exception('Seller profile not found');
      }

      final seller = Seller.fromMap(sellerDoc.data() as Map<String, dynamic>);

      if (!seller.isApproved) {
        // sign out locally and throw a special token so UI can route to waiting screen
        debugPrint('signIn: seller ${seller.id} not approved yet');
        await _auth.signOut();
        throw Exception('PENDING_APPROVAL');
      }

      debugPrint('signIn: seller ${seller.id} approved, returning seller');
      return seller;
    } catch (e, st) {
      debugPrint('signIn ERROR for $email: $e\n$st');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<Seller?> getCurrentSeller() async {
    User? user = _auth.currentUser;
    if (user != null) {
      debugPrint('getCurrentSeller: loading seller doc for ${user.uid}');
      DocumentSnapshot doc = await _firestore
          .collection('Sellers')
          .doc(user.uid)
          .get();
      debugPrint('getCurrentSeller: doc.exists=${doc.exists} for ${user.uid}');
      if (doc.exists) {
        return Seller.fromMap(doc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }
}
