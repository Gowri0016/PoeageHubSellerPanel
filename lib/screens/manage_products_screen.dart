import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../services/product_service.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final _service = ProductService();

  Future<void> _deleteProduct(String productId) async {
    try {
      await _service.deleteProduct(productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<AuthProvider>().currentSeller;
    if (seller == null) {
      return const Center(child: Text('Sign in required'));
    }

    return StreamBuilder<List<Product>>(
      stream: _service.getSellerProducts(seller.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Center(child: Text('No products yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final p = products[index];
            return Card(
              child: ListTile(
                leading: p.images.isNotEmpty
                    ? Image.network(
                        p.images.first,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image_not_supported),
                title: Text(p.name),
                subtitle: Text('₹${p.price.toStringAsFixed(2)} • Stock: ${p.stock}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/edit-product',
                          arguments: p,
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete product?'),
                            content: Text('Are you sure you want to delete "${p.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _deleteProduct(p.id);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
