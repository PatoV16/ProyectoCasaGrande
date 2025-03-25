import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:casa_grande_app/Models/FichaMedica.model.dart';

class FichaMedicaService {
  final CollectionReference fichaMedicaRef =
      FirebaseFirestore.instance.collection('fichas_medicas');

  // Guardar una ficha médica en Firestore
  Future<void> addFichaMedica(FichaMedica fichaMedica) async {
    print('Datos a guardar: ${fichaMedica.toJson()}');
    await fichaMedicaRef.add(fichaMedica.toJson());
  }

  // Obtener todas las fichas médicas en tiempo real
  Stream<List<FichaMedica>> getFichasMedicas() {
    return fichaMedicaRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data == null || data is! Map<String, dynamic>) {
          return null;
        }
        return FichaMedica.fromJson(data);
      }).whereType<FichaMedica>().toList();
    });
  }

  // Obtener una ficha médica por ID
  Future<FichaMedica?> getFichaMedicaById(String id) async {
    DocumentSnapshot doc = await fichaMedicaRef.doc(id).get();
    if (doc.exists) {
      return FichaMedica.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Actualizar una ficha médica
  Future<void> updateFichaMedica(String id, FichaMedica fichaMedica) async {
    await fichaMedicaRef.doc(id).update(fichaMedica.toJson());
  }

  // Eliminar una ficha médica
  Future<void> deleteFichaMedica(String id) async {
    await fichaMedicaRef.doc(id).delete();
  }

  // Obtener una ficha médica por la cédula del paciente
  Future<FichaMedica?> getFichaMedicaByPacienteCedula(String cedula) async {
    QuerySnapshot querySnapshot = await fichaMedicaRef
        .where('id_paciente', isEqualTo: cedula)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      return FichaMedica.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}
