  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:casa_grande_app/Models/ActaCompromiso.model.dart';

  class ActaCompromisoService {
  final CollectionReference actasRef =
      FirebaseFirestore.instance.collection('actas_compromiso');

  // Guardar un acta en Firestore
  Future<void> addActaCompromiso(ActaCompromiso acta) async {
    await actasRef.add(acta.toMap());
  }

  // Obtener todas las actas en tiempo real
  Stream<List<ActaCompromiso>> getActasCompromiso() {
    return actasRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ActaCompromiso.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Obtener una sola acta por ID
  Future<ActaCompromiso?> getActaById(String id) async {
    DocumentSnapshot doc = await actasRef.doc(id).get();
    if (doc.exists) {
      return ActaCompromiso.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Obtener acta por ID de paciente
  Future<ActaCompromiso?> getActaPorPaciente(String idPaciente) async {
    final snapshot = await actasRef.where('id_paciente', isEqualTo: idPaciente).limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      return ActaCompromiso.fromMap(snapshot.docs.first.data() as Map<String, dynamic>, snapshot.docs.first.id);
    }
    return null;
  }

  // Actualizar un acta de compromiso
  Future<void> updateActaCompromiso(ActaCompromiso acta) async {
    await actasRef.doc(acta.id).update(acta.toMap());
  }

  // Eliminar un acta de compromiso
  Future<void> deleteActaCompromiso(String id) async {
    await actasRef.doc(id).delete();
  }
}

