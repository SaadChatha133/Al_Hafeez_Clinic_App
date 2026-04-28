import 'dart:ui';
import 'package:flutter/material.dart';
import '../appointments/appointment_models.dart';
import '../family/report_list_page.dart';
import '../family/report_service.dart';

class DoctorAppointmentDetailPage extends StatelessWidget {
  final AppointmentBooking booking;

  const DoctorAppointmentDetailPage({
    super.key,
    required this.booking,
  });

  static const List<String> reportTypes = [
    'Blood Test',
    'X-Ray',
    'MRI',
    'Prescription',
    'ECG',
  ];

  int? calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return null;

    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;

    final hasHadBirthdayThisYear = today.month > dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day >= dateOfBirth.day);

    if (!hasHadBirthdayThisYear) age--;
    return age;
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void openReportList(BuildContext context, String category) {
    if (booking.memberId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No family member record linked with this appointment.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportListPage(
          memberId: booking.memberId,
          category: category,
        ),
      ),
    );
  }

  Widget buildReportBox(BuildContext context, String reportName) {
    final ReportService reportService = ReportService();

    return StreamBuilder<int>(
      stream: reportService.reportCountStream(
        memberId: booking.memberId,
        category: reportName,
      ),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return GestureDetector(
          onTap: () => openReportList(context, reportName),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.45),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.folder_rounded,
                  color: Color(0xFF0F766E),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reportName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F5F5A),
                    ),
                  ),
                ),
                Text(
                  count == 0 ? 'Empty' : '$count',
                  style: const TextStyle(
                    color: Color(0xFF275E59),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF275E59),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final age = calculateAge(booking.memberDateOfBirth);
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
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.assignment_ind_rounded,
                          size: 54,
                          color: Color(0xFF0F766E),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          booking.memberName.isEmpty
                              ? 'Family Member'
                              : booking.memberName,
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
                        const SizedBox(height: 24),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Patient Records',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F5F5A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...reportTypes.map(
                          (type) => buildReportBox(context, type),
                        ),
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