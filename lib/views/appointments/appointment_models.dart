import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentBooking {
  final String id;
  final String userId;
  final String userEmail;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  AppointmentBooking({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory AppointmentBooking.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AppointmentBooking(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'booked',
    );
  }
}