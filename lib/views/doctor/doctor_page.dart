import 'dart:ui';
import 'package:flutter/material.dart';
import '../../auth_service.dart';
import '../appointments/appointment_models.dart';
import '../appointments/appointments_service.dart';
import '../appointments/appointments_widgets.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final AppointmentsService appointmentsService = AppointmentsService();

  bool isCleaning = true;
  String? pageMessage;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    cleanOldAppointments();
  }

  Future<void> cleanOldAppointments() async {
    setState(() {
      isCleaning = true;
      pageMessage = null;
      isError = false;
    });

    try {
      final deletedCount =
          await appointmentsService.deleteOldAppointmentsAutomatically();

      if (!mounted) return;

      setState(() {
        pageMessage =
            'Doctor view updated. $deletedCount old appointments were removed automatically.';
        isError = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        pageMessage = 'Could not clean old appointments automatically.';
        isError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          isCleaning = false;
        });
      }
    }
  }

  Future<void> signOutDoctor() async {
    await authService.value.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget buildAppointmentsList() {
    return StreamBuilder<List<AppointmentBooking>>(
      stream: appointmentsService.allAppointmentsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && isCleaning) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: CircularProgressIndicator(
                color: Color(0xFF0F766E),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const EmptyStateCard(
            text: 'Could not load doctor appointments right now.',
          );
        }

        final now = DateTime.now();
        final appointments = (snapshot.data ?? [])
            .where(
              (booking) => booking.endTime.isAfter(
                now.subtract(const Duration(seconds: 1)),
              ),
            )
            .toList();

        if (appointments.isEmpty) {
          return const EmptyStateCard(
            text: 'There are no current appointments in the database.',
          );
        }

        return Column(
          children: appointments
              .map(
                (booking) => DoctorAppointmentCard(
                  booking: booking,
                ),
              )
              .toList(),
        );
      },
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
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
                              Icons.monitor_heart_rounded,
                              size: 50,
                              color: Color(0xFF0F766E),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Doctor Admin',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F5F5A),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'This page shows all current booked appointments and automatically removes old past appointments when opened.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Color(0xFF275E59),
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: signOutDoctor,
                                icon: const Icon(Icons.logout_rounded),
                                label: const Text('Sign Out'),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: const Color(0xFF2C8C84),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (pageMessage != null)
                    AppointmentMessageBox(
                      message: pageMessage!,
                      isError: isError,
                    ),
                  const SizedBox(height: 6),
                  const Text(
                    'All Current Appointments',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F5F5A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildAppointmentsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}