import '../Models/Lawton.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LawtonBrodyService {
  final CollectionReference lawtonBrodyRef =
      FirebaseFirestore.instance.collection('lawton_brody');

  Future<void> addLawtonBrody(LawtonBrody lawtonBrody) async {
    try {
      DocumentReference docRef = await lawtonBrodyRef.add(lawtonBrody.toMap());
      await docRef.update({'id_lawton_brody': docRef.id});
    } catch (e) {
      print('Error al agregar Lawton-Brody: $e');
    }
  }

  Stream<List<LawtonBrody>> getLawtonBrodys() {
    return lawtonBrodyRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LawtonBrody.fromMap({...data, 'id_lawton_brody': doc.id});
      }).toList();
    });
  }
Future<LawtonBrody?> getLawtonBrodyById(String idPaciente) async {
  try {
    // Realizar la consulta buscando el campo 'id_paciente'
    final querySnapshot = await lawtonBrodyRef
        .where('id_paciente', isEqualTo: idPaciente)  // Buscar por el campo 'id_paciente'
        .limit(1)  // Limitar a 1 resultado
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;  // Tomar el primer documento
      print('Documento obtenido: ${doc.data()}');
      return LawtonBrody.fromMap({
        ...doc.data() as Map<String, dynamic>,
        'id_paciente': idPaciente,
      });
    } else {
      print('No se encontró el documento con id_paciente: $idPaciente');
    }
  } catch (e) {
    print('Error al obtener Lawton-Brody por ID: $e');
  }
  return null;
}



  Future<void> updateLawtonBrody(String id, LawtonBrody lawtonBrody) async {
    try {
      await lawtonBrodyRef.doc(id).update(lawtonBrody.toMap());
    } catch (e) {
      print('Error al actualizar Lawton-Brody: $e');
    }
  }

  Future<void> deleteLawtonBrody(String id) async {
    try {
      await lawtonBrodyRef.doc(id).delete();
    } catch (e) {
      print('Error al eliminar Lawton-Brody: $e');
    }
  }
}
