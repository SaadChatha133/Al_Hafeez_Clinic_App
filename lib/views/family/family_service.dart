import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'family_member_model.dart';

class FamilyService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Stream<List<FamilyMember>> myFamilyMembersStream() {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return firestore
        .collection('family_members')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final members =
          snapshot.docs.map((doc) => FamilyMember.fromDoc(doc)).toList();

      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      return members;
    });
  }

  Future<void> addFamilyMember({
    required String name,
    DateTime? dateOfBirth,
  }) async {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-logged-in',
        message: 'You must be logged in.',
      );
    }

    await firestore.collection('family_members').add({
      'userId': user.uid,
      'name': name.trim(),
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth) : null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFamilyMemberDateOfBirth({
    required String memberId,
    DateTime? dateOfBirth,
  }) async {
    await firestore.collection('family_members').doc(memberId).update({
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth) : null,
    });
  }

  Future<void> deleteFamilyMember({
    required String memberId,
  }) async {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-logged-in',
        message: 'You must be logged in.',
      );
    }

    final memberRef = firestore.collection('family_members').doc(memberId);
    final memberDoc = await memberRef.get();

    if (!memberDoc.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Family member not found.',
      );
    }

    final data = memberDoc.data() as Map<String, dynamic>;

    if (data['userId'] != user.uid) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-allowed',
        message: 'You can only delete your own family members.',
      );
    }

    await _deleteMemberReports(memberId: memberId, userId: user.uid);
    await _deleteMemberAppointments(memberId: memberId, userId: user.uid);
    await memberRef.delete();
  }

  Future<void> _deleteMemberAppointments({
    required String memberId,
    required String userId,
  }) async {
    while (true) {
      final snapshot = await firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .where('memberId', isEqualTo: memberId)
          .limit(400)
          .get();

      if (snapshot.docs.isEmpty) break;

      final batch = firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (snapshot.docs.length < 400) break;
    }
  }

  Future<void> _deleteMemberReports({
    required String memberId,
    required String userId,
  }) async {
    while (true) {
      final snapshot = await firestore
          .collection('family_members')
          .doc(memberId)
          .collection('reports')
          .limit(400)
          .get();

      if (snapshot.docs.isEmpty) break;

      final batch = firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (snapshot.docs.length < 400) break;
    }

    try {
      final folderRef = storage.ref().child('reports/$userId/$memberId');
      final listResult = await folderRef.listAll();

      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (_) {}
  }

  int? calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return null;

    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;

    final hasHadBirthdayThisYear = today.month > dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day >= dateOfBirth.day);

    if (!hasHadBirthdayThisYear) {
      age--;
    }

    return age;
  }
}