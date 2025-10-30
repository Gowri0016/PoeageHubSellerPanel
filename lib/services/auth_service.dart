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

      final uid = userCredential.user!.uid;

      // First, check if seller exists in Approved path
      final approvedDoc = await _firestore
          .collection('Sellers')
          .doc('Approved')
          .collection('Sellers')
          .doc(uid)
          .get();

      if (approvedDoc.exists) {
        final seller = Seller.fromMap(approvedDoc.data() as Map<String, dynamic>);
        if (seller.isApproved) {
          debugPrint('signIn: seller $uid is approved and found in Approved path');
          return seller;
        } else {
          // Edge: present in Approved path but status not approved
          debugPrint('signIn: seller $uid in Approved path but status=${seller.approvalStatus}');
          await _auth.signOut();
          throw Exception('PENDING_APPROVAL');
        }
      }

      // Check Rejected path
      final rejectedDoc = await _firestore
          .collection('Sellers')
          .doc('Rejected')
          .collection('Sellers')
          .doc(uid)
          .get();

      if (rejectedDoc.exists) {
        final data = rejectedDoc.data() as Map<String, dynamic>;
        final reason = (data['rejectionReason'] ?? 'Your application was rejected.').toString();
        final rejectedAt = data['rejectedAt'];
        String rejectedAtIso = '';
        if (rejectedAt is Timestamp) {
          rejectedAtIso = rejectedAt.toDate().toIso8601String();
        } else if (rejectedAt is DateTime) {
          rejectedAtIso = rejectedAt.toIso8601String();
        } else if (rejectedAt != null) {
          rejectedAtIso = rejectedAt.toString();
        }
        debugPrint('signIn: seller $uid found in Rejected path; reason=$reason');
        await _auth.signOut();
        throw Exception('REJECTED|$reason|$rejectedAtIso');
      }

      // Not in Approved; check Pending path
      final pendingDoc = await _firestore
          .collection('Sellers')
          .doc('Pending')
          .collection('Sellers')
          .doc(uid)
          .get();

      if (pendingDoc.exists) {
        debugPrint('signIn: seller $uid found in Pending path; blocking login until approved');
        await _auth.signOut();
        throw Exception('PENDING_APPROVAL');
      }

      // Not found in either path
      // Fallback: search across all Sellers subcollections in Firestore
      debugPrint('signIn: direct lookups not found, running collectionGroup search for uid=$uid');
      final cgSnap = await _firestore
          .collectionGroup('Sellers')
          .where('id', isEqualTo: uid)
          .limit(1)
          .get();

      if (cgSnap.docs.isNotEmpty) {
        final doc = cgSnap.docs.first;
        // Determine parent status by checking parent document id (Approved/Pending/Rejected)
        final parentStatusDocId = doc.reference.parent.parent?.id ?? '';
        final data = doc.data();

        if (parentStatusDocId == 'Approved') {
          final seller = Seller.fromMap(data);
          if (seller.isApproved) {
            debugPrint('signIn: found via collectionGroup under Approved; proceeding');
            return seller;
          }
          await _auth.signOut();
          throw Exception('PENDING_APPROVAL');
        } else if (parentStatusDocId == 'Pending') {
          debugPrint('signIn: found via collectionGroup under Pending; blocking');
          await _auth.signOut();
          throw Exception('PENDING_APPROVAL');
        } else if (parentStatusDocId == 'Rejected') {
          final reason = (data['rejectionReason'] ?? 'Your application was rejected.').toString();
          final rejectedAt = data['rejectedAt'];
          String rejectedAtIso = '';
          if (rejectedAt is Timestamp) {
            rejectedAtIso = rejectedAt.toDate().toIso8601String();
          } else if (rejectedAt is DateTime) {
            rejectedAtIso = rejectedAt.toIso8601String();
          } else if (rejectedAt != null) {
            rejectedAtIso = rejectedAt.toString();
          }
          debugPrint('signIn: found via collectionGroup under Rejected; reason=$reason');
          await _auth.signOut();
          throw Exception('REJECTED|$reason|$rejectedAtIso');
        }
      }

      throw Exception('Seller profile not found');
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
      debugPrint('getCurrentSeller: loading seller doc for ${user.uid} from Approved path');
      final approvedDoc = await _firestore
          .collection('Sellers')
          .doc('Approved')
          .collection('Sellers')
          .doc(user.uid)
          .get();
      debugPrint('getCurrentSeller: approvedDoc.exists=${approvedDoc.exists} for ${user.uid}');
      if (approvedDoc.exists) {
        return Seller.fromMap(approvedDoc.data() as Map<String, dynamic>);
      }

      // Fallback: find via collectionGroup under Approved
      debugPrint('getCurrentSeller: approved direct doc not found, trying collectionGroup');
      final cgSnap = await _firestore
          .collectionGroup('Sellers')
          .where('id', isEqualTo: user.uid)
          .limit(3)
          .get();
      for (final d in cgSnap.docs) {
        final parentStatusDocId = d.reference.parent.parent?.id ?? '';
        if (parentStatusDocId == 'Approved') {
          final seller = Seller.fromMap(d.data());
          if (seller.isApproved) {
            debugPrint('getCurrentSeller: found Approved via collectionGroup');
            return seller;
          }
        }
      }
    }
    return null;
  }
}
