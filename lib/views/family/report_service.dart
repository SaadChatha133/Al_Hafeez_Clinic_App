import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'report_model.dart';

class ReportService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  final String apiUrl =
      "https://report-classifier-api-836138859179.asia-south1.run.app/predict";

  Future<Map<String, dynamic>> classifyImage(File file) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(apiUrl),
    );

    request.files.add(
      await http.MultipartFile.fromPath("file", file.path),
    );

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception("Failed to classify image");
    }

    final body = await response.stream.bytesToString();
    return jsonDecode(body);
  }

  Future<String> uploadImage({
    required File file,
    required String memberId,
  }) async {
    final user = auth.currentUser!;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final ref = storage.ref().child(
          "reports/${user.uid}/$memberId/$fileName",
        );

    final bytes = await file.readAsBytes();

    await ref.putData(
      bytes,
      SettableMetadata(contentType: "image/jpeg"),
    );

    return await ref.getDownloadURL();
  }

  Future<void> saveReport({
    required String memberId,
    required String category,
    required double confidence,
    required String imageUrl,
  }) async {
    final user = auth.currentUser!;

    await firestore
        .collection("family_members")
        .doc(memberId)
        .collection("reports")
        .add({
      "userId": user.uid,
      "memberId": memberId,
      "category": category,
      "confidence": confidence,
      "imageUrl": imageUrl,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> processReport({
    required File file,
    required String memberId,
  }) async {
    final result = await classifyImage(file);

    final imageUrl = await uploadImage(
      file: file,
      memberId: memberId,
    );

    await saveReport(
      memberId: memberId,
      category: result["category"],
      confidence: (result["confidence"] ?? 0).toDouble(),
      imageUrl: imageUrl,
    );
  }

  Stream<List<ReportModel>> reportsByCategoryStream({
    required String memberId,
    required String category,
  }) {
    return firestore
        .collection("family_members")
        .doc(memberId)
        .collection("reports")
        .where("category", isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final reports =
          snapshot.docs.map((doc) => ReportModel.fromDoc(doc)).toList();

      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return reports;
    });
  }

  Stream<int> reportCountStream({
    required String memberId,
    required String category,
  }) {
    return reportsByCategoryStream(
      memberId: memberId,
      category: category,
    ).map((reports) => reports.length);
  }

  Future<void> deleteReport({
    required String memberId,
    required ReportModel report,
  }) async {
    await firestore
        .collection("family_members")
        .doc(memberId)
        .collection("reports")
        .doc(report.id)
        .delete();

    try {
      await storage.refFromURL(report.imageUrl).delete();
    } catch (_) {}
  }

  Future<String> downloadReportImage({
    required ReportModel report,
  }) async {
    final response = await http.get(Uri.parse(report.imageUrl));

    if (response.statusCode != 200) {
      throw Exception("Could not download report.");
    }

    final directory = await getApplicationDocumentsDirectory();

    final filePath =
        "${directory.path}/report_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return filePath;
  }
}