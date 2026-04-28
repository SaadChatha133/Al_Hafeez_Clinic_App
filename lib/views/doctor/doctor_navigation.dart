import 'dart:ui';
import 'package:flutter/material.dart';
import 'doctor_page.dart';
import 'doctor_patients_page.dart';

class DoctorNavigationPage extends StatefulWidget {
  const DoctorNavigationPage({super.key});

  @override
  State<DoctorNavigationPage> createState() => _DoctorNavigationPageState();
}

class _DoctorNavigationPageState extends State<DoctorNavigationPage> {
  int selectedIndex = 0;

  final pages = const [
    DoctorPage(),
    DoctorPatientsPage(),
  ];

  final items = const [
    _DoctorNavItem(
      icon: Icons.calendar_month_rounded,
      label: 'Appointments',
    ),
    _DoctorNavItem(
      icon: Icons.people_alt_rounded,
      label: 'Patients',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pages[selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: 76,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.42),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.55),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = selectedIndex == index;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0F766E)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF0F766E)
                                          .withOpacity(0.28),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item.icon,
                                size: 23,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF0F5F5A),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                                child: isSelected
                                    ? Row(
                                        children: [
                                          const SizedBox(width: 7),
                                          Text(
                                            item.label,
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DoctorNavItem {
  final IconData icon;
  final String label;

  const _DoctorNavItem({
    required this.icon,
    required this.label,
  });
}