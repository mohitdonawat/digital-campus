import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/library_resource_model.dart';

class LibraryService {
  static final _col = FirebaseFirestore.instance.collection('library_resources');

  static Future<String> uploadResource(LibraryResourceModel res) async {
    final ref = await _col.add(res.toMap());
    return ref.id;
  }

  static Stream<List<LibraryResourceModel>> getResources({
    String? department,
    String? year,
  }) {
    return _col.snapshots().map((snap) {
      final list = snap.docs.map((d) => LibraryResourceModel.fromMap(d.data(), d.id)).toList();
      final filtered = list.where((r) {
        if (department != null && department != 'ALL') {
          final matchesDept = r.department == 'ALL' ||
              r.department.toLowerCase().trim() == department.toLowerCase().trim() ||
              department.toLowerCase().contains(r.department.toLowerCase());
          if (!matchesDept) return false;
        }
        if (year != null && year != 'ALL') {
          final matchesYear = r.year == 'ALL' || r.year.toLowerCase().trim() == year.toLowerCase().trim();
          if (!matchesYear) return false;
        }
        return true;
      }).toList();
      filtered.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
      return filtered;
    });
  }
}
