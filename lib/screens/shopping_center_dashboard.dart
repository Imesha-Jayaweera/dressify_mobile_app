import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import 'product_page.dart';
import 'edit_product_page.dart';

class ShoppingCenterDashboard extends StatefulWidget {
  const ShoppingCenterDashboard({super.key});

  @override
  State<ShoppingCenterDashboard> createState() =>
      _ShoppingCenterDashboardState();
}

class _ShoppingCenterDashboardState extends State<ShoppingCenterDashboard> {
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
          await Provider.of<OrderProvider>(context, listen: false).fetchOrders();
        } catch (e) {
          print('Error fetching orders: $e');
          // Orders endpoint might not exist yet, so we'll just continue
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
            // Cancel Button
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            // Delete Button
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
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('$productName deleted successfully'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              Tab(icon: Icon(Icons.auto_awesome), text: "AI Suggestions"),
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

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            product.images.isNotEmpty
                                ? product.images[0]
                                : 'https://via.placeholder.com/150',
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) {
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: InkWell(
                                    onTap: () async {
                                      // Navigate to edit page
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditProductPage(
                                            product: product,
                                            userId: authProvider.user?['userId'],
                                          ),
                                        ),
                                      );
                                      // Provider already refreshed the list
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E88E5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.edit, size: 16, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text(
                                            "Edit",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
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
                                    borderRadius: BorderRadius.circular(6),
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
                                          Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
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
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orderProvider.orders.length,
                itemBuilder: (context, index) {
                  final order = orderProvider.orders[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF1E88E5),
                        child: Text(
                          order.customerName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(order.productName),
                      subtitle: Text(order.customerName),
                      trailing: DropdownButton<String>(
                        value: order.status,
                        items: const [
                          DropdownMenuItem(
                            value: "processing",
                            child: Text("Processing"),
                          ),
                          DropdownMenuItem(
                            value: "ongoing",
                            child: Text("Ongoing"),
                          ),
                          DropdownMenuItem(
                            value: "success",
                            child: Text("Success"),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            orderProvider.updateStatus(order.id, value);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // ===== AI TAB =====
            Container(
              color: Colors.white,
              child: const Center(
                child: Text("AI Recommendations will load here"),
              ),
            ),
          ],
        ),


        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
          backgroundColor: const Color(0xFF8E2DE2),
          icon: const Icon(Icons.add),
          label: const Text("Add Product"),
        ),
      ),
    );
  }
}