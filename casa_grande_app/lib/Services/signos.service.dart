import 'package:casa_grande_app/Models/signos.vitales.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ajusta la ruta si es diferente

class SignosVitalesService {
  final CollectionReference _signosCollection =
      FirebaseFirestore.instance.collection('signos_vitales');

  // Crear nuevo registro de signos vitales
  Future<void> agregarSignosVitales(SignosVitales signos) async {
    await _signosCollection.add(signos.toMap());
  }

  // Obtener todos los registros de un paciente
 Future<List<SignosVitales>> obtenerSignosPorPaciente(String idPaciente) async {
  QuerySnapshot snapshot = await _signosCollection.get();

  List<SignosVitales> signos = snapshot.docs
      .map((doc) => SignosVitales.fromMap(doc.data() as Map<String, dynamic>, doc.id))
      .where((signo) => signo.idPaciente == idPaciente)
      .toList();

  signos.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro)); // Ordenar por fecha descendente

  return signos;
}

  // Obtener un registro específico por ID
  Future<SignosVitales?> obtenerSignosPorId(String id) async {
    DocumentSnapshot doc = await _signosCollection.doc(id).get();
    if (doc.exists) {
      return SignosVitales.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Actualizar un registro existente
  Future<void> actualizarSignosVitales(SignosVitales signos) async {
    await _signosCollection.doc(signos.id).update(signos.toMap());
  }

  // Eliminar un registro
  Future<void> eliminarSignosVitales(String id) async {
    await _signosCollection.doc(id).delete();
  }
}
