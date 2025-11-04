import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _itemsRef(
    String category,
    String subCategory,
  ) {
    return _firestore
        .collection('products')
        .doc(category)
        .collection('subcategories')
        .doc(subCategory)
        .collection('items');
  }

  Future<String> uploadImage(
    File image,
    String category,
    String subCategory,
    String productId,
    String folder,
    String filename,
  ) async {
    final path =
        'products/$category/$subCategory/$productId/$folder/$filename';
    final ref = _storage.ref().child(path);
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<List<String>> uploadImages(
    List<File> images,
    String category,
    String subCategory,
    String productId, {
    String folder = 'default',
  }) async {
    final List<String> imageUrls = [];
    for (int i = 0; i < images.length; i++) {
      final url = await uploadImage(
        images[i],
        category,
        subCategory,
        productId,
        folder,
        '$i.jpg',
      );
      imageUrls.add(url);
    }
    return imageUrls;
  }

  Future<void> addProduct(Product product) async {
    await _itemsRef(product.category, product.subCategory)
        .doc(product.id)
        .set(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _itemsRef(product.category, product.subCategory)
        .doc(product.id)
        .update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    // Caller should provide category & subCategory to fully resolve path if needed.
    // For safety, delete via collectionGroup lookup.
    final snap = await _firestore
        .collectionGroup('items')
        .where('id', isEqualTo: productId)
        .limit(1)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  Stream<List<Product>> getSellerProducts(String sellerId) {
    return _firestore
        .collectionGroup('items')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
    });
  }
}
