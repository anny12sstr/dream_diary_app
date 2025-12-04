import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dream_diary_app/models/dream_model.dart';

abstract class IDreamRepository {
  Future<List<Dream>> getDreams(String userId);
  Future<void> addDream(String userId, Map<String, dynamic> dreamData);
  Future<void> updateDream(String userId, String dreamId, Map<String, dynamic> dreamData);
  Future<void> deleteDream(String userId, String dreamId);
  Future<void> updateDreamRating(String userId, String dreamId, double rating);
}

class DreamRepository implements IDreamRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Dream>> getDreams(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('dreams')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => Dream.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching dreams: $e');
    }
  }

  @override
  Future<void> addDream(String userId, Map<String, dynamic> dreamData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('dreams')
        .add(dreamData);
  }

  @override
  Future<void> updateDream(String userId, String dreamId, Map<String, dynamic> dreamData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('dreams')
        .doc(dreamId)
        .update(dreamData);
  }

  @override
  Future<void> deleteDream(String userId, String dreamId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('dreams')
        .doc(dreamId)
        .delete();
  }

  @override
  Future<void> updateDreamRating(String userId, String dreamId, double rating) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('dreams')
        .doc(dreamId)
        .update({'rating': rating});
  }
}