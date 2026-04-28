import 'dart:ui';
import 'package:flutter/material.dart';
import 'family/add_family_member_page.dart';
import 'family/family_member_detail_page.dart';
import 'family/family_member_model.dart';
import 'family/family_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FamilyService familyService = FamilyService();

  String? pageMessage;
  bool isError = false;

  void showPageMessage(String message, {bool error = false}) {
    setState(() {
      pageMessage = message;
      isError = error;
    });
  }

  Future<void> openAddMemberPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddFamilyMemberPage(),
      ),
    );
  }

  Future<void> openMemberDetail(FamilyMember member) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FamilyMemberDetailPage(member: member),
      ),
    );
  }

  Future<void> deleteMember(FamilyMember member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Family Member'),
          content: Text(
            'Are you sure you want to delete ${member.name}? This will also remove their appointments and reports.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFC65D5D)),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await familyService.deleteFamilyMember(memberId: member.id);

      if (!mounted) return;

      showPageMessage(
        '${member.name} was deleted successfully.',
        error: false,
      );
    } catch (e) {
      if (!mounted) return;

      showPageMessage(
        'Could not delete family member.',
        error: true,
      );
    }
  }

  Widget buildMessageBox() {
    if (pageMessage == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFE5E5) : const Color(0xFFE5FFF7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isError ? const Color(0xFFD64545) : const Color(0xFF2C8C84),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? const Color(0xFFD64545) : const Color(0xFF2C8C84),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pageMessage!,
              style: TextStyle(
                color: isError ? const Color(0xFF9F1D1D) : const Color(0xFF0F5F5A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFamilyMemberCard(FamilyMember member) {
    final age = familyService.calculateAge(member.dateOfBirth);
    final ageText = age == null ? 'NA' : '$age years';

    return GestureDetector(
      onTap: () => openMemberDetail(member),
      onLongPress: () => deleteMember(member),
      child: Container(
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
            child: Padding(
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
                        child: Column(
                          children: [
                            const Icon(
                              Icons.family_restroom_rounded,
                              size: 52,
                              color: Color(0xFF0F766E),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Family Members',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F5F5A),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Add and manage family members linked to your account.',
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
                                onPressed: openAddMemberPage,
                                icon: const Icon(Icons.person_add_alt_1_rounded),
                                label: const Text(
                                  'Add Member',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: const Color(0xFF0F766E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
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
                  buildMessageBox(),
                  const Text(
                    'Your Family',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F5F5A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<List<FamilyMember>>(
                      stream: familyService.myFamilyMembersStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0F766E),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
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
                              'Could not load family members right now.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF275E59),
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          );
                        }

                        final members = snapshot.data ?? [];

                        if (members.isEmpty) {
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
                              'No family members added yet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF275E59),
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            return buildFamilyMemberCard(members[index]);
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