import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/product.dart';
import '../providers/product_provider.dart';

class EditProductPageWithImages extends StatefulWidget {
  final Product product;
  final String? userId;

  const EditProductPageWithImages({
    super.key,
    required this.product,
    required this.userId,
  });

  @override
  State<EditProductPageWithImages> createState() => _EditProductPageWithImagesState();
}

class _EditProductPageWithImagesState extends State<EditProductPageWithImages> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedCategory;
  String? _selectedGender;
  List<String> _selectedColors = [];
  List<String> _selectedBodyTypes = [];
  List<SizeStock> _sizes = [];
  bool _isLoading = false;

  // ✅ Image management
  List<String> _existingImages = []; // Cloudinary URLs
  List<File> _newImages = []; // New images to upload
  Set<String> _imagesToDelete = {}; // Images marked for deletion

  // Categories, genders, etc.
  final List<String> categories = [
    'JACKET', 'SHIRT', 'SKIRT', 'BLOUSE', 'TROUSER',
    'TSHIRT', 'SHORTS', 'FROCK', 'OTHER'
  ];

  final List<String> genders = ['MALE', 'FEMALE'];
  final List<String> availableSizes = ['S', 'M', 'L', 'XL'];
  final List<String> availableColors = [
    'Red', 'Blue', 'Black', 'White', 'Green',
    'Yellow', 'Pink', 'Purple', 'Orange', 'Gray'
  ];
  final List<String> bodyTypes = [
    'ALL', 'ROUND', 'HOURGLASS', 'INVERTED_TRIANGLE',
    'RECTANGLE', 'TRIANGLE', 'OVAL', 'TRAPEZOID', 'INVERTED_TRAPEZOID'
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

    _selectedCategory = widget.product.category.toUpperCase();
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = 'OTHER';
    }

    _selectedGender = widget.product.genderType.toUpperCase();
    if (!genders.contains(_selectedGender)) {
      _selectedGender = 'FEMALE';
    }

    // Load sizes
    _sizes = [];
    for (var size in availableSizes) {
      final existingSize = widget.product.sizes.firstWhere(
            (s) => s.size.toUpperCase() == size.toUpperCase(),
        orElse: () => SizeStock(size: size, stock: 0),
      );
      _sizes.add(SizeStock(size: size, stock: existingSize.stock));
    }

    _selectedColors = List<String>.from(widget.product.colors);
    _selectedBodyTypes = List<String>.from(widget.product.suitableBodyTypes);

    // ✅ Load existing images
    _existingImages = List<String>.from(widget.product.images);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ✅ Pick new images
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _newImages.addAll(images.map((img) => File(img.path)));
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${images.length} new images added'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error picking images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick images'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ Mark existing image for deletion
  void _markImageForDeletion(String imageUrl) {
    setState(() {
      if (_imagesToDelete.contains(imageUrl)) {
        _imagesToDelete.remove(imageUrl);
      } else {
        _imagesToDelete.add(imageUrl);
      }
    });
  }

  // ✅ Remove new image before upload
  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
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

    // Check if there will be any images left after deletion
    final remainingExistingImages = _existingImages
        .where((img) => !_imagesToDelete.contains(img))
        .toList();

    if (remainingExistingImages.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product must have at least one image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Update product data with image changes
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'category': _selectedCategory,
        'genderType': _selectedGender,
        'sizes': _sizes.map((s) => s.toJson()).toList(),
        'colors': _selectedColors,
        'suitableBodyTypes':
        _selectedBodyTypes.isEmpty ? ['ALL'] : _selectedBodyTypes,
        // ✅ Only keep images that aren't marked for deletion
        'images': remainingExistingImages,
      };

      final productProvider =
      Provider.of<ProductProvider>(context, listen: false);

      // TODO: If you have new images, you need to upload them first
      // For now, we'll just update with existing images
      // You'll need to add an endpoint to handle image uploads during edit

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
              // ✅ IMAGES MANAGEMENT SECTION
              const Text(
                "Product Images",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),

              // Existing Images
              if (_existingImages.isNotEmpty) ...[
                const Text(
                  "Current Images (tap to mark for deletion):",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _existingImages.length,
                    itemBuilder: (context, index) {
                      final imageUrl = _existingImages[index];
                      final isMarkedForDeletion =
                      _imagesToDelete.contains(imageUrl);

                      return GestureDetector(
                        onTap: () => _markImageForDeletion(imageUrl),
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isMarkedForDeletion
                                  ? Colors.red
                                  : Colors.grey[300]!,
                              width: isMarkedForDeletion ? 3 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  color: isMarkedForDeletion
                                      ? Colors.red.withOpacity(0.5)
                                      : null,
                                  colorBlendMode: isMarkedForDeletion
                                      ? BlendMode.darken
                                      : null,
                                  errorBuilder: (context, error, stack) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (isMarkedForDeletion)
                                const Center(
                                  child: Icon(
                                    Icons.delete_forever,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // New Images
              if (_newImages.isNotEmpty) ...[
                const Text(
                  "New Images to Upload:",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _newImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _newImages[index],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeNewImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Add Images Button
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text("Add More Images"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8E2DE2),
                  side: const BorderSide(color: Color(0xFF8E2DE2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 20),

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
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          initialValue: sizeStock.stock.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              final index = _sizes.indexWhere(
                                      (s) => s.size == sizeStock.size);
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
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    selectedColor:
                    const Color(0xFF8E2DE2).withOpacity(0.3),
                    checkmarkColor: const Color(0xFF8E2DE2),
                    backgroundColor: Colors.white,
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Body Types
              const Text(
                "Suitable Body Types",
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    selectedColor:
                    const Color(0xFF8E2DE2).withOpacity(0.3),
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
                        onPressed: _isLoading
                            ? null
                            : () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(vertical: 16),
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
                          padding:
                          const EdgeInsets.symmetric(vertical: 16),
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
                          mainAxisAlignment:
                          MainAxisAlignment.center,
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