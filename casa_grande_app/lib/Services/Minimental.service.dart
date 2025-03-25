import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/Minimental.model.dart';

class MiniExamenService {
  final CollectionReference miniExamenRef =
      FirebaseFirestore.instance.collection('mini_examen');

  Future<void> addMiniExamen(MiniExamen miniExamen) async {
    try {
      DocumentReference docRef = await miniExamenRef.add(miniExamen.toJson());
      await docRef.update({'id_mini_examen': docRef.id});
    } catch (e) {
      print('Error al agregar Mini Examen: $e');
    }
  }

  Stream<List<MiniExamen>> getMiniExamenes() {
    return miniExamenRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MiniExamen.fromJson({...data, 'id_mini_examen': doc.id});
      }).toList();
    });
  }

  Future<MiniExamen?> getMiniExamenByPaciente(String idPaciente) async {
  try {
    // Realizar la consulta buscando el campo 'id_paciente'
    final querySnapshot = await miniExamenRef
        .where('id_paciente', isEqualTo: idPaciente)  // Buscar por el campo 'id_paciente'
        .limit(1)  // Limitar a 1 resultado
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;  // Tomar el primer documento
      print('Documento obtenido: ${doc.data()}');
      return MiniExamen.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id_paciente': idPaciente,
      });
    } else {
      print('No se encontró el documento con id_paciente: $idPaciente');
    }
  } catch (e) {
    print('Error al obtener miniexamen por ID: $e');
  }
  return null;
}

  Future<void> updateMiniExamen(String id, MiniExamen miniExamen) async {
    try {
      await miniExamenRef.doc(id).update(miniExamen.toJson());
    } catch (e) {
      print('Error al actualizar Mini Examen: $e');
    }
  }

  Future<void> deleteMiniExamen(String id) async {
    try {
      await miniExamenRef.doc(id).delete();
    } catch (e) {
      print('Error al eliminar Mini Examen: $e');
    }
  }
}
