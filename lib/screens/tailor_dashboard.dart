import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/custom_order_provider.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'product_page.dart';
import 'edit_product_page.dart';

class TailorDashboard extends StatefulWidget {
  const TailorDashboard({super.key});

  @override
  State<TailorDashboard> createState() => _TailorDashboardState();
}

class _TailorDashboardState extends State<TailorDashboard> {
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
          await Provider.of<CustomOrderProvider>(context, listen: false)
              .fetchTailorCustomOrders(userId);
        } catch (e) {
          print('Error fetching custom orders: $e');
        }
      }
    });
  }

  String _formatDate(DateTime utcDate) {
    final localDate = utcDate.toLocal();
    return DateFormat('MMM dd, yyyy - hh:mm a').format(localDate);
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'PROCESSING':
        return Colors.blue;
      case 'ONGOING':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.teal;
      default:
        return Colors.grey;
    }
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
                "This action can't be undo.",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await productProvider.deleteProduct(productId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$productName deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete product'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final customOrderProvider = Provider.of<CustomOrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.orange,
        appBar: AppBar(
          backgroundColor: Colors.orange,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dressify Tailor",
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
              Tab(icon: Icon(Icons.inventory_2), text: "My Products"),
              Tab(icon: Icon(Icons.request_quote), text: "Custom Requests"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ===== MY PRODUCTS TAB =====
            _buildProductsTab(productProvider, authProvider),

            // ===== CUSTOM REQUESTS TAB =====
            _buildCustomRequestsTab(customOrderProvider),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final userId = authProvider.user?['userId'];
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
          backgroundColor: Colors.deepOrange,
          icon: const Icon(Icons.add),
          label: const Text("Add Product"),
        ),
      ),
    );
  }

  Widget _buildProductsTab(ProductProvider productProvider, AuthProvider authProvider) {
    return Container(
      color: Colors.white,
      child: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : productProvider.products.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("No products yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text("Add your first product using the + button", style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: productProvider.products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.58,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final product = productProvider.products[index];
          if (!_currentImageIndexes.containsKey(product.id)) {
            _currentImageIndexes[product.id] = 0;
          }
          final currentImageIndex = _currentImageIndexes[product.id] ?? 0;

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Stack(
                    children: [
                      Image.network(
                        product.images.isNotEmpty ? product.images[currentImageIndex] : 'https://via.placeholder.com/150',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) {
                          return Container(
                            height: 140,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
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
                                    _currentImageIndexes[product.id] = currentImageIndex - 1;
                                  } else {
                                    _currentImageIndexes[product.id] = product.images.length - 1;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
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
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${currentImageIndex + 1}/${product.images.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "\$${product.price.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProductPageWithImages(
                                  product: product,
                                  userId: authProvider.user?['userId'],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit, size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text("Edit", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _showDeleteConfirmation(context, product.id, product.name, productProvider);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text("Delete", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
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
    );
  }

  Widget _buildCustomRequestsTab(CustomOrderProvider customOrderProvider) {
    return Container(
      color: const Color(0xFFF9F9F9),
      child: customOrderProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : customOrderProvider.customOrders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.request_quote_outlined, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("No custom requests yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text("Customer requests will appear here", style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final userId = authProvider.user?['userId'];
          if (userId != null) {
            await customOrderProvider.fetchTailorCustomOrders(userId);
          }
        },
        color: Colors.orange,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: customOrderProvider.customOrders.length,
          itemBuilder: (context, index) {
            final order = customOrderProvider.customOrders[index];
            return _buildCustomRequestCard(order, customOrderProvider);
          },
        ),
      ),
    );
  }

  Widget _buildCustomRequestCard(dynamic order, CustomOrderProvider customOrderProvider) {
    final statusColor = _getStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.orange.shade100],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
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

          // Product Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (order.productImage.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          order.productImage,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 80,
                            width: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 30),
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.shopping_cart, "Quantity: ${order.quantity}"),
                          const SizedBox(height: 4),
                          _buildInfoRow(Icons.palette, "Color: ${order.selectedColor}"),
                        ],
                      ),
                    ),
                  ],
                ),

                if (order.additionalNotes != null && order.additionalNotes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note, size: 18, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Additional Notes:",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange),
                              ),
                              const SizedBox(height: 4),
                              Text(order.additionalNotes!, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Divider(height: 24),

                // Contact Info
                _buildInfoRow(Icons.phone, order.customerPhone),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.email, order.customerEmail),

                const SizedBox(height: 16),

                // ✅ ACTION BUTTONS - PENDING STATE
                if (order.status == 'PENDING') ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await customOrderProvider.updateStatus(order.id, 'REJECTED');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.cancel, color: Colors.white),
                                      SizedBox(width: 12),
                                      Text("Order rejected"),
                                    ],
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.cancel, size: 20),
                          label: const Text("Reject", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await customOrderProvider.updateStatus(order.id, 'ACCEPTED');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 12),
                                      Text("Order accepted!"),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_circle, size: 20),
                          label: const Text("Accept", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // ✅ STATUS UPDATE DROPDOWN - ACCEPTED/PROCESSING/ONGOING STATE
                if (order.status == 'ACCEPTED' || order.status == 'PROCESSING' || order.status == 'ONGOING') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.update, size: 18, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              "Update Order Status",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
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
                              borderSide: BorderSide(color: Colors.orange.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.orange.withOpacity(0.5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.orange, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: "ACCEPTED", child: Text("Accepted")),
                            DropdownMenuItem(value: "PROCESSING", child: Text("Processing")),
                            DropdownMenuItem(value: "ONGOING", child: Text("Ongoing")),
                            DropdownMenuItem(value: "COMPLETED", child: Text("Completed")),
                          ],
                          onChanged: (value) async {
                            if (value != null && value != order.status) {
                              await customOrderProvider.updateStatus(order.id, value);
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
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                // ✅ COMPLETED/REJECTED STATE
                if (order.status == 'COMPLETED' || order.status == 'REJECTED') ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: order.status == 'COMPLETED' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: order.status == 'COMPLETED' ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          order.status == 'COMPLETED' ? Icons.check_circle : Icons.cancel,
                          color: order.status == 'COMPLETED' ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            order.status == 'COMPLETED' ? "Order completed successfully!" : "Order was rejected",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: order.status == 'COMPLETED' ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.orange),
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