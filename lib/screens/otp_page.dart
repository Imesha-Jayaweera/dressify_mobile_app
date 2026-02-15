import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'shopping_center_dashboard.dart';

class OtpPage extends StatefulWidget {
  final String email;
  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  void verifyOtp() async {
    final otpCode = otpController.text.trim();

    if (otpCode.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter OTP code");
      return;
    }

    setState(() => isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // ✅ Pass 'code' parameter to match backend
      await authProvider.verifyOtp(widget.email, otpCode);

      Fluttertoast.showToast(
        msg: "Email verified successfully",
        backgroundColor: Colors.green,
      );

      // ✅ Role-based navigation
      final userType = authProvider.userType;

      if (!mounted) return;

      if (userType == 'SHOPPING_CENTER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ShoppingCenterDashboard(),
          ),
        );
      } else if (userType == 'TAILOR') {
        Navigator.pushReplacementNamed(context, '/tailor-dashboard');
      } else {
        // CUSTOMER
        Navigator.pushReplacementNamed(context, '/ai-image-analysis');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Invalid OTP code. Please try again.",
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF8E2DE2).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 60,
                  color: Color(0xFF8E2DE2),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Verify Email",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB23BC7),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Enter the 4-digit code sent to",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                widget.email,
                style: const TextStyle(
                  color: Color(0xFF8E2DE2),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 40),

              // OTP Input Field
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  letterSpacing: 16,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "0000",
                  hintStyle: TextStyle(
                    color: Colors.grey[300],
                    letterSpacing: 16,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF8E2DE2),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : verifyOtp,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8E2DE2),
                          Color(0xFFEC008C),
                        ],
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
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text(
                        "Verify OTP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend OTP option (optional)
              TextButton(
                onPressed: () {
                  // TODO: Implement resend OTP functionality
                  Fluttertoast.showToast(msg: "Resend OTP feature coming soon");
                },
                child: const Text(
                  "Didn't receive code? Resend",
                  style: TextStyle(
                    color: Color(0xFF8E2DE2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }
}