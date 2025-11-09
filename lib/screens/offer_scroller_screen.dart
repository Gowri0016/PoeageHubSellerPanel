import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OfferScrollerScreen extends StatefulWidget {
  static const routeName = '/offer-scroller';
  const OfferScrollerScreen({super.key});

  @override
  _OfferScrollerScreenState createState() => _OfferScrollerScreenState();
}

class _OfferScrollerScreenState extends State<OfferScrollerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _offerController = TextEditingController();
  List<DocumentSnapshot> offers = [];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  @override
  void dispose() {
    _offerController.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('offer_scrollers')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        offers = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading offers: $e')));
    }
  }

  Future<void> _addOffer() async {
    if (_offerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an offer text')),
      );
      return;
    }

    try {
      await _firestore.collection('offer_scrollers').add({
        'text': _offerController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      _offerController.clear();
      await _loadOffers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding offer: $e')));
    }
  }

  Future<void> _deleteOffer(String docId) async {
    try {
      await _firestore.collection('offer_scrollers').doc(docId).delete();
      await _loadOffers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting offer: $e')));
    }
  }

  Future<void> _toggleOfferStatus(String docId, bool currentStatus) async {
    try {
      await _firestore.collection('offer_scrollers').doc(docId).update({
        'isActive': !currentStatus,
      });
      await _loadOffers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating offer status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Offer Scroller')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _offerController,
                    decoration: const InputDecoration(
                      hintText: 'Enter offer text',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _addOffer,
                  child: const Text('Add Offer'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                final isActive = offer['isActive'] as bool;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    title: Text(
                      offer['text'] as String,
                      style: TextStyle(
                        color: isActive ? Colors.black : Colors.grey,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: isActive,
                          onChanged: (value) =>
                              _toggleOfferStatus(offer.id, isActive),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteOffer(offer.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
