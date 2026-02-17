import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/body_analysis_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'fashion_tips_page.dart';

class BodyMeasurementPage extends StatefulWidget {
  const BodyMeasurementPage({Key? key}) : super(key: key);

  @override
  State<BodyMeasurementPage> createState() => _BodyMeasurementPageState();
}

class _BodyMeasurementPageState extends State<BodyMeasurementPage> {
  File? _imageFile;
  bool isLoading = false;
  Map<String, dynamic>? result;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> analyzeImage() async {
    if (_imageFile == null) {
      Fluttertoast.showToast(
        msg: "Please select an image first",
        backgroundColor: const Color(0xFF8E2DE2),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Detect the actual image format from the file extension
      final extension = _imageFile!.path.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'png' : 'jpeg';

      // Send as data URL with correct MIME type
      final dataUrl = 'data:image/$mimeType;base64,$base64Image';

      print("Sending image with MIME type: image/$mimeType");
      print("Base64 length: ${base64Image.length}");

      final bodyAnalysisProvider = Provider.of<BodyAnalysisProvider>(context, listen: false);
      final analysis = await bodyAnalysisProvider.analyzeBodyImage(dataUrl);
      if (analysis == null ||
          analysis.gender == null ||
          analysis.skinColor == null ||
          analysis.bodyType == null ||
          analysis.heightCm == null ||
          analysis.widthCm == null ||
          analysis.heightCm == 0 ||
          analysis.widthCm == 0) {

        Fluttertoast.showToast(
          msg: "No valid person detected in the image",
          backgroundColor: Colors.red,
        );
        return;
      }
      if (analysis != null) {
        setState(() {
          result = {
            'gender': analysis.gender,
            'skin_color': analysis.skinColor,
            'body_type': analysis.bodyType,
            'height_cm': analysis.heightCm,
            'width_cm': analysis.widthCm,
          };
        });
        Fluttertoast.showToast(
          msg: "Analysis Complete",
          backgroundColor: const Color(0xFF8E2DE2),
        );
      }
    } catch (e) {
      print("Error analyzing image: $e");
      Fluttertoast.showToast(
        msg: "Failed to analyze image",
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Result card widget
  Widget buildResultCard(String title, String value, {IconData? icon}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E2DE2), Color(0xFFEC008C)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
            if (icon != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8E2DE2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F0FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            const Text(
              "AI Body Measurement",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8E2DE2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Upload your photo for personalized fashion advice",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            /// IMAGE SELECTOR
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8E2DE2), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8E2DE2).withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _imageFile == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8E2DE2), Color(0xFFEC008C)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Tap to select image",
                      style: TextStyle(
                        color: Color(0xFF8E2DE2),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Choose a full-body photo for best results",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Image.file(
                        _imageFile!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => setState(() => _imageFile = null),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ANALYZE BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : analyzeImage,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: EdgeInsets.zero,
                  elevation: 5,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFFEC008C)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          "Analyze with AI",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// RESULT DISPLAY
            if (result != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8E2DE2).withOpacity(0.1),
                      const Color(0xFFEC008C).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF8E2DE2), size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Analysis Complete!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8E2DE2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              buildResultCard("Gender", result!["gender"] ?? "-", icon: Icons.person),
              const SizedBox(height: 12),
              buildResultCard("Skin Color", result!["skin_color"] ?? "-", icon: Icons.color_lens),
              const SizedBox(height: 12),
              buildResultCard("Body Type", result!["body_type"] ?? "-", icon: Icons.accessibility_new),
              const SizedBox(height: 12),
              buildResultCard("Height (cm)", result!["height_cm"]?.toString() ?? "-", icon: Icons.height),
              const SizedBox(height: 12),
              buildResultCard("Width (cm)", result!["width_cm"]?.toString() ?? "-", icon: Icons.swap_horiz),
              const SizedBox(height: 24),

              /// FASHION TIPS CTA BOX
              /// FASHION TIPS BUTTON
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FashionTipsPage(
                        gender: result!["gender"] ?? "female",
                        skinColor: result!["skin_color"] ?? "medium",
                        bodyType: result!["body_type"] ?? "rectangle",
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFFEC008C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8E2DE2).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lightbulb,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Get Fashion Tips",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              result!["gender"] == "male" ? "Style guide for you, Sir 👔" : "Style guide for you, Miss 👗",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// ✅ NEW: READY TO SHOP BUTTON
              GestureDetector(
                onTap: () => _navigateToRecommendedShop(context),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ready to Shop",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Find clothes that match your body",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToRecommendedShop(BuildContext context) {
    if (result == null) {
      Fluttertoast.showToast(
        msg: "Please analyze your body first!",
        backgroundColor: Colors.orange,
      );
      return;
    }

    // Navigate to Recommended Shop page
    Navigator.pushNamed(
      context,
      '/shop-recommendations',
      arguments: {
        'genderType': result!['gender']?.toUpperCase() ?? 'FEMALE',
        'bodyType': result!['body_type']?.toUpperCase() ?? 'RECTANGLE',
        'skinTone': result!['skin_color'] ?? 'medium',
      },
    );
  }
}