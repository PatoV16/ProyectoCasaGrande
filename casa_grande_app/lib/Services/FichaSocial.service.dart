import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/FichaSocial.model.dart';  // Asegúrate de tener el modelo correcto importado.

class FichaSocialService {
  final CollectionReference fichaSocialRef =
      FirebaseFirestore.instance.collection('fichaSocial');

  // Agregar una nueva ficha social
  Future<void> addFichaSocial(FichaSocial fichaSocial) async {
    try {
      DocumentReference docRef = await fichaSocialRef.add(fichaSocial.toJson());
      await docRef.update({'id_fichaSocial': docRef.id});
    } catch (e) {
      print('Error al agregar FichaSocial: $e');
    }
  }

  // Obtener todas las fichas sociales
  Stream<List<FichaSocial>> getFichasSociales() {
    return fichaSocialRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FichaSocial.fromJson({...data, 'id_fichaSocial': doc.id});
      }).toList();
    });
  }

  // Obtener una ficha social por id de paciente
  Future<FichaSocial?> getFichaSocialByPaciente(String idPaciente) async {
    try {
      final querySnapshot = await fichaSocialRef
          .where('id_paciente', isEqualTo: idPaciente)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        print('Documento obtenido: ${doc.data()}');
        return FichaSocial.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id_paciente': idPaciente,
        });
      } else {
        print('No se encontró la ficha social para el paciente con ID: $idPaciente');
      }
    } catch (e) {
      print('Error al obtener FichaSocial por ID: $e');
    }
    return null;
  }

  // Actualizar una ficha social
  Future<void> updateFichaSocial(String id, FichaSocial fichaSocial) async {
    try {
      await fichaSocialRef.doc(id).update(fichaSocial.toJson());
    } catch (e) {
      print('Error al actualizar FichaSocial: $e');
    }
  }

  // Eliminar una ficha social
  Future<void> deleteFichaSocial(String id) async {
    try {
      await fichaSocialRef.doc(id).delete();
    } catch (e) {
      print('Error al eliminar FichaSocial: $e');
    }
  }
}
