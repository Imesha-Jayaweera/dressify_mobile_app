class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final String genderType;
  final List<SizeStock> sizes;
  final List<String> images;
  final double price;
  final List<String> colors;
  final List<String> suitableBodyTypes;
  final String shoppingCenterId;
  final int totalStock;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.genderType,
    required this.sizes,
    required this.images,
    required this.price,
    required this.colors,
    required this.suitableBodyTypes,
    required this.shoppingCenterId,
    required this.totalStock,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      genderType: json['genderType'] ?? '',
      sizes: (json['sizes'] as List?)
          ?.map((s) => SizeStock.fromJson(s))
          .toList() ??
          [],
      images: List<String>.from(json['images'] ?? []),
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      colors: List<String>.from(json['colors'] ?? []),
      suitableBodyTypes: List<String>.from(json['suitableBodyTypes'] ?? []),
      shoppingCenterId: json['shoppingCenterId'] ?? '',
      totalStock: json['totalStock'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'genderType': genderType,
      'sizes': sizes.map((s) => s.toJson()).toList(),
      'images': images,
      'price': price,
      'colors': colors,
      'suitableBodyTypes': suitableBodyTypes,
    };
  }
}

class SizeStock {
  final String size;
  final int stock;

  SizeStock({
    required this.size,
    required this.stock,
  });

  factory SizeStock.fromJson(Map<String, dynamic> json) {
    return SizeStock(
      size: json['size'] ?? '',
      stock: json['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'stock': stock,
    };
  }
}