import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product.dart';
import 'custom_order_request_page.dart';

class RecommendedShopPage extends StatefulWidget {
  final String genderType;
  final String bodyType;
  final String skinTone;

  const RecommendedShopPage({
    Key? key,
    required this.genderType,
    required this.bodyType,
    required this.skinTone,
  }) : super(key: key);

  @override
  State<RecommendedShopPage> createState() => _RecommendedShopPageState();
}

class _RecommendedShopPageState extends State<RecommendedShopPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadRecommendedProducts());
  }

  Future<void> _loadRecommendedProducts() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    await provider.fetchRecommendedProducts(
      genderType: widget.genderType,
      bodyType: widget.bodyType,
      skinTone: widget.skinTone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E2DE2),
        title: const Text(
          "Recommended for You",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterInfo(),
          Expanded(child: _buildProductsGrid()),
        ],
      ),
    );
  }

  Widget _buildFilterInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF8E2DE2).withOpacity(0.1), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF8E2DE2), size: 32),
          const SizedBox(height: 12),
          const Text(
            "Personalized for Your Body",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8E2DE2),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildInfoChip(Icons.person, widget.genderType, Colors.purple),
              _buildInfoChip(Icons.accessibility, widget.bodyType, Colors.orange),
              _buildInfoChip(Icons.palette, widget.skinTone, Colors.pink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8E2DE2)),
          );
        }

        if (provider.recommendedProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 100,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  "No matching products found",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Try browsing all products",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    DefaultTabController.of(context)?.animateTo(1);
                  },
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text("Browse All Products"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E2DE2),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadRecommendedProducts,
          color: const Color(0xFF8E2DE2),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.recommendedProducts.length,
            itemBuilder: (context, index) {
              return _buildProductCard(provider.recommendedProducts[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final isTailor = product.isTailorProduct;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.images.isNotEmpty
                      ? Image.network(
                    product.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                    ),
                  )
                      : Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.checkroom, size: 40, color: Colors.grey),
                  ),

                  // Perfect Match Badge
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.teal],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 10),
                          SizedBox(width: 3),
                          Text(
                            "Match",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Seller Badge
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isTailor ? Colors.orange : Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isTailor ? "Tailor" : "Shop",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "LKR ${product.price.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E2DE2),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: ElevatedButton(
                    onPressed: product.totalStock == 0 && !isTailor
                        ? null
                        : () {
                      if (isTailor) {
                        _showCustomOrderDialog(product);
                      } else {
                        _addToCart(product);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTailor ? Colors.orange : const Color(0xFF8E2DE2),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: Text(
                      product.totalStock == 0 && !isTailor
                          ? "Out"
                          : isTailor
                          ? "Request"
                          : "Add",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: product.totalStock == 0 && !isTailor ? Colors.grey : Colors.white,
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
  }

  void _addToCart(Product product) {
    showDialog(
      context: context,
      builder: (context) => _AddToCartDialog(product: product),
    );
  }

  void _showCustomOrderDialog(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomOrderRequestPage(product: product),
      ),
    );
  }
}

// Add to Cart Dialog (same as shop_page.dart)
class _AddToCartDialog extends StatefulWidget {
  final Product product;

  const _AddToCartDialog({required this.product});

  @override
  State<_AddToCartDialog> createState() => _AddToCartDialogState();
}

class _AddToCartDialogState extends State<_AddToCartDialog> {
  String? selectedSize;
  String? selectedColor;

  @override
  Widget build(BuildContext context) {
    final availableSizes = widget.product.sizes
        .where((s) => s.stock > 0)
        .map((s) => s.size)
        .toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.shopping_cart, color: Color(0xFF8E2DE2)),
          SizedBox(width: 12),
          Expanded(child: Text("Add to Cart", style: TextStyle(fontSize: 18))),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Size Selection
            const Text("Select Size:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: availableSizes.map((size) {
                final isSelected = selectedSize == size;
                return GestureDetector(
                  onTap: () => setState(() => selectedSize = size),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF8E2DE2) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      size,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Color Selection
            const Text("Select Color:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.product.colors.map((color) {
                final isSelected = selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF8E2DE2) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      color,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: selectedSize == null || selectedColor == null
              ? null
              : () {
            final cartProvider = Provider.of<CartProvider>(context, listen: false);
            cartProvider.addItem(widget.product, selectedSize!, selectedColor!);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${widget.product.name} added to cart!"),
                backgroundColor: const Color(0xFF8E2DE2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8E2DE2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Add to Cart"),
        ),
      ],
    );
  }
}