import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import 'body_measurement_page.dart';
import 'shop_page.dart';
import 'cart_page.dart';
import 'orders_page.dart';

class CustomerDashboard extends StatefulWidget {
  final int initialTab; // ADD THIS

  const CustomerDashboard({Key? key, this.initialTab = 0}) : super(key: key); // ADD THIS

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab, // ✅ USE INITIAL TAB
    );

    // ✅ SET USER ID IN CART PROVIDER
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      final userId = authProvider.user?['userId'] ?? authProvider.user?['_id'];
      if (userId != null) {
        cartProvider.setUserId(userId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF8E2DE2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E2DE2),
        elevation: 0,
        automaticallyImplyLeading: false, // ✅ REMOVE BACK BUTTON
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dressify",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              authProvider.user?['email'] ?? 'Guest',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Notifications coming soon!"),
                  backgroundColor: Color(0xFF8E2DE2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E2DE2),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                // ✅ CLEAR CART ON LOGOUT
                final cartProvider = Provider.of<CartProvider>(context, listen: false);
                cartProvider.clearLocalCart();

                await authProvider.logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/signin');
                }
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: "Analyze"),
            Tab(icon: Icon(Icons.shopping_bag), text: "Shop"),
            Tab(icon: Icon(Icons.shopping_cart), text: "Cart"),
            Tab(icon: Icon(Icons.receipt_long), text: "Orders"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BodyMeasurementPage(),
          ShopPage(),
          CartPage(),
          OrdersPage(),
        ],
      ),
    );
  }
}