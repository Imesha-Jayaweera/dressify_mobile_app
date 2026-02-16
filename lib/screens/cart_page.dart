import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'checkout_page.dart'; // ADD THIS IMPORT

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.items.isEmpty) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text("Your cart is empty", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text("Add products from the Shop tab", style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                ],
              ),
            ),
          );
        }

        return Container(
          color: const Color(0xFFF6F0FA),
          child: Column(
            children: [
              // Cart Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.cartItems[index];
                    return _buildCartItem(cartItem, cartProvider);
                  },
                ),
              ),

              // Bottom Summary
              _buildBottomSummary(cartProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartItem(dynamic cartItem, CartProvider cartProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: cartItem.product.images.isNotEmpty
                  ? Image.network(
                cartItem.product.images.first,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image),
                ),
              )
                  : Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.checkroom),
              ),
            ),

            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Size: ${cartItem.selectedSize} | Color: ${cartItem.selectedColor}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "LKR ${cartItem.product.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8E2DE2),
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    cartProvider.updateQuantity(
                      cartItem.product.id,
                      cartItem.selectedSize,
                      cartItem.selectedColor,
                      cartItem.quantity + 1,
                    );
                  },
                  icon: const Icon(Icons.add_circle, color: Color(0xFF8E2DE2)),
                ),
                Text(
                  '${cartItem.quantity}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    cartProvider.updateQuantity(
                      cartItem.product.id,
                      cartItem.selectedSize,
                      cartItem.selectedColor,
                      cartItem.quantity - 1,
                    );
                  },
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
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
                const Text("Total Amount:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  "LKR ${cartProvider.totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E2DE2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ UPDATED BUTTON WITH VALIDATION
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // ✅ Check if all products are from same shopping center
                  if (!_validateSameShoppingCenter(cartProvider)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please checkout items from one store at a time"),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E2DE2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Proceed to Checkout",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ VALIDATION HELPER METHOD
  bool _validateSameShoppingCenter(CartProvider cartProvider) {
    if (cartProvider.cartItems.isEmpty) return false;

    final firstShoppingCenterId = cartProvider.cartItems.first.product.shoppingCenterId;

    for (var item in cartProvider.cartItems) {
      if (item.product.shoppingCenterId != firstShoppingCenterId) {
        return false;
      }
    }

    return true;
  }
}