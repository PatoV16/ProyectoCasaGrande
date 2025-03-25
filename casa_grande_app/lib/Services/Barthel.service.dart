import '../Models/Barthel.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class BarthelService {
  final CollectionReference barthelRef =
      FirebaseFirestore.instance.collection('barthel');

  Future<void> addBarthel(Barthel barthel) async {
    await barthelRef.add(barthel.toMap());
  }

  Stream<List<Barthel>> getBarthels() {
    return barthelRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Barthel.fromMap(data);
      }).toList();
    });
  }

  Future<Barthel?> getBarthelById(String id) async {
  final snapshot = await barthelRef
      .where('id_paciente', isEqualTo: id)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    print(Barthel.fromMap(data));
    return Barthel.fromMap(data);
  }
  return null;
}


  Future<void> updateBarthel(String id, Barthel barthel) async {
    await barthelRef.doc(id).update(barthel.toMap());
  }

  Future<void> deleteBarthel(String id) async {
    await barthelRef.doc(id).delete();
  }
}
