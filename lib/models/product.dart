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
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
