import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'add_product_screen.dart';
import 'inventory_screen.dart';
import 'manage_products_screen.dart';

class ProductManagementScreen extends StatelessWidget {
  static const routeName = '/product-management';

  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<AuthProvider>().currentSeller;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Management'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add), text: 'Add'),
              Tab(icon: Icon(Icons.inventory_2), text: 'Inventory'),
              Tab(icon: Icon(Icons.manage_search), text: 'Manage'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Add tab: simple CTA to open the full AddProductScreen (avoids nested Scaffold)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Create a new product'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: seller == null
                        ? null
                        : () => Navigator.of(context).pushNamed(AddProductScreen.routeName),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                  if (seller == null) ...[
                    const SizedBox(height: 8),
                    const Text('Sign in required', style: TextStyle(color: Colors.redAccent)),
                  ],
                ],
              ),
            ),
            const InventoryScreen(),
            const ManageProductsScreen(),
          ],
        ),
      ),
    );
  }
}
