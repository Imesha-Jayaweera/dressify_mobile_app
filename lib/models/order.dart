class Order {
  final String id;
  final String customerName;
  final String productName;
  final String status;
  final double total;

  Order({
    required this.id,
    required this.customerName,
    required this.productName,
    required this.status,
    required this.total,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      customerName: json['customer']['name'],
      productName: json['product']['name'],
      status: json['status'],
      total: double.parse(json['total'].toString()),
    );
  }
}
