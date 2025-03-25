import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/Paciente.model.dart';

class PacienteService {
  final CollectionReference pacientesRef =
      FirebaseFirestore.instance.collection('pacientes');

  // Guardar un paciente en Firestore
  Future<void> addPaciente(Paciente paciente) async {
    await pacientesRef.add(paciente.toJson());
  }

  // Obtener todos los pacientes
  Stream<List<Paciente>> getPacientes() {
    return pacientesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Paciente.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Actualizar un paciente
  Future<void> updatePaciente(String id, Paciente paciente) async {
    await pacientesRef.doc(id).update(paciente.toJson());
  }

  // Eliminar un paciente
  Future<void> deletePaciente(String id) async {
    await pacientesRef.doc(id).delete();
  }
  Future<Paciente?> obtenerPacientePorCedula(String cedula) async {
  final snapshot = await pacientesRef
      .where('cedula', isEqualTo: cedula)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    print(Paciente.fromJson(data));
    return Paciente.fromJson(data);
  }
  return null;
}


}

