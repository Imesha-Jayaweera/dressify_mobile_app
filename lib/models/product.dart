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

  // NEW: Seller info (populated from backend)
  final SellerInfo? sellerInfo;

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
    this.sellerInfo,
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
          .toList() ?? [],
      images: List<String>.from(json['images'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      colors: List<String>.from(json['colors'] ?? []),
      suitableBodyTypes: List<String>.from(json['suitableBodyTypes'] ?? []),
      shoppingCenterId: json['shoppingCenterId'] is String
          ? json['shoppingCenterId']
          : json['shoppingCenterId']?['_id'] ?? '',
      totalStock: json['totalStock'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      sellerInfo: json['shoppingCenterId'] is Map
          ? SellerInfo.fromJson(json['shoppingCenterId'])
          : null,
    );
  }

  // Helper to check if this is a tailor product
  bool get isTailorProduct => sellerInfo?.userType == 'TAILOR';
}

class SizeStock {
  final String size;
  final int stock;

  SizeStock({required this.size, required this.stock});

  factory SizeStock.fromJson(Map<String, dynamic> json) {
    return SizeStock(
      size: json['size'] ?? '',
      stock: json['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'size': size, 'stock': stock};
}

// NEW: Seller information
class SellerInfo {
  final String userType;
  final String businessName;
  final String contactNumber;

  SellerInfo({
    required this.userType,
    required this.businessName,
    required this.contactNumber,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      userType: json['userType'] ?? '',
      businessName: json['businessName'] ?? json['name'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
    );
  }
}