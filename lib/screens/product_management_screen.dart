import 'package:flutter/material.dart';

class ProductManagementScreen extends StatelessWidget {
  static const routeName = '/product-management';

  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Management')),
      body: const Center(child: Text('Add, edit or remove products')),
    );
  }
}
