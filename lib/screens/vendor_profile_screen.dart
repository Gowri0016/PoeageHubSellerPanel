import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/seller.dart';
import '../providers/auth_provider.dart';

class VendorProfileScreen extends StatefulWidget {
  static const routeName = '/vendor-profile';

  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _businessNameCtl = TextEditingController();
  final TextEditingController _businessAddressCtl = TextEditingController();
  final TextEditingController _phoneCtl = TextEditingController();
  // Note: GST and Aadhar are sensitive credentials and must not be editable here.

  @override
  void dispose() {
    _businessNameCtl.dispose();
    _businessAddressCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(Seller seller) async {
    if (!_formKey.currentState!.validate()) return;

    final id = seller.id;
    final docRef = FirebaseFirestore.instance
        .collection('Sellers')
        .doc('Approved')
        .collection('Sellers')
        .doc(id);

    final updateData = {
      'businessName': _businessNameCtl.text.trim(),
      'businessAddress': _businessAddressCtl.text.trim(),
      'phone': _phoneCtl.text.trim(),
      // Do not update gstNumber or aadharNumber here — they are immutable from seller side
    };

    try {
      await docRef.update(updateData);
    } catch (e) {
      // If update failed (for example doc not found at Approved path), try to locate the seller document
      try {
        final cg = await FirebaseFirestore.instance
            .collectionGroup('Sellers')
            .where('id', isEqualTo: id)
            .limit(1)
            .get();
        if (cg.docs.isNotEmpty) {
          await cg.docs.first.reference.update(updateData);
        } else {
          rethrow;
        }
      } catch (e2) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Update failed: $e2')));
        }
        return;
      }
    }

    // reload provider seller
    await context.read<AuthProvider>().loadCurrentSeller();
    if (!mounted) return;
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<AuthProvider>().currentSeller;

    if (seller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vendor Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isEditing) {
      // populate controllers for when editing begins
      _businessNameCtl.text = seller.businessName;
      _businessAddressCtl.text = seller.businessAddress;
      _phoneCtl.text = seller.phone;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // reset form fields to provider values
                  _businessNameCtl.text = seller.businessName;
                  _businessAddressCtl.text = seller.businessAddress;
                  _phoneCtl.text = seller.phone;
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: seller.selfieImage.isNotEmpty
                      ? NetworkImage(seller.selfieImage)
                      : null,
                  child: seller.selfieImage.isEmpty
                      ? const Icon(Icons.person, size: 48)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                seller.sellerName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(seller.email, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _isEditing
                      ? _buildEditForm(seller)
                      : _buildReadOnly(seller),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton.extended(
              onPressed: () => _saveChanges(seller),
              label: const Text('Save'),
              icon: const Icon(Icons.save),
            )
          : null,
    );
  }

  Widget _buildReadOnly(Seller seller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row('Business Name', seller.businessName),
        const SizedBox(height: 8),
        _row('Business Address', seller.businessAddress),
        const SizedBox(height: 8),
        _row('Phone', seller.phone),
        const SizedBox(height: 8),
        _row('GST Number', seller.gstNumber),
        const SizedBox(height: 8),
        _row('Aadhar Number', seller.aadharNumber),
        const SizedBox(height: 8),
        _row('Approval Status', seller.approvalStatus),
        const SizedBox(height: 12),
        const Text('Documents', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _docThumb('Aadhar Front', seller.aadharFrontImage),
            _docThumb('Aadhar Back', seller.aadharBackImage),
            _docThumb('GST Certificate', seller.gstCertificateImage),
          ],
        ),
      ],
    );
  }

  Widget _buildEditForm(Seller seller) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _businessNameCtl,
            decoration: const InputDecoration(labelText: 'Business name'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _businessAddressCtl,
            decoration: const InputDecoration(labelText: 'Business address'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneCtl,
            decoration: const InputDecoration(labelText: 'Phone'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          // GST is a sensitive field and cannot be edited here. Show as read-only.
          TextFormField(
            initialValue: seller.gstNumber,
            decoration: const InputDecoration(labelText: 'GST number'),
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(flex: 3, child: Text(value)),
      ],
    );
  }

  Widget _docThumb(String label, String url) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          height: 70,
          child: url.isNotEmpty
              ? Image.network(url, fit: BoxFit.cover)
              : Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 40),
                ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 100,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
