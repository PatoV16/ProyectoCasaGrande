import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/Evolucion.model.dart';

class EvolucionService {
  final CollectionReference _evolucionesCollection =
      FirebaseFirestore.instance.collection('evoluciones');

  /// 🔹 Crear una nueva evolución
  Future<Evolucion> crearEvolucion({
    required String idPaciente,
    required DateTime fechaHora,
    required String observaciones,
    required String areaServicio,
    required String tipoFicha,
  }) async {
    try {
      final evolucion = Evolucion(
        idPaciente: idPaciente,
        fechaHora: fechaHora,
        observaciones: observaciones,
        areaServicio: areaServicio,
        tipoFicha: tipoFicha, id: '',
        actividades: [], 
        evolucion: '', 
        recomendaciones: '',
      );

      final docRef = await _evolucionesCollection.add(evolucion.toMap());
      return Evolucion.fromMap(docRef.id, evolucion.toMap());
    } catch (e) {
      print('❌ Error al crear evolución: $e');
      rethrow;
    }
  }

  /// 🔹 Obtener una evolución por ID
  Future<Evolucion?> obtenerEvolucionPorId(String id) async {
    try {
      final doc = await _evolucionesCollection.doc(id).get();
      if (doc.exists) {
        return Evolucion.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("❌ Error al obtener evolución: $e");
      return null;
    }
  }

  /// 🔹 Obtener todas las evoluciones
  Future<List<Evolucion>> obtenerTodasLasEvoluciones() async {
    try {
      final snapshot = await _evolucionesCollection.get();
      List<Evolucion> evoluciones = snapshot.docs
          .map((doc) => Evolucion.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      return evoluciones;
    } catch (e) {
      print("❌ Error al obtener evoluciones: $e");
      return [];
    }
  }

  /// 🔹 Actualizar una evolución
  Future<void> actualizarEvolucion(Evolucion evolucion) async {
    try {
      await _evolucionesCollection.doc(evolucion.id).update(evolucion.toMap());
      print("✅ Evolución actualizada con ID: ${evolucion.id}");
    } catch (e) {
      print("❌ Error al actualizar evolución: $e");
    }
  }

  /// 🔹 Eliminar una evolución
  Future<void> eliminarEvolucion(String id) async {
    try {
      await _evolucionesCollection.doc(id).delete();
      print("✅ Evolución eliminada con ID: $id");
    } catch (e) {
      print("❌ Error al eliminar evolución: $e");
    }
  }
}
