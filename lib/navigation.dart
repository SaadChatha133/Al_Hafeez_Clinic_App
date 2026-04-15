import 'dart:ui';
import 'package:flutter/material.dart';
import 'views/account_page.dart';
import 'views/appointments/appointments_page.dart';
import 'views/profileoptions/profile_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    AccountPage(),
    AppointmentsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pages[selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.30),
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
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                indicatorColor: const Color(0xFF0F766E).withOpacity(0.18),
                selectedIndex: selectedIndex,
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined, color: Color(0xFF275E59)),
                    selectedIcon:
                        Icon(Icons.home_rounded, color: Color(0xFF0F766E)),
                    label: 'Account',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.calendar_month_outlined,
                      color: Color(0xFF275E59),
                    ),
                    selectedIcon: Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF0F766E),
                    ),
                    label: 'Appointments',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline, color: Color(0xFF275E59)),
                    selectedIcon:
                        Icon(Icons.person, color: Color(0xFF0F766E)),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}