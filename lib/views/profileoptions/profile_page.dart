import 'dart:ui';
import 'package:flutter/material.dart';
import '../../auth_service.dart';
import '../home_page.dart';
import 'reset_password_page.dart';
import 'delete_account_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, a, b) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> signOut(BuildContext context) async {
    await authService.value.signOut();

    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
      (route) => false,
    );
  }

  Widget themedButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = const Color(0xFF0F766E),
    Color foregroundColor = Colors.white,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username =
        authService.value.currentUser?.displayName?.trim().isNotEmpty == true
            ? authService.value.currentUser!.displayName!
            : 'User';

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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
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
                          Icons.person_rounded,
                          size: 50,
                          color: Color(0xFF0F766E),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F5F5A),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.38),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.45),
                            ),
                          ),
                          child: Text(
                            username,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F5F5A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        themedButton(
                          text: "Reset Password",
                          icon: Icons.lock_reset_rounded,
                          onPressed: () => navigate(
                            context,
                            const ResetPasswordPage(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        themedButton(
                          text: "Delete Account",
                          icon: Icons.delete_forever_rounded,
                          backgroundColor: const Color(0xFFC65D5D),
                          onPressed: () => navigate(
                            context,
                            const DeleteAccountPage(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        themedButton(
                          text: "Sign Out",
                          icon: Icons.logout_rounded,
                          backgroundColor: const Color(0xFF2C8C84),
                          onPressed: () => signOut(context),
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