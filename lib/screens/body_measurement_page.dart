import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/body_analysis_provider.dart';
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

  /// Pick image from gallery
  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  /// Send image to backend for analysis
  Future<void> analyzeImage() async {
    if (_imageFile == null) {
      Fluttertoast.showToast(msg: "Please select an image first");
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
      print("First 50 chars of base64: ${base64Image.substring(0, 50)}");

      // Call your ApiService
      final bodyAnalysisProvider = Provider.of<BodyAnalysisProvider>(context, listen: false);
      final analysis = await bodyAnalysisProvider.analyzeBodyImage(dataUrl);
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
      }
      Fluttertoast.showToast(msg: "Analysis complete");
    } catch (e) {
      print("Error analyzing image: $e");
      Fluttertoast.showToast(msg: "Failed to analyze image: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Result card widget
  Widget buildResultCard(String title, String value, {IconData? icon}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (icon != null) Icon(icon, size: 28, color: Colors.deepPurple),
            if (icon != null) const SizedBox(width: 12),
            Expanded(
              child: Text(
                "$title: $value",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Body Measurement"),
        backgroundColor: const Color(0xFF8E2DE2),
      ),
      backgroundColor: const Color(0xFFF6F0FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            /// IMAGE SELECTOR - FIXED TO SHOW FULL IMAGE
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 300, // Increased height
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepPurple, width: 2),
                ),
                child: _imageFile == null
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 64, color: Colors.deepPurple),
                      SizedBox(height: 8),
                      Text(
                        "Tap to select image",
                        style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _imageFile!,
                    fit: BoxFit.contain, // Shows full image without cropping
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ANALYZE BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : analyzeImage,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: EdgeInsets.zero,
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
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Analyze",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// RESULT DISPLAY
            if (result != null) ...[
              buildResultCard("Gender", result!["gender"] ?? "-", icon: Icons.male),
              buildResultCard("Skin Color", result!["skin_color"] ?? "-", icon: Icons.color_lens),
              buildResultCard("Body Type", result!["body_type"] ?? "-", icon: Icons.accessibility_new),
              buildResultCard("Height (cm)", result!["height_cm"]?.toString() ?? "-", icon: Icons.height),
              buildResultCard("Width (cm)", result!["width_cm"]?.toString() ?? "-", icon: Icons.swap_horiz),
              const SizedBox(height: 20),

              const SizedBox(height: 10),

              /// FASHION TIPS CTA BOX
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
                        color: const Color(0xFF8E2DE2).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          result!["gender"] == "male"
                              ? "Hello Sir! 👔"
                              : "Hello Miss! 👗",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Would you like to dress fashionably\nwith your body shape?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Get Your Style Tips",
                                style: TextStyle(
                                  color: Color(0xFF8E2DE2),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Color(0xFF8E2DE2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
