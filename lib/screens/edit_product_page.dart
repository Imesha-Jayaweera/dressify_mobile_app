import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  final String? userId;

  const EditProductPage({
    super.key,
    required this.product,
    required this.userId,
  });

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedCategory;
  String? _selectedGender;
  List<String> _selectedColors = [];
  List<String> _selectedBodyTypes = [];
  List<SizeStock> _sizes = [];
  bool _isLoading = false;

  // Categories matching your add product page
  final List<String> categories = [
    'JACKET',
    'SHIRT',
    'SKIRT',
    'BLOUSE',
    'TROUSER',
    'TSHIRT',
    'SHORTS',
    'FROCK',
    'OTHER'
  ];

  // Genders matching your add product page
  final List<String> genders = ['MALE', 'FEMALE'];

  // Sizes matching your add product page
  final List<String> availableSizes = ['S', 'M', 'L', 'XL'];

  // Colors matching your add product page
  final List<String> availableColors = [
    'Red',
    'Blue',
    'Black',
    'White',
    'Green',
    'Yellow',
    'Pink',
    'Purple',
    'Orange',
    'Gray'
  ];

  // Body Types matching your add product page
  final List<String> bodyTypes = [
    'ALL',
    'ROUND',
    'HOURGLASS',
    'INVERTED_TRIANGLE',
    'RECTANGLE',
    'TRIANGLE',
    'OVAL',
    'TRAPEZOID',
    'INVERTED_TRAPEZOID'
  ];

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  void _loadProductData() {
    _nameController.text = widget.product.name;
    _descriptionController.text = widget.product.description;
    _priceController.text = widget.product.price.toString();

    // Load category
    _selectedCategory = widget.product.category.toUpperCase();
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = 'OTHER';
    }

    // Load gender
    _selectedGender = widget.product.genderType.toUpperCase();
    if (!genders.contains(_selectedGender)) {
      _selectedGender = 'FEMALE';
    }

    // Load sizes - ensure all available sizes are present
    _sizes = [];
    for (var size in availableSizes) {
      final existingSize = widget.product.sizes.firstWhere(
            (s) => s.size.toUpperCase() == size.toUpperCase(),
        orElse: () => SizeStock(size: size, stock: 0),
      );
      _sizes.add(SizeStock(size: size, stock: existingSize.stock));
    }

    // Load colors
    _selectedColors = List<String>.from(widget.product.colors);

    // Load body types
    _selectedBodyTypes = List<String>.from(widget.product.suitableBodyTypes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select category and gender'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedColors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one color'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'category': _selectedCategory,
        'genderType': _selectedGender,
        'sizes': _sizes.map((s) => s.toJson()).toList(),
        'colors': _selectedColors,
        'suitableBodyTypes': _selectedBodyTypes.isEmpty ? ['ALL'] : _selectedBodyTypes,
      };

      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      // Provider now handles refresh internally
      await productProvider.updateProduct(widget.product.id, productData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Product updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Pop with success flag to trigger UI update
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E2DE2),
        title: const Text(
          'Edit Product',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Images Preview
              if (widget.product.images.isNotEmpty) ...[
                const Text(
                  "Product Images",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount: widget.product.images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.product.images[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Product Name
              const Text(
                "Product Name",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                validator: (v) => v!.isEmpty ? "Required" : null,
                decoration: InputDecoration(
                  hintText: "Elegant Evening Dress",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              const Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Product description...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category
              const Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: categories
                    .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Gender
              const Text(
                "Gender Type",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'MALE', child: Text('Male')),
                  DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                ],
                onChanged: (value) {
                  setState(() => _selectedGender = value);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Price
              const Text(
                "Price (\$)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid price';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "99.99",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sizes and Stock
              const Text(
                "Sizes & Stock",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ..._sizes.map((sizeStock) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          sizeStock.size,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          initialValue: sizeStock.stock.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              final index = _sizes.indexWhere((s) => s.size == sizeStock.size);
                              if (index != -1) {
                                _sizes[index] = SizeStock(
                                  size: sizeStock.size,
                                  stock: int.tryParse(value) ?? 0,
                                );
                              }
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "0",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 16),

              // Colors
              const Text(
                "Colors",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableColors.map((color) {
                  final isSelected = _selectedColors.contains(color);
                  return FilterChip(
                    label: Text(color),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedColors.add(color);
                        } else {
                          _selectedColors.remove(color);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF8E2DE2).withOpacity(0.3),
                    checkmarkColor: const Color(0xFF8E2DE2),
                    backgroundColor: Colors.white,
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Body Types
              const Text(
                "Suitable Body Types",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: bodyTypes.map((type) {
                  final isSelected = _selectedBodyTypes.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedBodyTypes.add(type);
                        } else {
                          _selectedBodyTypes.remove(type);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF8E2DE2).withOpacity(0.3),
                    checkmarkColor: const Color(0xFF8E2DE2),
                    backgroundColor: Colors.white,
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8E2DE2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}