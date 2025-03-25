import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/Yesavage.model.dart';  // Asegúrate de que la clase Yesavage esté correctamente importada.

class YesavageService {
  final CollectionReference yesavageRef =
      FirebaseFirestore.instance.collection('yesavage');

  // Agregar un nuevo Yesavage
  Future<void> addYesavage(Yesavage yesavage) async {
    try {
      DocumentReference docRef = await yesavageRef.add(yesavage.toJson());
      await docRef.update({'id': docRef.id});
    } catch (e) {
      print('Error al agregar Yesavage: $e');
    }
  }

  // Obtener todos los registros de Yesavage
  Stream<List<Yesavage>> getYesavages() {
    return yesavageRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Yesavage.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  // Obtener un Yesavage por id de paciente
  Future<Yesavage?> getYesavageByPaciente(String idPaciente) async {
    try {
      // Realizar la consulta buscando el campo 'id_paciente'
      final querySnapshot = await yesavageRef
          .where('id_paciente', isEqualTo: idPaciente)  // Buscar por el campo 'id_paciente'
          .limit(1)  // Limitar a 1 resultado
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;  // Tomar el primer documento
        print('Documento obtenido: ${doc.data()}');
        return Yesavage.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id_paciente': idPaciente,
        });
      } else {
        print('No se encontró el documento con id_paciente: $idPaciente');
      }
    } catch (e) {
      print('Error al obtener Yesavage por ID: $e');
    }
    return null;
  }

  // Actualizar un registro de Yesavage
  Future<void> updateYesavage(String id, Yesavage yesavage) async {
    try {
      await yesavageRef.doc(id).update(yesavage.toJson());
    } catch (e) {
      print('Error al actualizar Yesavage: $e');
    }
  }

  // Eliminar un registro de Yesavage
  Future<void> deleteYesavage(String id) async {
    try {
      await yesavageRef.doc(id).delete();
    } catch (e) {
      print('Error al eliminar Yesavage: $e');
    }
  }
}
