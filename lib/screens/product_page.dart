import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class AddProductPage extends StatefulWidget {
  final String userId;

  const AddProductPage({super.key, required this.userId});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  // Selected values
  String selectedCategory = 'OTHER';
  String selectedGender = 'FEMALE';
  List<String> selectedColors = [];
  List<String> selectedBodyTypes = [];
  List<File> selectedImages = [];

  // Size and stock
  List<SizeStock> sizes = [
    SizeStock(size: 'S', stock: 0),
    SizeStock(size: 'M', stock: 0),
    SizeStock(size: 'L', stock: 0),
    SizeStock(size: 'XL', stock: 0),
  ];

  bool isLoading = false;

  // Categories
  final categories = [
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

  // Colors
  final availableColors = [
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

  // Body Types
  final bodyTypes = [
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

  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        selectedImages = images.map((img) => File(img.path)).toList();
      });
    }
  }

  Future<void> submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedImages.isEmpty) {
      Fluttertoast.showToast(msg: "Please add at least one image");
      return;
    }

    if (selectedColors.isEmpty) {
      Fluttertoast.showToast(msg: "Please select at least one color");
      return;
    }

    setState(() => isLoading = true);

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      final productData = {
        'name': nameController.text,
        'description': descriptionController.text,
        'category': selectedCategory,
        'genderType': selectedGender,
        'price': double.tryParse(priceController.text) ?? 0,
        'sizes': sizes.map((s) => s.toJson()).toList(),
        'colors': selectedColors,
        'suitableBodyTypes': selectedBodyTypes.isEmpty ? ['ALL'] : selectedBodyTypes,
      };

      await productProvider.addProduct(
        productData,
        selectedImages,
        widget.userId,
      );

      Fluttertoast.showToast(
        msg: "Product added successfully",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.green,
      );

      Navigator.pop(context);
    } catch (e) {
      print('❌ Submit error: $e');
      Fluttertoast.showToast(
        msg: "Failed to add product: $e",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FA),
      appBar: AppBar(
        title: const Text("Add New Product"),
        backgroundColor: const Color(0xFF8E2DE2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Images
              const Text(
                "Product Images",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              GestureDetector(
                onTap: pickImages,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: selectedImages.isEmpty
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 50),
                        SizedBox(height: 8),
                        Text("Tap to add images"),
                      ],
                    ),
                  )
                      : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                selectedImages[index],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    selectedImages.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Product Name
              const Text("Product Name"),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
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
              const Text("Description"),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
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
              const Text("Category"),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories
                    .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedCategory = value!);
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
              const Text("Gender Type"),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: const [
                  DropdownMenuItem(value: 'MALE', child: Text('Male')),
                  DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                ],
                onChanged: (value) {
                  setState(() => selectedGender = value!);
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
              const Text("Price (\$)"),
              const SizedBox(height: 8),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Required" : null,
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
              const Text("Sizes & Stock"),
              const SizedBox(height: 8),
              ...sizes.map((sizeStock) {
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
                              final index = sizes.indexWhere((s) => s.size == sizeStock.size);
                              if (index != -1) {
                                sizes[index] = SizeStock(
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
              const Text("Colors"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: availableColors.map((color) {
                  final isSelected = selectedColors.contains(color);
                  return FilterChip(
                    label: Text(color),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedColors.add(color);
                        } else {
                          selectedColors.remove(color);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Body Types
              const Text("Suitable Body Types"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: bodyTypes.map((type) {
                  final isSelected = selectedBodyTypes.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedBodyTypes.add(type);
                        } else {
                          selectedBodyTypes.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E2DE2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Add Product",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }
}