import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/procedure.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String proceduresCollection = 'procedures';

  Future<Procedure?> getProcedureById(String documentId) async {
    try {
      final doc = await _firestore
          .collection(proceduresCollection)
          .doc(documentId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id;
      return Procedure.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch procedure: $e');
    }
  }

  Future<List<Procedure>> searchProceduresByKeywords(
      List<String> keywords) async {
    try {
      if (keywords.isEmpty) {
        return [];
      }

      // Query using array-contains for keyword matching
      final querySnapshot = await _firestore
          .collection(proceduresCollection)
          .where('keywords', arrayContainsAny: keywords)
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Procedure.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search procedures: $e');
    }
  }

  Future<List<Procedure>> getAllProcedures() async {
    try {
      final querySnapshot =
          await _firestore.collection(proceduresCollection).get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Procedure.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch all procedures: $e');
    }
  }

  Future<List<Procedure>> searchProceduresByText(String searchText) async {
    try {
      // Client-side text search as a fallback
      final allProcedures = await getAllProcedures();
      final lowerSearchText = searchText.toLowerCase();

      return allProcedures.where((procedure) {
        final titleMatch = procedure.title.toLowerCase().contains(lowerSearchText);
        final keywordMatch = procedure.keywords.any(
            (keyword) => keyword.toLowerCase().contains(lowerSearchText));
        return titleMatch || keywordMatch;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search procedures by text: $e');
    }
  }
}
