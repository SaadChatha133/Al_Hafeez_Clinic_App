import 'dart:ui';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'doctor/doctor_login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget glassButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = const Color(0xFF0F766E),
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
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
            top: -70,
            right: -45,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.28),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -55,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                color: const Color(0xFF4DB6AC).withOpacity(0.20),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.30),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.45),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 22,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.38),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_hospital_rounded,
                              size: 58,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Al-Hafeez Clinic',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F5F5A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Your health matters. Book appointments and manage your family care with ease.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.5,
                              height: 1.5,
                              color: Color(0xFF275E59),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 28),
                          glassButton(
                            text: 'Login',
                            icon: Icons.login_rounded,
                            onPressed: () =>
                                navigate(context, const LoginPage()),
                          ),
                          const SizedBox(height: 14),
                          glassButton(
                            text: 'Register',
                            icon: Icons.app_registration_rounded,
                            backgroundColor: const Color(0xFF2C8C84),
                            onPressed: () =>
                                navigate(context, const RegisterPage()),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  navigate(context, const DoctorLoginPage()),
                              icon: const Icon(Icons.medical_services_rounded),
                              label: const Text(
                                'Doctor',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0F766E),
                                side: const BorderSide(
                                  color: Color(0xFF0F766E),
                                  width: 1.3,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor:
                                    Colors.white.withOpacity(0.18),
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
          ),
        ],
      ),
    );
  }
}