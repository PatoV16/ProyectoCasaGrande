import 'package:casa_grande_app/Models/Kardex.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KardexGerontologicoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'kardexGerontologico';

  Future<String> createKardex(KardexGerontologico kardex) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(kardex.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear el kardex: $e');
    }
  }

  Future<void> updateKardex(KardexGerontologico kardex) async {
    try {
      await _firestore.collection(_collectionName)
          .doc(kardex.id)
          .update({
            ...kardex.toMap(),
            'fechaActualizacion': DateTime.now().millisecondsSinceEpoch,
          });
    } catch (e) {
      throw Exception('Error al actualizar el kardex: $e');
    }
  }

  Future<KardexGerontologico?> getKardexById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return KardexGerontologico.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener el kardex: $e');
    }
  }

  Future<List<KardexGerontologico>> getKardexByPaciente(String idPaciente) async {
    try {
      final query = await _firestore.collection(_collectionName)
          .where('idPaciente', isEqualTo: idPaciente)
          .get();

      return query.docs.map((doc) => KardexGerontologico.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Error al obtener los kardex del paciente: $e');
    }
  }

  Future<void> addMedicamento(String kardexId, Medicamento medicamento) async {
    try {
      await _firestore.collection(_collectionName)
          .doc(kardexId)
          .update({
            'medicamentos': FieldValue.arrayUnion([medicamento.toMap()]),
            'fechaActualizacion': DateTime.now().millisecondsSinceEpoch,
          });
    } catch (e) {
      throw Exception('Error al agregar medicamento: $e');
    }
  }

  Future<void> addAdministracion(
    String kardexId, 
    int medicamentoIndex, 
    Administracion administracion
  ) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(kardexId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final medicamentos = List<Map<String, dynamic>>.from(data['medicamentos']);
        
        if (medicamentoIndex < medicamentos.length) {
          final medicamento = medicamentos[medicamentoIndex];
          final administraciones = List<Map<String, dynamic>>.from(medicamento['administraciones'] ?? []);
          administraciones.add(administracion.toMap());
          medicamento['administraciones'] = administraciones;
          medicamentos[medicamentoIndex] = medicamento;
          
          await _firestore.collection(_collectionName)
              .doc(kardexId)
              .update({
                'medicamentos': medicamentos,
                'fechaActualizacion': DateTime.now().millisecondsSinceEpoch,
              });
        }
      }
    } catch (e) {
      throw Exception('Error al agregar administración: $e');
    }
  }
}