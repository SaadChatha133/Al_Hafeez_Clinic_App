import 'package:flutter/material.dart';
import 'appointment_models.dart';

class AppointmentMessageBox extends StatelessWidget {
  final String message;
  final bool isError;

  const AppointmentMessageBox({
    super.key,
    required this.message,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isError ? const Color(0xFFFFE5E5) : const Color(0xFFE5FFF7);
    final borderColor =
        isError ? const Color(0xFFD64545) : const Color(0xFF2C8C84);
    final textColor =
        isError ? const Color(0xFF9F1D1D) : const Color(0xFF0F5F5A);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: borderColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyAppointmentCard extends StatelessWidget {
  final AppointmentBooking booking;
  final VoidCallback onCancel;

  const MyAppointmentCard({
    super.key,
    required this.booking,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.memberName.isEmpty ? 'Family Member' : booking.memberName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F5F5A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatDate(booking.startTime),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F5F5A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatTimeRange(booking.startTime, booking.endTime),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF275E59),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFC65D5D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Cancel Appointment',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorAppointmentCard extends StatelessWidget {
  final AppointmentBooking booking;

  const DoctorAppointmentCard({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.userEmail,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F5F5A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            booking.memberName.isEmpty ? 'Family Member' : booking.memberName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF275E59),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatDate(booking.startTime),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF275E59),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatTimeRange(booking.startTime, booking.endTime),
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF275E59),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  final String text;

  const EmptyStateCard({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.45),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF275E59),
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }
}

String formatDate(DateTime date) {
  const weekdays = [
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${weekdays[date.weekday]}, ${date.day} ${months[date.month]} ${date.year}';
}

String formatTime(DateTime time) {
  int hour = time.hour;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';

  hour = hour % 12;
  if (hour == 0) hour = 12;

  return '$hour:$minute $period';
}

String formatTimeRange(DateTime start, DateTime end) {
  return '${formatTime(start)} - ${formatTime(end)}';
}