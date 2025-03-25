import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/InformePsicologico.model.dart';  // Asegúrate de que la clase EvaluacionPsicologica esté correctamente importada.

class EvaluacionPsicologicaService {
  final CollectionReference evaluacionPsicologicaRef =
      FirebaseFirestore.instance.collection('evaluaciones_psicologicas');

  // Agregar una nueva Evaluación Psicológica
  Future<void> addEvaluacionPsicologica(EvaluacionPsicologica evaluacion) async {
    try {
      DocumentReference docRef = await evaluacionPsicologicaRef.add(evaluacion.toMap());
      await docRef.update({'id': docRef.id});
    } catch (e) {
      print('Error al agregar Evaluación Psicológica: $e');
    }
  }

  // Obtener todas las evaluaciones psicológicas
  Stream<List<EvaluacionPsicologica>> getEvaluacionesPsicologicas() {
    return evaluacionPsicologicaRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EvaluacionPsicologica.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }

  // Obtener una evaluación psicológica por id de paciente
  Future<EvaluacionPsicologica?> getEvaluacionPsicologicaByPaciente(String idPaciente) async {
    try {
      final querySnapshot = await evaluacionPsicologicaRef
          .where('id_paciente', isEqualTo: idPaciente)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return EvaluacionPsicologica.fromMap({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      } else {
        print('No se encontró la evaluación psicológica con id_paciente: $idPaciente');
      }
    } catch (e) {
      print('Error al obtener Evaluación Psicológica por ID: $e');
    }
    return null;
  }

  // Actualizar una evaluación psicológica
  Future<void> updateEvaluacionPsicologica(String id, EvaluacionPsicologica evaluacion) async {
    try {
      await evaluacionPsicologicaRef.doc(id).update(evaluacion.toMap());
    } catch (e) {
      print('Error al actualizar Evaluación Psicológica: $e');
    }
  }

  // Eliminar una evaluación psicológica
  Future<void> deleteEvaluacionPsicologica(String id) async {
    try {
      await evaluacionPsicologicaRef.doc(id).delete();
    } catch (e) {
      print('Error al eliminar Evaluación Psicológica: $e');
    }
  }
}