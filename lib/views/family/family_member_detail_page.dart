import 'dart:ui';
import 'package:flutter/material.dart';
import 'family_member_model.dart';
import 'family_service.dart';

class FamilyMemberDetailPage extends StatefulWidget {
  final FamilyMember member;

  const FamilyMemberDetailPage({
    super.key,
    required this.member,
  });

  @override
  State<FamilyMemberDetailPage> createState() => _FamilyMemberDetailPageState();
}

class _FamilyMemberDetailPageState extends State<FamilyMemberDetailPage> {
  final FamilyService familyService = FamilyService();

  bool isLoading = false;
  String? errorMessage;
  DateTime? currentDateOfBirth;

  @override
  void initState() {
    super.initState();
    currentDateOfBirth = widget.member.dateOfBirth;
  }

  void showError(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> updateDateOfBirth() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDateOfBirth ?? DateTime(now.year - 10),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await familyService.updateFamilyMemberDateOfBirth(
        memberId: widget.member.id,
        dateOfBirth: picked,
      );

      if (!mounted) return;

      setState(() {
        currentDateOfBirth = picked;
      });
    } catch (e) {
      if (!mounted) return;
      showError('Could not update date of birth.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> clearDateOfBirth() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await familyService.updateFamilyMemberDateOfBirth(
        memberId: widget.member.id,
        dateOfBirth: null,
      );

      if (!mounted) return;

      setState(() {
        currentDateOfBirth = null;
      });
    } catch (e) {
      if (!mounted) return;
      showError('Could not clear date of birth.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildErrorBox() {
    if (errorMessage == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5E5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD64545)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFD64545),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Color(0xFF9F1D1D),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final age = familyService.calculateAge(currentDateOfBirth);
    final ageText = age == null ? 'NA' : '$age years';

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
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
                          Icons.person_rounded,
                          size: 54,
                          color: Color(0xFF0F766E),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.member.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F5F5A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ageText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF275E59),
                          ),
                        ),
                        const SizedBox(height: 22),
                        buildErrorBox(),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.45),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date of Birth',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF275E59),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                currentDateOfBirth == null
                                    ? 'NA'
                                    : formatDate(currentDateOfBirth!),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F5F5A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        if (isLoading)
                          const CircularProgressIndicator(
                            color: Color(0xFF0F766E),
                          )
                        else ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: updateDateOfBirth,
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
                              child: const Text(
                                'Update Date of Birth',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: clearDateOfBirth,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFC65D5D),
                                side: const BorderSide(
                                  color: Color(0xFFC65D5D),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Clear Date of Birth',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}