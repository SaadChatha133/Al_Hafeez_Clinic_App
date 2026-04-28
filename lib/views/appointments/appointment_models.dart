import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentBooking {
  final String id;
  final String userId;
  final String userEmail;
  final String memberId;
  final String memberName;
  final DateTime? memberDateOfBirth;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  AppointmentBooking({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.memberId,
    required this.memberName,
    required this.memberDateOfBirth,
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
      memberId: data['memberId'] ?? '',
      memberName: data['memberName'] ?? '',
      memberDateOfBirth: data['memberDateOfBirth'] != null
          ? (data['memberDateOfBirth'] as Timestamp).toDate()
          : null,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'booked',
    );
  }
}