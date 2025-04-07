  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:casa_grande_app/Models/Referencia.model.dart';

  class ReferenciaService {
    final CollectionReference referenciaRef =
        FirebaseFirestore.instance.collection('referencias');

    // Guardar una referencia en Firestore
    Future<void> addReferencia(Referencia referencia) async {
    try {
      // Crear un nuevo documento con ID automático
      final docRef = referenciaRef.doc();
      
      // Asignar el ID del documento al modelo
      referencia.id = docRef.id;
      
      // Guardar el documento con todos los campos incluyendo el ID
      await docRef.set(referencia.toJson());
    } catch (e) {
      print('Error al guardar referencia: $e');
      throw e;
    }
  }

    // Obtener todas las referencias en tiempo real
    Stream<List<Referencia>> getReferencias() {
      return referenciaRef.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          if (data == null || data is! Map<String, dynamic>) {
            return null; // Si data es null, evita la conversión.
          }
          return Referencia.fromJson(data);
        }).whereType<Referencia>().toList();
      });
    }

    // Obtener una referencia por ID
    Future<Referencia?> getReferenciaById(String id) async {
      DocumentSnapshot doc = await referenciaRef.doc(id).get();
      if (doc.exists) {
        return Referencia.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    }

    // Actualizar una referencia
    Future<void> updateReferencia(String id, Referencia referencia) async {
      await referenciaRef.doc(id).update(referencia.toJson());
    }

    // Eliminar una referencia
    Future<void> deleteReferencia(String id) async {
      await referenciaRef.doc(id).delete();
    }
    Future<Referencia?> getReferenciaByPacienteCedula(String cedula) async {
    QuerySnapshot querySnapshot = await referenciaRef
        .where('id_paciente', isEqualTo: cedula)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      return Referencia.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
    Future<List<Referencia>> getReferenciasByPacienteId(String idPaciente) async {
    QuerySnapshot querySnapshot = await referenciaRef
        .where('id_paciente.cedula', isEqualTo: idPaciente)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.map((doc) {
        return Referencia.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    }
    return []; // Retorna una lista vacía si no hay referencias
  }
  }
