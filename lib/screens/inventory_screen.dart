import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../services/product_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _service = ProductService();

  Future<void> _updateStock(Product p, int newStock) async {
    try {
      if (newStock < 0) return;
      final updated = Product(
        id: p.id,
        sellerId: p.sellerId,
        sellerName: p.sellerName,
        businessName: p.businessName,
        phone: p.phone,
        name: p.name,
        brandName: p.brandName,
        description: p.description,
        price: p.price,
        stock: newStock,
        images: p.images,
        category: p.category,
        subCategory: p.subCategory,
        minStock: p.minStock,
        expiryDate: p.expiryDate,
        specialPrice: p.specialPrice,
        productionCost: p.productionCost,
        unitMode: p.unitMode,
        variantMode: p.variantMode,
        createdAt: p.createdAt,
      );
      await _service.updateProduct(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock update failed: $e')),
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
          return const Center(child: Text('No inventory yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final p = products[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    p.images.isNotEmpty
                        ? Image.network(
                            p.images.first,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text('Current stock: ${p.stock}')
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Decrease',
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _updateStock(p, p.stock - 1),
                    ),
                    SizedBox(
                      width: 64,
                      child: Text(
                        '${p.stock}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Increase',
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _updateStock(p, p.stock + 1),
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
