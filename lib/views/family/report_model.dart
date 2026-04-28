import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String category;
  final String imageUrl;
  final double confidence;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.category,
    required this.imageUrl,
    required this.confidence,
    required this.createdAt,
  });

  factory ReportModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ReportModel(
      id: doc.id,
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      confidence: (data['confidence'] ?? 0).toDouble(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}