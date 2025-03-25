import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:casa_grande_app/Models/Asistencia.model.dart';

class AsistenciaService {
  final CollectionReference asistenciasRef =
      FirebaseFirestore.instance.collection('asistencias');

  // Guardar una asistencia en Firestore
  Future<void> addAsistencia(Asistencia asistencia) async {
    try {
      await asistenciasRef.add(asistencia.toMap());
    } catch (e) {
      throw Exception('Error al agregar asistencia: $e');
    }
  }

  // Obtener todas las asistencias
  Stream<List<Asistencia>> getAsistencias() {
    return asistenciasRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Asistencia.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Actualizar una asistencia
  Future<void> updateAsistencia(Asistencia asistencia) async {
    try {
      await asistenciasRef.doc(asistencia.id).update(asistencia.toMap());
    } catch (e) {
      throw Exception('Error al actualizar asistencia: $e');
    }
  }

  // Eliminar una asistencia
  Future<void> deleteAsistencia(String id) async {
    try {
      await asistenciasRef.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar asistencia: $e');
    }
  }
}