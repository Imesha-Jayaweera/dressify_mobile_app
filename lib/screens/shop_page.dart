import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product.dart';
import 'custom_order_request_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String? selectedGender;
  String? selectedCategory;
  String? selectedSize;
  RangeValues priceRange = const RangeValues(0, 10000);
  bool showFilters = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadProducts());
  }

  Future<void> _loadProducts() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    await provider.fetchAllProducts(
      genderType: selectedGender,
      category: selectedCategory,
      size: selectedSize,
      minPrice: priceRange.start,
      maxPrice: priceRange.end,
    );
  }

  void _applyFilters() {
    setState(() => showFilters = false);
    _loadProducts();
  }

  void _resetFilters() {
    setState(() {
      selectedGender = null;
      selectedCategory = null;
      selectedSize = null;
      priceRange = const RangeValues(0, 10000);
    });
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildFilterToggle(),
          if (showFilters) _buildFiltersSection(),
          Expanded(child: _buildProductsGrid()),
        ],
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.store, color: Color(0xFF8E2DE2), size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Discover Fashion",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8E2DE2),
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => showFilters = !showFilters),
            icon: Icon(
              showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: const Color(0xFF8E2DE2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filters",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8E2DE2),
                ),
              ),
              TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Reset"),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),

          // Gender Filter
          _buildFilterChips(
            "Gender",
            ["MALE", "FEMALE"],
            selectedGender,
                (v) => setState(() => selectedGender = v),
          ),
          const SizedBox(height: 16),

          // Category Filter
          _buildFilterChips(
            "Category",
            ["JACKET", "SHIRT", "SKIRT", "BLOUSE", "TROUSER", "TSHIRT", "SHORTS", "FROCK", "OTHER"],
            selectedCategory,
                (v) => setState(() => selectedCategory = v),
          ),
          const SizedBox(height: 16),

          // Size Filter
          _buildFilterChips(
            "Size",
            ["S", "M", "L", "XL"],
            selectedSize,
                (v) => setState(() => selectedSize = v),
          ),
          const SizedBox(height: 16),

          // Price Range
          Text(
            "Price Range: LKR ${priceRange.start.toInt()} - ${priceRange.end.toInt()}",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF8E2DE2),
            ),
          ),
          RangeSlider(
            values: priceRange,
            min: 0,
            max: 10000,
            divisions: 100,
            activeColor: const Color(0xFF8E2DE2),
            onChanged: (values) => setState(() => priceRange = values),
          ),
          const SizedBox(height: 12),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E2DE2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Apply Filters",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
      String label,
      List<String> options,
      String? selected,
      Function(String?) onSelected,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF8E2DE2),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return GestureDetector(
              onTap: () => onSelected(isSelected ? null : option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF8E2DE2) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
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

        if (provider.allProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 100,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  "No products found",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Try adjusting your filters",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset Filters"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E2DE2),
                    foregroundColor: Colors.white,
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
          onRefresh: _loadProducts,
          color: const Color(0xFF8E2DE2),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.allProducts.length,
            itemBuilder: (context, index) {
              return _buildProductCard(provider.allProducts[index]);
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

                  // Stock Badge
                  if (!isTailor && product.totalStock < 10)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.totalStock == 0 ? Colors.red : Colors.yellow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.totalStock == 0 ? "Out of stock" : "Low stock",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 7,
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

// ============================================================================
// ADD TO CART DIALOG
// ============================================================================

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
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFFEC008C)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text("Add to Cart", style: TextStyle(fontSize: 18)),
          ),
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
            const SizedBox(height: 4),
            Text(
              "LKR ${widget.product.price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8E2DE2),
              ),
            ),
            const SizedBox(height: 16),

            // Size Selection
            const Text(
              "Select Size:",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (availableSizes.isEmpty)
              Text(
                "No sizes available",
                style: TextStyle(color: Colors.red[700]),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
            const Text(
              "Select Color:",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text("${widget.product.name} added to cart!"),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF8E2DE2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8E2DE2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Add to Cart"),
        ),
      ],
    );
  }
}