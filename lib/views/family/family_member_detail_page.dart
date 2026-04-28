import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'family_member_model.dart';
import 'family_service.dart';
import 'report_service.dart';
import 'report_list_page.dart';

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
  final ReportService reportService = ReportService();
  final ImagePicker picker = ImagePicker();

  DateTime? currentDateOfBirth;
  bool isLoading = false;
  bool isUploading = false;
  String? errorMessage;

  final List<String> reportTypes = const [
    'Blood Test',
    'X-Ray',
    'MRI',
    'Prescription',
    'ECG',
  ];

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

  void showSuccess(String message) {
    setState(() {
      errorMessage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 55,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile == null) return;

      setState(() {
        isUploading = true;
        errorMessage = null;
      });

      final file = File(pickedFile.path);

      await reportService.processReport(
        file: file,
        memberId: widget.member.id,
      );

      if (!mounted) return;

      showSuccess('Report uploaded and classified successfully.');
    } catch (e) {
      if (!mounted) return;
      showError('Failed to upload report. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> showUploadOptions() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void openReportList(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportListPage(
          memberId: widget.member.id,
          category: category,
        ),
      ),
    );
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
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD64545)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Color(0xFF9F1D1D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReportBox(String reportName) {
    return StreamBuilder<int>(
      stream: reportService.reportCountStream(
        memberId: widget.member.id,
        category: reportName,
      ),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return GestureDetector(
          onTap: () => openReportList(reportName),
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
                              const SizedBox(height: 14),
                              isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF0F766E),
                                      ),
                                    )
                                  : SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: updateDateOfBirth,
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor:
                                              const Color(0xFF0F766E),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: const Text(
                                          'Update Date of Birth',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isUploading ? null : showUploadOptions,
                            icon: isUploading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.upload_file_rounded),
                            label: const Text('Upload Report'),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFF2C8C84),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Reports',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F5F5A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...reportTypes.map(buildReportBox),
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