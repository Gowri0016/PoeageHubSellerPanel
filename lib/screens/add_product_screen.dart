import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../services/product_service.dart';
import '../constants/taxonomy.dart';

class AddProductScreen extends StatefulWidget {
  static const routeName = '/add-product';
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _minStockController = TextEditingController();
  DateTime? _expiryDate;
  final List<File> _imageFiles = [];
  final ProductService _productService = ProductService();
  bool _isLoading = false;

  List<String> get _categories => Taxonomy.categories;
  Map<String, List<String>> get _subCategories => Taxonomy.subcategories;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _brandController.text = widget.product!.brandName;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _categoryController.text = widget.product!.category;
      _subCategoryController.text = widget.product!.subCategory;
      _minStockController.text = widget.product!.minStock.toString();
      _expiryDate = widget.product!.expiryDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _subCategoryController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles.addAll(pickedFiles.map((xFile) => File(xFile.path)));
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFiles.isEmpty && widget.product?.images.isEmpty != false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final seller = context.read<AuthProvider>().currentSeller;
      if (seller == null) throw Exception('No seller found');

      final category = _categoryController.text.trim();
      final subCategory = _subCategoryController.text.trim();
      final newId = widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      List<String> imageUrls = [];
      if (_imageFiles.isNotEmpty) {
        imageUrls = await _productService.uploadImages(
          _imageFiles,
          category,
          subCategory,
          newId,
        );
      }

      final product = Product(
        id: newId,
        sellerId: seller.id,
        sellerName: seller.sellerName,
        businessName: seller.businessName,
        phone: seller.phone,
        name: _nameController.text,
        brandName: _brandController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        images: widget.product == null
            ? imageUrls
            : [...widget.product!.images, ...imageUrls],
        category: category,
        subCategory: subCategory,
        minStock: int.tryParse(_minStockController.text) ?? 0,
        expiryDate: _expiryDate,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
      );

      if (widget.product == null) {
        await _productService.addProduct(product);
      } else {
        await _productService.updateProduct(product);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (route) => false);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoryController.text.isEmpty ? null : _categoryController.text,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _categoryController.text = val ?? '';
                    // reset subcategory when category changes
                    _subCategoryController.text = '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _subCategoryController.text.isEmpty ? null : _subCategoryController.text,
                decoration: const InputDecoration(
                  labelText: 'Sub Category',
                  border: OutlineInputBorder(),
                ),
                items: (_subCategories[_categoryController.text] ?? [])
                    .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _subCategoryController.text = val ?? '';
                  });
                },
                validator: (value) {
                  if ((_subCategories[_categoryController.text] ?? []).isNotEmpty) {
                    if (value == null || value.isEmpty) {
                      return 'Please select sub category';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minStockController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Stock',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.event),
                      label: Text(
                        _expiryDate == null
                            ? 'Pick Expiry Date (optional)'
                            : 'Expiry: ${_expiryDate!.toLocal().toString().split(' ').first}',
                      ),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _expiryDate ?? now,
                          firstDate: now,
                          lastDate: DateTime(now.year + 10),
                        );
                        if (picked != null) {
                          setState(() {
                            _expiryDate = picked;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image),
                label: const Text('Add Images'),
              ),
              if (_imageFiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageFiles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            Image.file(
                              _imageFiles[index],
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _imageFiles.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (widget.product?.images.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                const Text(
                  'Existing Images:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.product!.images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.network(
                          widget.product!.images[index],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        widget.product == null
                            ? 'Add Product'
                            : 'Update Product',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
