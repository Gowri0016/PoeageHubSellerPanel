import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class OfferBannerScreen extends StatefulWidget {
  static const routeName = '/offer-banners';
  const OfferBannerScreen({super.key});

  @override
  State<OfferBannerScreen> createState() => _OfferBannerScreenState();
}

class _OfferBannerScreenState extends State<OfferBannerScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  List<String> bannerUrls = [];

  @override
  void initState() {
    super.initState();
    loadBanners();
  }

  Future<void> loadBanners() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('offer_banners')
          .get();
      setState(() {
        bannerUrls = snapshot.docs
            .map((doc) => doc['imageUrl'] as String)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading banners: $e')));
      }
    }
  }

  Future<void> uploadBanner() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final File imageFile = File(image.path);
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference ref = _storage.ref().child('offer_banners/$fileName.jpg');

      await ref.putFile(imageFile);
      final String downloadUrl = await ref.getDownloadURL();

      await _firestore.collection('offer_banners').add({
        'imageUrl': downloadUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await loadBanners();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner uploaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading banner: $e')));
      }
    }
  }

  Future<void> deleteBanner(String imageUrl) async {
    try {
      // Delete from Firestore
      final QuerySnapshot snapshot = await _firestore
          .collection('offer_banners')
          .where('imageUrl', isEqualTo: imageUrl)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Delete from Storage
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();

      await loadBanners();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner deleted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting banner: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Offer Banners')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: uploadBanner,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Upload New Banner'),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: bannerUrls.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          bannerUrls[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteBanner(bannerUrls[index]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
