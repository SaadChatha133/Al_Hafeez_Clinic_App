import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../navigation.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? errorMessage;

  void showError(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  bool isValidEmail(String email) {
    return email.contains('@') && email.contains('.com');
  }

  Future<void> registerUser() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    setState(() {
      errorMessage = null;
    });

    if (username.isEmpty) {
      showError('Please enter a username.');
      return;
    }

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showError('Please fill all fields before registering.');
      return;
    }

    if (!isValidEmail(email)) {
      showError('Invalid email format. Please enter an email with @ and .com');
      return;
    }

    if (password != confirmPassword) {
      showError('Passwords do not match. Please enter the same password.');
      return;
    }

    if (password.length < 6) {
      showError('Password must be at least 6 characters long.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.value.createAccount(
        email: email,
        password: password,
      );

      await authService.value.updateUsername(
        username: username,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const NavigationPage(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Could not register. Please try again.';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      }

      showError(message);
    } catch (e) {
      showError('Could not register. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildErrorBox() {
    if (errorMessage == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5E5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD64545)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFD64545),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Color(0xFF9F1D1D),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration inputDecoration({
    required String label,
    required bool isPassword,
    required bool obscureText,
    VoidCallback? onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF3B6E69)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.45),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.45)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.4),
      ),
      suffixIcon: isPassword
          ? IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF3B6E69),
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8FFFB),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE8FFFB),
                  Color(0xFFCFF7F0),
                  Color(0xFF9FE3D8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF4DB6AC).withOpacity(0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.45),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.app_registration_rounded,
                          size: 50,
                          color: Color(0xFF0F766E),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F5F5A),
                          ),
                        ),
                        const SizedBox(height: 22),
                        buildErrorBox(),
                        TextField(
                          controller: usernameController,
                          style: const TextStyle(color: Color(0xFF184E4A)),
                          decoration: inputDecoration(
                            label: 'Username',
                            isPassword: false,
                            obscureText: false,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Color(0xFF184E4A)),
                          decoration: inputDecoration(
                            label: 'Email',
                            isPassword: false,
                            obscureText: false,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          style: const TextStyle(color: Color(0xFF184E4A)),
                          decoration: inputDecoration(
                            label: 'Password',
                            isPassword: true,
                            obscureText: obscurePassword,
                            onToggle: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirmPassword,
                          style: const TextStyle(color: Color(0xFF184E4A)),
                          decoration: inputDecoration(
                            label: 'Confirm Password',
                            isPassword: true,
                            obscureText: obscureConfirmPassword,
                            onToggle: () {
                              setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 25),
                        isLoading
                            ? const CircularProgressIndicator(
                                color: Color(0xFF0F766E),
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: registerUser,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: const Color(0xFF0F766E),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}