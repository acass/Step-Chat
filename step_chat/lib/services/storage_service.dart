import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Gets a download URL for an image from Firebase Storage
  Future<String> getImageUrl(String imagePath) async {
    try {
      // Remove 'gs://' prefix if present
      String path = imagePath;
      if (path.startsWith('gs://')) {
        // Parse the gs:// URL
        final uri = Uri.parse(path);
        path = uri.path.substring(1); // Remove leading '/'
      }

      final ref = _storage.ref(path);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Failed to get image URL: $e');
    }
  }

  /// Gets download URLs for multiple images
  Future<List<String>> getImageUrls(List<String> imagePaths) async {
    try {
      final urls = <String>[];
      for (final path in imagePaths) {
        final url = await getImageUrl(path);
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw Exception('Failed to get image URLs: $e');
    }
  }

  /// Checks if a file exists in Firebase Storage
  Future<bool> fileExists(String path) async {
    try {
      await _storage.ref(path).getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }
}
