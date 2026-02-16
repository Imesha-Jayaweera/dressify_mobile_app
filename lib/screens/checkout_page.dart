import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController(text: "Sri Lanka");

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill user data
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      nameController.text = authProvider.user?['name'] ?? '';
      emailController.text = authProvider.user?['email'] ?? '';
    });
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      final customerId = authProvider.user?['userId'] ?? authProvider.user?['_id'];

      // Prepare order items
      final items = cartProvider.cartItems.map((cartItem) {
        return {
          'productId': cartItem.product.id,
          'quantity': cartItem.quantity,
          'size': cartItem.selectedSize,
          'color': cartItem.selectedColor,
        };
      }).toList();

      // Create order
      final success = await orderProvider.createOrder(
        customerId: customerId,
        customerName: nameController.text,
        customerEmail: emailController.text,
        customerPhone: phoneController.text,
        shippingAddress: {
          'street': streetController.text,
          'city': cityController.text,
          'postalCode': postalCodeController.text,
          'country': countryController.text,
        },
        items: items,
      );

      if (success) {
        // Clear cart after successful order
        await cartProvider.fetchCart();

        if (mounted) {
          // ✅ Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text("Order placed successfully!")),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // ✅ FIXED: Pop back to dashboard with result
          Navigator.of(context).pop(); // Pop checkout page
          Navigator.of(context).pop(); // Pop cart page (if needed)

          // ✅ Navigate back with tab index to switch to Orders tab
          Navigator.of(context).pushReplacementNamed(
            '/customer-dashboard',
            arguments: {'initialTab': 3}, // Orders tab index
          );
        }
      } else {
        throw Exception("Order placement failed");
      }
    } catch (e) {
      print('❌ Order placement error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text("Error: ${e.toString()}")),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E2DE2),
        title: const Text("Checkout", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              _buildOrderSummary(cartProvider),

              const SizedBox(height: 24),

              // Shipping Information
              const Text(
                "Shipping Information",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8E2DE2),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField("Full Name", nameController, Icons.person),
              const SizedBox(height: 12),
              _buildTextField("Email", emailController, Icons.email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField("Phone Number", phoneController, Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField("Street Address", streetController, Icons.home),
              const SizedBox(height: 12),
              _buildTextField("City", cityController, Icons.location_city),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField("Postal Code", postalCodeController, Icons.markunread_mailbox),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField("Country", countryController, Icons.flag),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E2DE2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Place Order",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8E2DE2),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Items:", style: TextStyle(fontSize: 16)),
              Text(
                "${cartProvider.totalQuantity}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal:", style: TextStyle(fontSize: 16)),
              Text(
                "LKR ${cartProvider.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Delivery:", style: TextStyle(fontSize: 16)),
              Text(
                "LKR 500.00",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "LKR ${(cartProvider.totalAmount + 500).toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8E2DE2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF8E2DE2)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8E2DE2), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    super.dispose();
  }
}