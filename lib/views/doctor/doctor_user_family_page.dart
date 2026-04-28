import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../family/family_member_model.dart';
import 'doctor_family_member_record_page.dart';

class DoctorUserFamilyPage extends StatelessWidget {
  final String userId;
  final String username;

  const DoctorUserFamilyPage({
    super.key,
    required this.userId,
    required this.username,
  });

  int? calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return null;

    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;

    final hasHadBirthdayThisYear = today.month > dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day >= dateOfBirth.day);

    if (!hasHadBirthdayThisYear) age--;

    return age;
  }

  void openMemberRecord(BuildContext context, FamilyMember member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorFamilyMemberRecordPage(
          member: member,
          username: username,
        ),
      ),
    );
  }

  Widget buildMemberCard(BuildContext context, FamilyMember member) {
    final age = calculateAge(member.dateOfBirth);
    final ageText = age == null ? 'NA' : '$age years';

    return GestureDetector(
      onTap: () => openMemberRecord(context, member),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.36),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.45),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.42),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF0F766E),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F5F5A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ageText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF275E59),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF275E59),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('family_members')
        .where('userId', isEqualTo: userId)
        .snapshots();

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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
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
                              Icons.family_restroom_rounded,
                              size: 54,
                              color: Color(0xFF0F766E),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              username,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F5F5A),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Family Members',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF275E59),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: stream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0F766E),
                            ),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
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
                            child: const Text(
                              'No family members found for this patient.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF275E59),
                                fontSize: 15,
                              ),
                            ),
                          );
                        }

                        final members = docs
                            .map((doc) => FamilyMember.fromDoc(doc))
                            .toList();

                        members.sort(
                          (a, b) => a.name
                              .toLowerCase()
                              .compareTo(b.name.toLowerCase()),
                        );

                        return ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            return buildMemberCard(
                              context,
                              members[index],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}