class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double price;
  final int stock;
  final int minStock;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stock,
    required this.minStock,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock => stock <= minStock && stock > 0;
  bool get isOutOfStock => stock == 0;

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    double? price,
    int? stock,
    int? minStock,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'price': price,
      'stock': stock,
      'minStock': minStock,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      sku: map['sku'] ?? '',
      category: map['category'],
      price: map['price'].toDouble(),
      stock: map['stock'],
      minStock: map['minStock'],
      imageUrl: map['imageUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
