import 'package:flutter/material.dart';

class OrderManagementScreen extends StatelessWidget {
  static const routeName = '/order-management';

  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Management')),
      body: const Center(child: Text('View and process orders here')),
    );
  }
}
