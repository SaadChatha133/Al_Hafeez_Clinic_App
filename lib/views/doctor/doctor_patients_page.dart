import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'doctor_user_family_page.dart';

class DoctorPatientsPage extends StatefulWidget {
  const DoctorPatientsPage({super.key});

  @override
  State<DoctorPatientsPage> createState() => _DoctorPatientsPageState();
}

class _DoctorPatientsPageState extends State<DoctorPatientsPage> {
  final TextEditingController searchController = TextEditingController();

  String searchText = '';

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {
        searchText = searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void openUserFamilyPage({
    required String userId,
    required String username,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorUserFamilyPage(
          userId: userId,
          username: username,
        ),
      ),
    );
  }

  Widget buildUserCard({
    required String userId,
    required String username,
  }) {
    return GestureDetector(
      onTap: () => openUserFamilyPage(
        userId: userId,
        username: username,
      ),
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
              child: Text(
                username,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F5F5A),
                ),
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

  InputDecoration searchDecoration() {
    return InputDecoration(
      hintText: 'Search username',
      hintStyle: const TextStyle(color: Color(0xFF6B8F8B)),
      prefixIcon: const Icon(
        Icons.search_rounded,
        color: Color(0xFF0F766E),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.45),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.45),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF0F766E),
          width: 1.4,
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
                              Icons.people_alt_rounded,
                              size: 54,
                              color: Color(0xFF0F766E),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Patients',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F5F5A),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Search and open patient family records.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Color(0xFF275E59),
                              ),
                            ),
                            const SizedBox(height: 18),
                            TextField(
                              controller: searchController,
                              decoration: searchDecoration(),
                              style: const TextStyle(
                                color: Color(0xFF184E4A),
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
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0F766E),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Could not load patients.',
                              style: TextStyle(
                                color: Color(0xFF275E59),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];

                        final filteredDocs = docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final username =
                              (data['username'] ?? 'User').toString();
                          return username.toLowerCase().contains(searchText);
                        }).toList();

                        filteredDocs.sort((a, b) {
                          final aData = a.data() as Map<String, dynamic>;
                          final bData = b.data() as Map<String, dynamic>;
                          final aName =
                              (aData['username'] ?? 'User').toString();
                          final bName =
                              (bData['username'] ?? 'User').toString();

                          return aName
                              .toLowerCase()
                              .compareTo(bName.toLowerCase());
                        });

                        if (filteredDocs.isEmpty) {
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
                              'No patients found.',
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
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final doc = filteredDocs[index];
                            final data =
                                doc.data() as Map<String, dynamic>;

                            final username =
                                (data['username'] ?? 'User').toString();

                            return buildUserCard(
                              userId: doc.id,
                              username: username,
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