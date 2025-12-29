import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/reflection/data/models/reflection_model.dart';

class ReflectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get reflection for specific user and year
  Future<ReflectionModel?> getUserReflectionForYear(
    String userId,
    int year,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('reflections')
          .where('userId', isEqualTo: userId)
          .where('year', isEqualTo: year)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return ReflectionModel.fromJson(querySnapshot.docs.first.data());
    } catch (e) {
      print('Error getting reflection: $e');
      return null;
    }
  }

  // Get all reflections for a user (for past years)
  Stream<List<ReflectionModel>> getUserReflections(String userId) {
    return _firestore
        .collection('reflections')
        .where('userId', isEqualTo: userId)
        .orderBy('year', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReflectionModel.fromJson(doc.data()))
              .toList();
        });
  }

  // Create or update reflection
  Future<void> saveReflection(ReflectionModel reflection) async {
    try {
      await _firestore
          .collection('reflections')
          .doc(reflection.id)
          .set(reflection.toJson());
    } catch (e) {
      throw 'Viga postituse salvestamisel: $e';
    }
  }
}
