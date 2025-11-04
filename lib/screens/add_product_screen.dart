import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../services/product_service.dart';
import '../constants/taxonomy.dart';

class _ComboEdit {
  final double? productionCost;
  final double? sellingPrice;
  final double? specialPrice;
  final List<File> images;
  _ComboEdit({
    this.productionCost,
    this.sellingPrice,
    this.specialPrice,
    this.images = const [],
  });
}

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
  String _unitMode = 'single';
  String _variantMode = 'single';
  final List<UnitOption> _units = [];
  final List<VariantOption> _variants = [];
  final Map<String, List<File>> _unitImageFiles = {};
  final Map<String, List<File>> _variantImageFiles = {};

  // combo key: unitId|variantId
  final Map<String, _ComboEdit> _comboEdits = {};

  String _comboKey(String u, String v) => '$u|$v';

  Future<void> _pickUnitImages(String unitId) async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _unitImageFiles[unitId] = [
          ...(_unitImageFiles[unitId] ?? const []),
          ...picked.map((x) => File(x.path)),
        ];
      });
    }
  }

  Future<void> _pickVariantImages(String variantId) async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _variantImageFiles[variantId] = [
          ...(_variantImageFiles[variantId] ?? const []),
          ...picked.map((x) => File(x.path)),
        ];
      });
    }
  }

  Future<void> _editComboDialog(String unitId, String variantId) async {
    final key = _comboKey(unitId, variantId);
    final existing = _comboEdits[key];
    final prodCtl = TextEditingController(
      text: existing?.productionCost?.toStringAsFixed(2) ?? '',
    );
    final sellCtl = TextEditingController(
      text: existing?.sellingPrice?.toStringAsFixed(2) ?? '',
    );
    final specialCtl = TextEditingController(
      text: existing?.specialPrice?.toStringAsFixed(2) ?? '',
    );
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Edit Combo: $unitId × $variantId'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: prodCtl,
                  decoration: const InputDecoration(
                    labelText: 'Production Cost',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: sellCtl,
                  decoration: const InputDecoration(labelText: 'Selling Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: specialCtl,
                  decoration: const InputDecoration(
                    labelText: 'Special Price (optional)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickMultiImage();
                      if (picked.isNotEmpty) {
                        setStateDialog(() {
                          final list = existing?.images ?? [];
                          _comboEdits[key] = _ComboEdit(
                            productionCost: double.tryParse(
                              prodCtl.text.trim(),
                            ),
                            sellingPrice: double.tryParse(sellCtl.text.trim()),
                            specialPrice: double.tryParse(
                              specialCtl.text.trim(),
                            ),
                            images: [
                              ...list,
                              ...picked.map((x) => File(x.path)),
                            ],
                          );
                        });
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Add Images for this Combo'),
                  ),
                ),
                if ((existing?.images ?? const []).isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: existing!.images.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Image.file(
                          existing.images[i],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _comboEdits[key] = _ComboEdit(
                  productionCost: double.tryParse(prodCtl.text.trim()),
                  sellingPrice: double.tryParse(sellCtl.text.trim()),
                  specialPrice: double.tryParse(specialCtl.text.trim()),
                  images: _comboEdits[key]?.images ?? existing?.images ?? [],
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

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
      _unitMode = widget.product!.unitMode;
      _variantMode = widget.product!.variantMode;
      _units.clear();
      _units.addAll(widget.product!.units);
      _variants.clear();
      _variants.addAll(widget.product!.variants);
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

  Future<void> _showAddUnitDialog() async {
    final idCtl = TextEditingController();
    final labelCtl = TextEditingController();
    final prodCtl = TextEditingController();
    final sellCtl = TextEditingController();
    final specialCtl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Unit Option'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idCtl,
                  decoration: const InputDecoration(
                    labelText: 'Unit ID (e.g., 500g, 1kg, 1L)',
                  ),
                ),
                TextField(
                  controller: labelCtl,
                  decoration: const InputDecoration(
                    labelText: 'Label (display name)',
                  ),
                ),
                TextField(
                  controller: prodCtl,
                  decoration: const InputDecoration(
                    labelText: 'Production Cost',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: sellCtl,
                  decoration: const InputDecoration(labelText: 'Selling Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: specialCtl,
                  decoration: const InputDecoration(
                    labelText: 'Special Price (optional)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final id = idCtl.text.trim();
                final label = labelCtl.text.trim();
                final prod = double.tryParse(prodCtl.text.trim());
                final sell = double.tryParse(sellCtl.text.trim());
                final special = specialCtl.text.trim().isEmpty
                    ? null
                    : double.tryParse(specialCtl.text.trim());
                if (id.isEmpty ||
                    label.isEmpty ||
                    prod == null ||
                    sell == null) {
                  return;
                }
                setState(() {
                  _units.add(
                    UnitOption(
                      id: id,
                      label: label,
                      productionCost: prod,
                      sellingPrice: sell,
                      specialPrice: special,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddVariantDialog() async {
    final idCtl = TextEditingController();
    final nameCtl = TextEditingController();
    final prodCtl = TextEditingController();
    final sellCtl = TextEditingController();
    final specialCtl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Variant Option'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idCtl,
                  decoration: const InputDecoration(
                    labelText: 'Variant ID (e.g., Red, 64GB)',
                  ),
                ),
                TextField(
                  controller: nameCtl,
                  decoration: const InputDecoration(
                    labelText: 'Name (display name)',
                  ),
                ),
                TextField(
                  controller: prodCtl,
                  decoration: const InputDecoration(
                    labelText: 'Production Cost (optional)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: sellCtl,
                  decoration: const InputDecoration(
                    labelText: 'Selling Price (optional)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: specialCtl,
                  decoration: const InputDecoration(
                    labelText: 'Special Price (optional)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final id = idCtl.text.trim();
                final name = nameCtl.text.trim();
                final prod = prodCtl.text.trim().isEmpty
                    ? null
                    : double.tryParse(prodCtl.text.trim());
                final sell = sellCtl.text.trim().isEmpty
                    ? null
                    : double.tryParse(sellCtl.text.trim());
                final special = specialCtl.text.trim().isEmpty
                    ? null
                    : double.tryParse(specialCtl.text.trim());
                if (id.isEmpty || name.isEmpty) {
                  return;
                }
                setState(() {
                  _variants.add(
                    VariantOption(
                      id: id,
                      name: name,
                      productionCost: prod,
                      sellingPrice: sell,
                      specialPrice: special,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
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
      final newId =
          widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      List<String> imageUrls = [];
      if (_imageFiles.isNotEmpty) {
        imageUrls = await _productService.uploadImages(
          _imageFiles,
          category,
          subCategory,
          newId,
        );
      }

      // Upload unit-specific images
      List<UnitOption> newUnits = _units;
      if (_unitMode == 'multi' && _units.isNotEmpty) {
        newUnits = [];
        for (final u in _units) {
          final files = _unitImageFiles[u.id] ?? const [];
          List<String> urls = [];
          if (files.isNotEmpty) {
            urls = await _productService.uploadImages(
              files,
              category,
              subCategory,
              newId,
              folder: 'units/${u.id}',
            );
          }
          newUnits.add(
            UnitOption(
              id: u.id,
              label: u.label,
              productionCost: u.productionCost,
              sellingPrice: u.sellingPrice,
              specialPrice: u.specialPrice,
              images: urls,
            ),
          );
        }
      }

      // Upload variant-specific images
      List<VariantOption> newVariants = _variants;
      if (_variantMode == 'multi' && _variants.isNotEmpty) {
        newVariants = [];
        for (final v in _variants) {
          final files = _variantImageFiles[v.id] ?? const [];
          List<String> urls = [];
          if (files.isNotEmpty) {
            urls = await _productService.uploadImages(
              files,
              category,
              subCategory,
              newId,
              folder: 'variants/${v.id}',
            );
          }
          newVariants.add(
            VariantOption(
              id: v.id,
              name: v.name,
              productionCost: v.productionCost,
              sellingPrice: v.sellingPrice,
              specialPrice: v.specialPrice,
              images: urls,
            ),
          );
        }
      }

      // Build combos and upload combo images
      List<ComboOption> combos = const [];
      if (_unitMode == 'multi' &&
          _variantMode == 'multi' &&
          _units.isNotEmpty &&
          _variants.isNotEmpty) {
        final List<ComboOption> list = [];
        for (final entry in _comboEdits.entries) {
          final parts = entry.key.split('|');
          if (parts.length != 2) continue;
          final unitId = parts[0];
          final variantId = parts[1];
          final ce = entry.value;
          List<String> urls = [];
          if (ce.images.isNotEmpty) {
            urls = await _productService.uploadImages(
              ce.images,
              category,
              subCategory,
              newId,
              folder: 'combos/${unitId}_$variantId',
            );
          }
          list.add(
            ComboOption(
              unitId: unitId,
              variantId: variantId,
              productionCost: ce.productionCost ?? 0,
              sellingPrice: ce.sellingPrice ?? 0,
              specialPrice: ce.specialPrice,
              images: urls,
            ),
          );
        }
        combos = list;
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
        unitMode: _unitMode,
        variantMode: _variantMode,
        units: _unitMode == 'multi'
            ? List<UnitOption>.from(newUnits)
            : const [],
        variants: _variantMode == 'multi'
            ? List<VariantOption>.from(newVariants)
            : const [],
        combos: combos,
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
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (route) => false);
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
                value: _categoryController.text.isEmpty
                    ? null
                    : _categoryController.text,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map(
                      (c) => DropdownMenuItem<String>(value: c, child: Text(c)),
                    )
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
                value: _subCategoryController.text.isEmpty
                    ? null
                    : _subCategoryController.text,
                decoration: const InputDecoration(
                  labelText: 'Sub Category',
                  border: OutlineInputBorder(),
                ),
                items: (_subCategories[_categoryController.text] ?? [])
                    .map(
                      (s) => DropdownMenuItem<String>(value: s, child: Text(s)),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _subCategoryController.text = val ?? '';
                  });
                },
                validator: (value) {
                  if ((_subCategories[_categoryController.text] ?? [])
                      .isNotEmpty) {
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
              const SizedBox(height: 24),
              Text('Unit Mode', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Single'),
                    selected: _unitMode == 'single',
                    onSelected: (v) => setState(() => _unitMode = 'single'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Multiple'),
                    selected: _unitMode == 'multi',
                    onSelected: (v) => setState(() => _unitMode = 'multi'),
                  ),
                ],
              ),
              if (_unitMode == 'multi') ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Units (per-unit pricing)'),
                    TextButton.icon(
                      onPressed: _showAddUnitDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Unit'),
                    ),
                  ],
                ),
                ..._units.map(
                  (u) => Card(
                    child: ListTile(
                      title: Text('${u.label} (${u.id})'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prod: ₹${u.productionCost.toStringAsFixed(2)}  Sell: ₹${u.sellingPrice.toStringAsFixed(2)}'
                            '${u.specialPrice != null ? '  Special: ₹${u.specialPrice!.toStringAsFixed(2)}' : ''}',
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              TextButton.icon(
                                onPressed: () => _pickUnitImages(u.id),
                                icon: const Icon(Icons.image),
                                label: const Text('Add Images'),
                              ),
                              if ((_unitImageFiles[u.id] ?? const [])
                                  .isNotEmpty)
                                SizedBox(
                                  height: 70,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _unitImageFiles[u.id]!.length,
                                    itemBuilder: (context, i) => Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Image.file(
                                        _unitImageFiles[u.id]![i],
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(() => _units.remove(u)),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Variant Mode',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Single'),
                    selected: _variantMode == 'single',
                    onSelected: (v) => setState(() => _variantMode = 'single'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Multiple'),
                    selected: _variantMode == 'multi',
                    onSelected: (v) => setState(() => _variantMode = 'multi'),
                  ),
                ],
              ),
              if (_variantMode == 'multi') ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Variants (optional per-variant pricing)'),
                    TextButton.icon(
                      onPressed: _showAddVariantDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Variant'),
                    ),
                  ],
                ),
                ..._variants.map(
                  (v) => Card(
                    child: ListTile(
                      title: Text('${v.name} (${v.id})'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${v.productionCost != null ? 'Prod: ₹${v.productionCost!.toStringAsFixed(2)}  ' : ''}'
                            '${v.sellingPrice != null ? 'Sell: ₹${v.sellingPrice!.toStringAsFixed(2)}  ' : ''}'
                            '${v.specialPrice != null ? 'Special: ₹${v.specialPrice!.toStringAsFixed(2)}' : ''}',
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              TextButton.icon(
                                onPressed: () => _pickVariantImages(v.id),
                                icon: const Icon(Icons.image),
                                label: const Text('Add Images'),
                              ),
                              if ((_variantImageFiles[v.id] ?? const [])
                                  .isNotEmpty)
                                SizedBox(
                                  height: 70,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _variantImageFiles[v.id]!.length,
                                    itemBuilder: (context, i) => Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Image.file(
                                        _variantImageFiles[v.id]![i],
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(() => _variants.remove(v)),
                      ),
                    ),
                  ),
                ),
              ],
              if (_unitMode == 'multi' &&
                  _variantMode == 'multi' &&
                  _units.isNotEmpty &&
                  _variants.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Combinations (Unit × Variant)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ..._units.map(
                  (u) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${u.label} (${u.id})',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _variants.map((v) {
                              final key = _comboKey(u.id, v.id);
                              final ce = _comboEdits[key];
                              final summary = ce == null
                                  ? 'Not set'
                                  : '₹${(ce.sellingPrice ?? 0).toStringAsFixed(0)}'
                                        '${ce.images.isNotEmpty ? ' • ${ce.images.length} img' : ''}';
                              return OutlinedButton(
                                onPressed: () => _editComboDialog(u.id, v.id),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(v.name),
                                    const SizedBox(width: 6),
                                    Text(
                                      '($summary)',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
