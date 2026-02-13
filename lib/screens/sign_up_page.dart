import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/enums.dart';
import 'otp_page.dart';
import 'package:intl/intl.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  // Common fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();

  // Customer-specific fields
  final birthDateController = TextEditingController();
  Gender selectedGender = Gender.MALE;  // ✅ Using enum

  // Business-specific fields
  final shopNameController = TextEditingController();

  // User type selection
  UserType selectedUserType = UserType.CUSTOMER;
  bool isLoading = false;

  void signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Build request data based on user type
      Map<String, dynamic> signUpData = {
        "email": emailController.text,
        "password": passwordController.text,
        "userType": selectedUserType.value,
      };

      // Add fields based on user type
      if (selectedUserType == UserType.CUSTOMER) {
        signUpData.addAll({
          "name": nameController.text,
          "birthDate": birthDateController.text,
          "address": addressController.text,
          "sex": selectedGender.value,  // ✅ Using enum value
        });
      } else {
        // TAILOR or SHOPPING_CENTER
        signUpData.addAll({
          "name": shopNameController.text, // Shop/Business name
          "shopName": nameController.text, // Business owner name
          "address": addressController.text, // Business address
        });
      }

      await authProvider.signUp(signUpData);

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
      Fluttertoast.showToast(msg: "Signup failed: $e");
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

  /// USER TYPE SELECTOR
  Widget buildUserTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: UserType.values.map((type) {
          final isSelected = type == selectedUserType;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedUserType = type;
                  // Clear fields when switching types
                  nameController.clear();
                  birthDateController.clear();
                  shopNameController.clear();
                  addressController.clear();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    type.displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  /// GENDER SELECTOR (Only for CUSTOMER) - ✅ Using Enum
  Widget buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: Gender.values.map((gender) {
          final isSelected = gender == selectedGender;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedGender = gender),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        gender.icon,
                        size: 18,
                        color: isSelected
                            ? const Color(0xFF8E2DE2)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        gender.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF8E2DE2)
                              : Colors.grey[700],
                        ),
                      ),
                    ],
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
    final isCustomer = selectedUserType == UserType.CUSTOMER;
    final isBusiness = !isCustomer;

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
                      /// USER TYPE SELECTOR (First)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Who Are You?",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      buildUserTypeSelector(),
                      const SizedBox(height: 24),

                      /// BUSINESS NAME (only for TAILOR/SHOPPING_CENTER)
                      if (isBusiness) ...[
                        buildInput(
                          "Shop/Business Name",
                          shopNameController,
                          hint: "Fashion Boutique",
                          icon: Icons.store_outlined,
                        ),
                        const SizedBox(height: 16),
                      ],

                      /// OWNER NAME / CUSTOMER NAME
                      buildInput(
                        isCustomer ? "Name" : "Business Owner Name",
                        nameController,
                        hint: isCustomer ? "John Doe" : "John Doe",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),

                      /// EMAIL
                      buildInput(
                        "Email",
                        emailController,
                        hint: "example@email.com",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),

                      /// PASSWORD
                      buildInput(
                        "Password",
                        passwordController,
                        hint: "••••••••",
                        obscure: true,
                        icon: Icons.lock_outline,
                      ),
                      const SizedBox(height: 16),

                      /// BIRTH DATE (only for CUSTOMER)
                      if (isCustomer) ...[
                        buildInput(
                          "Birth Date",
                          birthDateController,
                          hint: "Select your birth date",
                          icon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000),
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              String formattedDate =
                                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

                              setState(() {
                                birthDateController.text = formattedDate;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      /// ADDRESS
                      buildInput(
                        isCustomer ? "Address" : "Business Address",
                        addressController,
                        hint: isCustomer ? "No. 45, Colombo" : "Shop No. 12, Main Street",
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 24),

                      /// GENDER (only for CUSTOMER) - ✅ Using Enum
                      if (isCustomer) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Gender",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 8),
                        buildGenderSelector(),
                        const SizedBox(height: 24),
                      ],

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
                                  : Text(
                                "Create ${selectedUserType.displayName} Account",
                                style: const TextStyle(
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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    birthDateController.dispose();
    addressController.dispose();
    shopNameController.dispose();
    super.dispose();
  }
}