import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadReflectionPhoto({
    required File photoFile,
    required String userId,
    required int year,
  }) async {
    try {
      final fileName = '${userId}_$year.jpg';

      final Reference storageRef = _storage.ref().child(
        'reflections/$fileName',
      );
      final UploadTask uploadTask = storageRef.putFile(photoFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;

    } catch (e) {
      throw 'Viga pildi üleslaadimisel: $e';
    }
  }
}
