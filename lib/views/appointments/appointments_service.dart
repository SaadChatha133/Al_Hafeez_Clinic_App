import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../family/family_member_model.dart';
import 'appointment_models.dart';

class AppointmentsService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Stream<List<AppointmentBooking>> myAppointmentsStream() {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return firestore
        .collection('appointments')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs
          .map((doc) => AppointmentBooking.fromDoc(doc))
          .where((booking) => booking.status == 'booked')
          .toList();

      bookings.sort((a, b) => a.startTime.compareTo(b.startTime));
      return bookings;
    });
  }

  Stream<List<AppointmentBooking>> allAppointmentsStream() {
    return firestore.collection('appointments').snapshots().map((snapshot) {
      final bookings = snapshot.docs
          .map((doc) => AppointmentBooking.fromDoc(doc))
          .where((booking) => booking.status == 'booked')
          .toList();

      bookings.sort((a, b) => a.startTime.compareTo(b.startTime));
      return bookings;
    });
  }

  Stream<Set<String>> bookedSlotKeysForDateStream(DateTime selectedDate) {
    final startOfDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final endOfDay = startOfDay.add(const Duration(days: 1));

    return firestore
        .collection('appointments')
        .where(
          'startTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'startTime',
          isLessThan: Timestamp.fromDate(endOfDay),
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toSet();
    });
  }

  Future<void> bookAppointment({
    required DateTime startTime,
    required DateTime endTime,
    required FamilyMember member,
  }) async {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-logged-in',
        message: 'You must be logged in to book an appointment.',
      );
    }

    final slotKey = slotKeyFromDateTime(startTime);
    final appointmentRef = firestore.collection('appointments').doc(slotKey);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(appointmentRef);

      if (snapshot.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'slot-already-booked',
          message: 'This slot has already been booked.',
        );
      }

      transaction.set(appointmentRef, {
        'userId': user.uid,
        'userEmail': user.email ?? '',
        'memberId': member.id,
        'memberName': member.name,
        'memberDateOfBirth': member.dateOfBirth != null
            ? Timestamp.fromDate(member.dateOfBirth!)
            : null,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'status': 'booked',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> cancelAppointment(AppointmentBooking booking) async {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-logged-in',
        message: 'You must be logged in to cancel an appointment.',
      );
    }

    final appointmentRef = firestore.collection('appointments').doc(booking.id);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(appointmentRef);

      if (!snapshot.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'appointment-not-found',
          message: 'This appointment was not found.',
        );
      }

      final data = snapshot.data() as Map<String, dynamic>;

      if (data['userId'] != user.uid) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-allowed',
          message: 'You can only cancel your own appointments.',
        );
      }

      transaction.delete(appointmentRef);
    });
  }

  Future<int> deleteOldAppointmentsAutomatically() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    int deletedCount = 0;

    while (true) {
      final snapshot = await firestore
          .collection('appointments')
          .where(
            'endTime',
            isLessThan: Timestamp.fromDate(startOfToday),
          )
          .limit(400)
          .get();

      if (snapshot.docs.isEmpty) {
        break;
      }

      final batch = firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
        deletedCount++;
      }

      await batch.commit();

      if (snapshot.docs.length < 400) {
        break;
      }
    }

    return deletedCount;
  }

  String slotKeyFromDateTime(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '${year}${month}${day}_${hour}${minute}';
  }
}