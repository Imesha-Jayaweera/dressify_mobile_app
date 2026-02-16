class CustomOrder {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String tailorId;
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final String selectedColor;
  final String? additionalNotes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;


  CustomOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.tailorId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.selectedColor,
    this.additionalNotes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomOrder.fromJson(Map<String, dynamic> json) {
    return CustomOrder(
      id: json['_id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      tailorId: json['tailorId'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      quantity: json['quantity'] ?? 1,
      selectedColor: json['selectedColor'] ?? '',
      additionalNotes: json['additionalNotes'],
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}