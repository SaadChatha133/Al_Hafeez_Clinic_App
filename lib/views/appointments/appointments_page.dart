import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'appointment_models.dart';
import 'appointments_service.dart';
import 'appointments_widgets.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final AppointmentsService appointmentsService = AppointmentsService();

  String? pageMessage;
  bool isErrorMessage = false;
  Timer? refreshTimer;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    if (now.weekday == DateTime.friday) {
      selectedDate = now.add(const Duration(days: 1));
    }

    refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  void showPageMessage(String message, {bool isError = false}) {
    setState(() {
      pageMessage = message;
      isErrorMessage = isError;
    });
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year + 5, 12, 31);

    DateTime initialDate = selectedDate;
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }
    if (initialDate.weekday == DateTime.friday) {
      initialDate = initialDate.add(const Duration(days: 1));
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (day) {
        return day.weekday != DateTime.friday;
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  List<DateTime> getAvailableClinicTimesForDate(DateTime date) {
    if (date.weekday == DateTime.friday) {
      return [];
    }

    final now = DateTime.now();
    final slots = <DateTime>[];

    void addSessionSlots(DateTime start, DateTime end) {
      DateTime current = start;

      while (current.isBefore(end)) {
        final next = current.add(const Duration(minutes: 20));

        if (next.isAfter(end)) {
          break;
        }

        if (current.isAfter(now)) {
          slots.add(current);
        }

        current = next;
      }
    }

    addSessionSlots(
      DateTime(date.year, date.month, date.day, 8, 0),
      DateTime(date.year, date.month, date.day, 15, 0),
    );

    addSessionSlots(
      DateTime(date.year, date.month, date.day, 18, 0),
      DateTime(date.year, date.month, date.day).add(
        const Duration(days: 1, hours: 2),
      ),
    );

    return slots;
  }

  Future<void> showAvailableTimesPopup(Set<String> bookedSlotKeys) async {
    final allClinicTimes = getAvailableClinicTimesForDate(selectedDate);

    final availableTimes = allClinicTimes.where((time) {
      final key = appointmentsService.slotKeyFromDateTime(time);
      return !bookedSlotKeys.contains(key);
    }).toList();

    if (availableTimes.isEmpty) {
      showPageMessage(
        'No available time slots for the selected date.',
        isError: true,
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Available Times'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: availableTimes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final startTime = availableTimes[index];
                final endTime = startTime.add(const Duration(minutes: 20));

                return ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await handleBook(startTime, endTime);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(formatTimeRange(startTime, endTime)),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> handleBook(DateTime startTime, DateTime endTime) async {
    try {
      await appointmentsService.bookAppointment(
        startTime: startTime,
        endTime: endTime,
      );

      showPageMessage(
        'Appointment booked successfully.',
        isError: false,
      );
    } on FirebaseException catch (e) {
      String message = 'Could not book appointment. Please try again.';

      if (e.code == 'slot-already-booked') {
        message =
            'This time slot was just booked by someone else. Please choose another slot.';
      }

      showPageMessage(message, isError: true);
    } catch (e) {
      showPageMessage(
        'Could not book appointment. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> handleCancel(AppointmentBooking booking) async {
    try {
      await appointmentsService.cancelAppointment(booking);

      showPageMessage(
        'Appointment cancelled successfully.',
        isError: false,
      );
    } on FirebaseException catch (e) {
      String message = 'Could not cancel appointment. Please try again.';

      if (e.code == 'appointment-not-found') {
        message = 'This appointment no longer exists.';
      } else if (e.code == 'not-allowed') {
        message = 'You can only cancel your own appointments.';
      }

      showPageMessage(message, isError: true);
    } catch (e) {
      showPageMessage(
        'Could not cancel appointment. Please try again.',
        isError: true,
      );
    }
  }

  Widget buildScheduleCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.40),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinic Schedule',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F5F5A),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Monday, Tuesday, Wednesday, Thursday, Saturday, Sunday',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF275E59),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '8:00 AM to 3:00 PM',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF275E59),
                ),
              ),
              SizedBox(height: 6),
              Text(
                '6:00 PM to 2:00 AM',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF275E59),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBookAppointmentSection() {
    return StreamBuilder<Set<String>>(
      stream: appointmentsService.bookedSlotKeysForDateStream(selectedDate),
      builder: (context, snapshot) {
        final bookedSlotKeys = snapshot.data ?? <String>{};

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F5F5A),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: pickDate,
                      icon: const Icon(Icons.calendar_today_rounded),
                      label: Text(formatDate(selectedDate)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F766E),
                        side: const BorderSide(
                          color: Color(0xFF0F766E),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: snapshot.connectionState == ConnectionState.waiting
                          ? null
                          : () => showAvailableTimesPopup(bookedSlotKeys),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Choose Time',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildMyAppointmentsSection() {
    return StreamBuilder<List<AppointmentBooking>>(
      stream: appointmentsService.myAppointmentsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
            text: 'Could not load your appointments right now.',
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
            text: 'You do not have any booked appointments yet.',
          );
        }

        return Column(
          children: appointments
              .map(
                (booking) => MyAppointmentCard(
                  booking: booking,
                  onCancel: () => handleCancel(booking),
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
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
                        child: const Column(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 50,
                              color: Color(0xFF0F766E),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Appointments',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F5F5A),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Book and manage your clinic appointments here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Color(0xFF275E59),
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
                      isError: isErrorMessage,
                    ),
                  buildScheduleCard(),
                  const SizedBox(height: 18),
                  buildBookAppointmentSection(),
                  const SizedBox(height: 24),
                  const Text(
                    'My Appointments',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F5F5A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildMyAppointmentsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}