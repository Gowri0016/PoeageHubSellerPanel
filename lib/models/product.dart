class Product {
  final String id;
  final String sellerId;
  final String sellerName;
  final String businessName;
  final String phone;
  final String name;
  final String brandName;
  final String description;
  final double price;
  final int stock;
  final List<String> images;
  final String category;
  final String subCategory;
  final int minStock;
  final DateTime? expiryDate;
  final double? specialPrice;
  final double? productionCost;
  final String unitMode; // 'single' | 'multi'
  final String variantMode; // 'single' | 'multi'
  final List<UnitOption> units; // when unitMode == 'multi'
  final List<VariantOption> variants; // when variantMode == 'multi'
  final List<ComboOption> combos; // when both unitMode & variantMode == 'multi'
  final DateTime createdAt;

  Product({
    required this.id,
    required this.sellerId,
    this.sellerName = '',
    this.businessName = '',
    this.phone = '',
    required this.name,
    this.brandName = '',
    required this.description,
    required this.price,
    required this.stock,
    required this.images,
    required this.category,
    this.subCategory = '',
    this.minStock = 0,
    this.expiryDate,
    this.specialPrice,
    this.productionCost,
    this.unitMode = 'single',
    this.variantMode = 'single',
    this.units = const [],
    this.variants = const [],
    this.combos = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'businessName': businessName,
      'phone': phone,
      'name': name,
      'brandName': brandName,
      'description': description,
      'price': price,
      'stock': stock,
      'images': images,
      'category': category,
      'subCategory': subCategory,
      'minStock': minStock,
      'expiryDate': expiryDate?.toIso8601String(),
      'specialPrice': specialPrice,
      'productionCost': productionCost,
      'unitMode': unitMode,
      'variantMode': variantMode,
      'units': units.map((u) => u.toMap()).toList(),
      'variants': variants.map((v) => v.toMap()).toList(),
      'combos': combos.map((c) => c.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      businessName: map['businessName'] ?? '',
      phone: map['phone'] ?? '',
      name: map['name'] ?? '',
      brandName: map['brandName'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      stock: map['stock']?.toInt() ?? 0,
      images: List<String>.from(map['images'] ?? []),
      category: map['category'] ?? '',
      subCategory: map['subCategory'] ?? '',
      minStock: map['minStock']?.toInt() ?? 0,
      expiryDate: map['expiryDate'] != null && (map['expiryDate'] as String).isNotEmpty
          ? DateTime.tryParse(map['expiryDate'])
          : null,
      specialPrice: map['specialPrice'] != null
          ? (map['specialPrice'] as num).toDouble()
          : null,
      productionCost: map['productionCost'] != null
          ? (map['productionCost'] as num).toDouble()
          : null,
      unitMode: map['unitMode'] ?? 'single',
      variantMode: map['variantMode'] ?? 'single',
      units: (map['units'] as List<dynamic>? ?? [])
          .map((e) => UnitOption.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      variants: (map['variants'] as List<dynamic>? ?? [])
          .map((e) => VariantOption.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      combos: (map['combos'] as List<dynamic>? ?? [])
          .map((e) => ComboOption.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class UnitOption {
  final String id; // e.g., "500g", "1kg", "1L"
  final String label; // display label
  final double productionCost;
  final double sellingPrice;
  final double? specialPrice;
  final List<String> images;

  UnitOption({
    required this.id,
    required this.label,
    required this.productionCost,
    required this.sellingPrice,
    this.specialPrice,
    this.images = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'productionCost': productionCost,
        'sellingPrice': sellingPrice,
        'specialPrice': specialPrice,
        'images': images,
      };

  factory UnitOption.fromMap(Map<String, dynamic> map) => UnitOption(
        id: map['id'] ?? '',
        label: map['label'] ?? '',
        productionCost: (map['productionCost'] ?? 0).toDouble(),
        sellingPrice: (map['sellingPrice'] ?? 0).toDouble(),
        specialPrice:
            map['specialPrice'] != null ? (map['specialPrice'] as num).toDouble() : null,
        images: List<String>.from(map['images'] ?? []),
      );
}

class VariantOption {
  final String id; // e.g., "Red", "64GB"
  final String name; // display name
  final double? productionCost;
  final double? sellingPrice;
  final double? specialPrice;
  final List<String> images;

  VariantOption({
    required this.id,
    required this.name,
    this.productionCost,
    this.sellingPrice,
    this.specialPrice,
    this.images = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'productionCost': productionCost,
        'sellingPrice': sellingPrice,
        'specialPrice': specialPrice,
        'images': images,
      };

  factory VariantOption.fromMap(Map<String, dynamic> map) => VariantOption(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        productionCost:
            map['productionCost'] != null ? (map['productionCost'] as num).toDouble() : null,
        sellingPrice:
            map['sellingPrice'] != null ? (map['sellingPrice'] as num).toDouble() : null,
        specialPrice:
            map['specialPrice'] != null ? (map['specialPrice'] as num).toDouble() : null,
        images: List<String>.from(map['images'] ?? []),
      );
}

class ComboOption {
  final String unitId;
  final String variantId;
  final double productionCost;
  final double sellingPrice;
  final double? specialPrice;
  final List<String> images;

  ComboOption({
    required this.unitId,
    required this.variantId,
    required this.productionCost,
    required this.sellingPrice,
    this.specialPrice,
    this.images = const [],
  });

  Map<String, dynamic> toMap() => {
        'unitId': unitId,
        'variantId': variantId,
        'productionCost': productionCost,
        'sellingPrice': sellingPrice,
        'specialPrice': specialPrice,
        'images': images,
      };

  factory ComboOption.fromMap(Map<String, dynamic> map) => ComboOption(
        unitId: map['unitId'] ?? '',
        variantId: map['variantId'] ?? '',
        productionCost: (map['productionCost'] ?? 0).toDouble(),
        sellingPrice: (map['sellingPrice'] ?? 0).toDouble(),
        specialPrice:
            map['specialPrice'] != null ? (map['specialPrice'] as num).toDouble() : null,
        images: List<String>.from(map['images'] ?? []),
      );
}
