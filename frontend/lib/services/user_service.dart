import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/base_url.dart';
import '../models/recording_model.dart';

class RecordingUploadService {
  /// Uploads a file to Firebase Storage and returns the download URL.
  static Future<String> uploadFileToFirebase(File file, String folder) async {
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final Reference storageRef =
        FirebaseStorage.instance.ref().child(folder).child(fileName);
    final SettableMetadata metadata = SettableMetadata(); // <-- Add this line
    final UploadTask uploadTask =
        storageRef.putFile(file, metadata); // <-- Pass metadata
    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Uploads the recording (thumbnail and video) and then saves details via backend API.
  static Future<bool> uploadRecording({
    required String name,
    required String description,
    required String visibility,
    required File? thumbnail,
    required File video,
    String? batchId, // optional, if batch is selected
  }) async {
    try {
      // 1. Upload thumbnail (if provided)
      String? thumbnailUrl;
      if (thumbnail != null) {
        thumbnailUrl =
            await uploadFileToFirebase(thumbnail, 'recording_thumbnails');
      }

      // 2. Upload video (required)
      String videoUrl = await uploadFileToFirebase(video, 'recording_videos');

      // 3. Prepare RecordingModel
      final recording = RecordingModel(
        name: name,
        description: description,
        visibility: visibility,
        thumbnailUrl: thumbnailUrl,
        videoUrl: videoUrl,
        batchId: batchId,
        uploadDate: DateTime.now(),
      );
      print('Recording details: ${recording.toJson()}');

      // 4. Call backend API to save recording details
      final response = await http.post(
        Uri.parse('$url/api/recordings-upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(recording.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to save recording details: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<RecordingModel>> fetchRecordings() async {
    try {
      final response = await http.post(Uri.parse('$url/api/get-recordings'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Fetched recordings: $data');
        return data.map((item) => RecordingModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch recordings: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
