import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'otp_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final birthDateController = TextEditingController();
  final addressController = TextEditingController();

  String sex = 'MALE';
  String userType = 'CUSTOMER';
  bool isLoading = false;

  void signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await ApiService.signUp({
        "name": nameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "birthDate": birthDateController.text,
        "address": addressController.text,
        "sex": sex,
        "userType": userType,
      });

      Fluttertoast.showToast(
        msg: "OTP sent to your email",
        gravity: ToastGravity.BOTTOM,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OtpPage(email: emailController.text),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Signup failed");
    } finally {
      setState(() => isLoading = false);
    }
  }


  /// INPUT FIELD WITH PLACEHOLDER
  Widget buildInput(
      String label,
      TextEditingController controller, {
        String? hint,
        bool obscure = false,
        IconData? icon,
        bool readOnly = false,
        VoidCallback? onTap,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          readOnly: readOnly,
          onTap: onTap,
          validator: (v) => v!.isEmpty ? "Required" : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            filled: true,
            fillColor: const Color(0xFFF4F4F4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF8E2DE2),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// SEGMENTED SELECTOR
  Widget buildSelector(
      List<String> values, String selected, Function(String) onTap) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: values.map((v) {
          final isSelected = v == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(v),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    v.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB23BC7),
                ),
              ),
              const SizedBox(height: 30),

              /// CARD
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black12,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: buildInput(
                              "Name",
                              nameController,
                              hint: "John",
                              icon: Icons.person_outline,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                      const SizedBox(height: 16),

                      buildInput(
                        "Email",
                        emailController,
                        hint: "customer@example.com",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),

                      buildInput(
                        "Password",
                        passwordController,
                        hint: "••••••••",
                        obscure: true,
                        icon: Icons.lock_outline,
                      ),
                      const SizedBox(height: 16),

                      buildInput(
                        "Birth Date",
                        birthDateController,
                        hint: "YYYY-MM-DD",
                        icon: Icons.calendar_today_outlined,
                      ),
                      const SizedBox(height: 16),

                      buildInput(
                        "Address",
                        addressController,
                        hint: "No. 45, Colombo",
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 24),

                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Gender")),
                      const SizedBox(height: 8),
                      buildSelector(
                        ["MALE", "FEMALE"],
                        sex,
                            (v) => setState(() => sex = v),
                      ),

                      const SizedBox(height: 16),

                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Who Are You")),
                      const SizedBox(height: 8),
                      buildSelector(
                        ["CUSTOMER", "TAILOR", "SHOPPING_CENTER"],
                        userType,
                            (v) => setState(() => userType = v),
                      ),

                      const SizedBox(height: 30),

                      /// SIGN UP BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : signUp,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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
                                  ? const CircularProgressIndicator(
                                  color: Colors.white)
                                  : const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signin'),
                child: const Text(
                  "Already have an account? Sign in",
                  style: TextStyle(
                    color: Color(0xFF8E2DE2),
                    fontWeight: FontWeight.bold,
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
}

