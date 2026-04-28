import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscureCurrent = true;
  bool obscureNew = true;
  String? errorMessage;

  void showError(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  Future<void> resetPassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final email = authService.value.currentUser?.email ?? '';

    setState(() {
      errorMessage = null;
    });

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    if (newPassword.length < 6) {
      showError('New password must be at least 6 characters long.');
      return;
    }

    if (email.isEmpty) {
      showError('No logged in user found.');
      return;
    }

    setState(() => isLoading = true);

    try {
      await authService.value.resetPasswordFromCurrentPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        email: email,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'Could not reset password. Please try again.';

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Current password is incorrect.';
      } else if (e.code == 'weak-password') {
        message = 'New password is too weak.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Please sign in again and try resetting your password.';
      }

      showError(message);
    } catch (e) {
      showError('Could not reset password. Please try again.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
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
          const Icon(Icons.error_outline, color: Color(0xFFD64545)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Color(0xFF9F1D1D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration inputDecoration({
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
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
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscureText ? Icons.visibility_off : Icons.visibility,
          color: const Color(0xFF3B6E69),
        ),
      ),
    );
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
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
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.lock_reset_rounded,
                          size: 50,
                          color: Color(0xFF0F766E),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F5F5A),
                          ),
                        ),
                        const SizedBox(height: 22),
                        buildErrorBox(),
                        TextField(
                          controller: currentPasswordController,
                          obscureText: obscureCurrent,
                          style: const TextStyle(color: Color(0xFF184E4A)),
                          decoration: inputDecoration(
                            label: 'Current Password',
                            obscureText: obscureCurrent,
                            onToggle: () {
                              setState(() {
                                obscureCurrent = !obscureCurrent;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: newPasswordController,
                          obscureText: obscureNew,
                          style: const TextStyle(color: Color(0xFF184E4A)),
                          decoration: inputDecoration(
                            label: 'New Password',
                            obscureText: obscureNew,
                            onToggle: () {
                              setState(() {
                                obscureNew = !obscureNew;
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
                                  onPressed: resetPassword,
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
                                    'Update Password',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
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