import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AIImageAnalyzerPage extends StatefulWidget {
  const AIImageAnalyzerPage({super.key});

  @override
  State<AIImageAnalyzerPage> createState() => _AIImageAnalyzerPageState();
}

class _AIImageAnalyzerPageState extends State<AIImageAnalyzerPage> {
  File? _selectedImage;
  Map<String, dynamic>? _aiResult;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _aiResult = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _loading = true);

    final uri = Uri.parse('http://localhost:3000/ai/analyze');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        setState(() { _aiResult = json.decode(respStr); });
      } else {
        final error = json.decode(respStr);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error['message'] ?? 'AI analysis failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Image Analyzer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.purple.shade50,
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
                    : const Center(
                  child: Text('Tap to select an image', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loading ? null : _analyzeImage,
              icon: const Icon(Icons.analytics),
              label: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Analyze Image'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 20),
            _aiResult != null
                ? Expanded(
              child: SingleChildScrollView(
                child: Text(
                  jsonEncode(_aiResult),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
