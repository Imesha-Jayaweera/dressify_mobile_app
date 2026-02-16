import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import 'product_page.dart';
import 'edit_product_page.dart';
import 'package:intl/intl.dart';

class ShoppingCenterDashboard extends StatefulWidget {
  const ShoppingCenterDashboard({super.key});

  @override
  State<ShoppingCenterDashboard> createState() =>
      _ShoppingCenterDashboardState();
}

class _ShoppingCenterDashboardState extends State<ShoppingCenterDashboard> {
  // Track current image index for each product
  Map<String, int> _currentImageIndexes = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?['userId'];

      if (userId != null) {
        try {
          await Provider.of<ProductProvider>(context, listen: false)
              .fetchMyProducts(userId);
        } catch (e) {
          print('Error fetching products: $e');
        }

        try {
          // ✅ FIXED: Changed from fetchOrders() to fetchShoppingCenterOrders()
          await Provider.of<OrderProvider>(context, listen: false)
              .fetchShoppingCenterOrders(userId);
        } catch (e) {
          print('Error fetching orders: $e');
        }
      }
    });
  }

  void _showDeleteConfirmation(
      BuildContext context,
      String productId,
      String productName,
      ProductProvider productProvider,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Delete Product",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Are you sure you want to delete this product?",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "This action cannot be undone.",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();

                  try {
                    await productProvider.deleteProduct(productId);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child:
                                Text('$productName deleted successfully'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.white),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text('Failed to delete product'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_forever, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Yes, Delete",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF1E88E5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E88E5),
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dressify Store",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                authProvider.user?['email'] ?? '',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await authProvider.logout();
                Navigator.pushReplacementNamed(context, '/signin');
              },
            )
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.inventory_2), text: "Inventory"),
              Tab(icon: Icon(Icons.shopping_bag), text: "Orders"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ===== INVENTORY TAB =====
            Container(
              color: Colors.white,
              child: productProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : productProvider.products.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No products yet",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Add your first product using the + button",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: productProvider.products.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];

                  // Initialize current image index for this product
                  if (!_currentImageIndexes.containsKey(product.id)) {
                    _currentImageIndexes[product.id] = 0;
                  }

                  final currentImageIndex =
                      _currentImageIndexes[product.id] ?? 0;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Image.network(
                                product.images.isNotEmpty
                                    ? product
                                    .images[currentImageIndex]
                                    : 'https://via.placeholder.com/150',
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stack) {
                                  return Container(
                                    height: 140,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),

                              if (product.images.length > 1) ...[
                                Positioned(
                                  left: 4,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (currentImageIndex > 0) {
                                            _currentImageIndexes[
                                            product.id] =
                                                currentImageIndex - 1;
                                          } else {
                                            _currentImageIndexes[
                                            product.id] =
                                                product.images.length -
                                                    1;
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding:
                                        const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.chevron_left,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Positioned(
                                  right: 4,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (currentImageIndex < product.images.length - 1) {
                                            _currentImageIndexes[product.id] = currentImageIndex + 1;
                                          } else {
                                            _currentImageIndexes[product.id] = 0;
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding:
                                        const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.chevron_right,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Image Counter
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withOpacity(0.7),
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${currentImageIndex + 1}/${product.images.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Product Details
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "\$${product.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Color(0xFF1E88E5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    product.isAvailable
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 14,
                                    color: product.isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Stock: ${product.totalStock}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Edit/Delete Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: InkWell(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EditProductPageWithImages(
                                                product: product,
                                                userId: authProvider
                                                    .user?['userId'],
                                              ),
                                        ),
                                      );
                                    },
                                    borderRadius:
                                    BorderRadius.circular(6),
                                    child: Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color:
                                        const Color(0xFF1E88E5),
                                        borderRadius:
                                        BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.edit,
                                              size: 16,
                                              color: Colors.white),
                                          SizedBox(width: 4),
                                          Text(
                                            "Edit",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: InkWell(
                                    onTap: () {
                                      _showDeleteConfirmation(
                                        context,
                                        product.id,
                                        product.name,
                                        productProvider,
                                      );
                                    },
                                    borderRadius:
                                    BorderRadius.circular(6),
                                    child: Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                        BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.delete,
                                              size: 16,
                                              color: Colors.white),
                                          SizedBox(width: 4),
                                          Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ===== ORDERS TAB =====
            Container(
              color: Colors.white,
              child: orderProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : orderProvider.orders.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No orders yet",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final userId = authProvider.user?['userId'];
                  if (userId != null) {
                    await orderProvider.fetchShoppingCenterOrders(userId);
                  }
                },
                color: const Color(0xFF1E88E5),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderProvider.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderProvider.orders[index];
                    final statusColor = _getOrderStatusColor(order.status);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade50, Colors.blue.shade100],
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFF1E88E5),
                                  radius: 24,
                                  child: Text(
                                    order.customerName[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.customerName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(order.createdAt),
                                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    order.status.toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Order Details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Order Summary
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      'LKR ${order.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E88E5),
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(height: 24),

                                // Order Items Preview
                                const Text(
                                  "Order Items:",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                ...order.items.take(3).map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        if (item.image.isNotEmpty)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              item.image,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 40,
                                                height: 40,
                                                color: Colors.grey[200],
                                                child: const Icon(Icons.image, size: 20),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.productName,
                                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'Size: ${item.size} | Color: ${item.color} | Qty: ${item.quantity}',
                                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'LKR ${(item.price * item.quantity).toStringAsFixed(2)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),

                                if (order.items.length > 3)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '+ ${order.items.length - 3} more items',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                                    ),
                                  ),

                                const Divider(height: 24),

                                // Contact Info
                                _buildInfoRow(Icons.phone, order.customerPhone),
                                const SizedBox(height: 4),
                                _buildInfoRow(Icons.email, order.customerEmail),
                                const SizedBox(height: 4),
                                _buildInfoRow(
                                  Icons.location_on,
                                  "${order.shippingAddress.street}, ${order.shippingAddress.city}, ${order.shippingAddress.postalCode}",
                                ),

                                const SizedBox(height: 16),

                                // ✅ STATUS UPDATE DROPDOWN
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.update, size: 18, color: Color(0xFF1E88E5)),
                                          SizedBox(width: 8),
                                          Text(
                                            "Update Order Status",
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      DropdownButtonFormField<String>(
                                        value: order.status,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: const Color(0xFF1E88E5).withOpacity(0.5)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: const Color(0xFF1E88E5).withOpacity(0.5)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        ),
                                        items: const [
                                          DropdownMenuItem(value: "PENDING", child: Text("Pending")),
                                          DropdownMenuItem(value: "PROCESSING", child: Text("Processing")),
                                          DropdownMenuItem(value: "ONGOING", child: Text("Ongoing")),
                                          DropdownMenuItem(value: "COMPLETED", child: Text("Completed")),
                                        ],
                                        onChanged: (value) async {
                                          if (value != null && value != order.status) {
                                            try {
                                              await orderProvider.updateStatus(order.id, value);

                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: [
                                                        const Icon(Icons.check_circle, color: Colors.white),
                                                        const SizedBox(width: 12),
                                                        Text("Status updated to ${value.toUpperCase()}"),
                                                      ],
                                                    ),
                                                    backgroundColor: Colors.green,
                                                    duration: const Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text("Failed to update status"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final authProvider =
            Provider.of<AuthProvider>(context, listen: false);

            final userId = authProvider.user?['userId'];
            print('🔍 Dashboard userId: $userId');

            if (userId != null && userId.toString().isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddProductPage(userId: userId),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please login again'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          backgroundColor: const Color(0xFF1E88E5),
          icon: const Icon(Icons.add),
          label: const Text("Add Product"),
        ),
      ),
    );
  }

  String _formatDate(DateTime utcDate) {
    final localDate = utcDate.toLocal();
    return DateFormat('MMM dd, yyyy - hh:mm a').format(localDate);
  }

  Color _getOrderStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'PROCESSING':
        return Colors.blue;
      case 'ONGOING':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1E88E5)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}