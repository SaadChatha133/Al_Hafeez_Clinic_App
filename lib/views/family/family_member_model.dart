import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyMember {
  final String id;
  final String userId;
  final String name;
  final DateTime? dateOfBirth;

  FamilyMember({
    required this.id,
    required this.userId,
    required this.name,
    required this.dateOfBirth,
  });

  factory FamilyMember.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FamilyMember(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      dateOfBirth: data['dateOfBirth'] != null
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
    );
  }
}