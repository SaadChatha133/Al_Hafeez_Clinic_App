import 'dart:ui';
import 'package:flutter/material.dart';
import 'report_model.dart';
import 'report_service.dart';

class ReportListPage extends StatelessWidget {
  final String memberId;
  final String category;

  const ReportListPage({
    super.key,
    required this.memberId,
    required this.category,
  });

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void openImageViewer(BuildContext context, ReportModel report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportImageViewerPage(report: report),
      ),
    );
  }

  Future<void> showReportOptions({
    required BuildContext context,
    required ReportService reportService,
    required ReportModel report,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.download_rounded,
                  color: Color(0xFF0F766E),
                ),
                title: const Text('Download'),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);

                  try {
                    final path = await reportService.downloadReportImage(
                      report: report,
                    );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Report downloaded to:\n$path'),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not download report.'),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_forever_rounded,
                  color: Color(0xFFC65D5D),
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Color(0xFFC65D5D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text('Delete Report'),
                        content: const Text(
                          'Are you sure you want to delete this report?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                color: Color(0xFFC65D5D),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm != true) return;

                  try {
                    await reportService.deleteReport(
                      memberId: memberId,
                      report: report,
                    );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report deleted successfully.'),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not delete report.'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildReportCard({
    required BuildContext context,
    required ReportService reportService,
    required ReportModel report,
  }) {
    return GestureDetector(
      onTap: () => openImageViewer(context, report),
      onLongPress: () => showReportOptions(
        context: context,
        reportService: reportService,
        report: report,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                report.imageUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Uploaded: ${formatDate(report.createdAt)}',
              style: const TextStyle(
                color: Color(0xFF275E59),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap to view. Hold for options.',
              style: TextStyle(
                color: Color(0xFF6B8F8B),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ReportService reportService = ReportService();

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
                          Icons.folder_copy_rounded,
                          size: 50,
                          color: Color(0xFF0F766E),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F5F5A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap a report to view it larger. Hold a report to download or delete.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF275E59),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        StreamBuilder<List<ReportModel>>(
                          stream: reportService.reportsByCategoryStream(
                            memberId: memberId,
                            category: category,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(
                                color: Color(0xFF0F766E),
                              );
                            }

                            final reports = snapshot.data ?? [];

                            if (reports.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.45),
                                  ),
                                ),
                                child: const Text(
                                  'No reports uploaded yet.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF275E59),
                                    fontSize: 15,
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: reports.map((report) {
                                return buildReportCard(
                                  context: context,
                                  reportService: reportService,
                                  report: report,
                                );
                              }).toList(),
                            );
                          },
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

class ReportImageViewerPage extends StatelessWidget {
  final ReportModel report;

  const ReportImageViewerPage({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Report Preview'),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: Image.network(
            report.imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}