import 'package:cloud_firestore/cloud_firestore.dart';

class Dream {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String category;
  final String emotion;
  final double rating;
  final List<String> tags;
  final bool isDraft;

  Dream({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.emotion,
    required this.rating,
    required this.tags,
    this.isDraft = false,
  });

  factory Dream.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Dream(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] ?? 'Abstract',
      emotion: data['emotion'] ?? 'Peaceful',
      rating: (data['rating'] as num?)?.toDouble() ?? 3.0,
      tags: List<String>.from(data['tags'] ?? []),
      isDraft: data['isDraft'] ?? false,
    );
  }
}