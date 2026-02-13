import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'otp_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  int selectedRole = 0; // 0 = Customer, 1 = Shopping Center, 2 = Tailor

  void signIn() async {
    setState(() => isLoading = true);

    try {
      final res = await ApiService.signIn({
        "email": emailController.text,
        "password": passwordController.text,
      });

      if (res["verificationRequired"] == true) {
        Fluttertoast.showToast(msg: "OTP sent to your email");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpPage(email: emailController.text),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: "Login successful");
        Navigator.pushReplacementNamed(context, '/ai-image-analysis');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Login failed");
    } finally {
      setState(() => isLoading = false);
    }
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
              const SizedBox(height: 50),

              /// App Title
              const Text(
                "Dressify",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB23BC7),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "AI-Powered Virtual Tailoring & Shopping",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 40),

              /// Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Sign in to your account",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    /// Role Selector
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: List.generate(3, (index) {
                          final titles = ["Customer", "Shoping Center", "Tailor"];
                          final icons = [
                            Icons.person_outline,
                            Icons.store_outlined,
                            Icons.content_cut_outlined
                          ];

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => selectedRole = index);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: selectedRole == index
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      icons[index],
                                      color: Colors.black87,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      titles[index],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Email
                    const Text("Email"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "customer@example.com",
                        filled: true,
                        fillColor: const Color(0xFFF4F4F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Password
                    const Text("Password"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "password",
                        filled: true,
                        fillColor: const Color(0xFFF4F4F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : signIn,
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
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              "Sign In as ${["Customer", "Shopping Center", "Tailor"][selectedRole]}",
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

              const SizedBox(height: 24),

              /// Sign up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        color: Color(0xFF8E2DE2),
                        fontWeight: FontWeight.bold,
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
