import 'package:casa_grande_app/Models/AsistenciaUsuario.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';


class AsistenciaUsuarioService {
  final CollectionReference asistenciaRef =
      FirebaseFirestore.instance.collection('asistencia');

  Future<void> registrarAsistencia(AsistenciaUsuario asistencia) async {
    try {
      asistencia.id = const Uuid().v4(); // Genera un ID único
      await asistenciaRef.doc(asistencia.id).set(asistencia.toMap());
      print("Asistencia registrada correctamente.");
    } catch (e) {
      print("Error al registrar asistencia: $e");
    }
  }

  Future<List<AsistenciaUsuario>> obtenerAsistencias() async {
    try {
      QuerySnapshot snapshot = await asistenciaRef.get();
      return snapshot.docs.map((doc) {
        return AsistenciaUsuario.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error al obtener asistencias: $e");
      return [];
    }
  }
  Future<String?> obtenerUidUsuarioActual() async {
  try {
    // Obtener el usuario actual
    User? user = FirebaseAuth.instance.currentUser;
    
    // Si hay un usuario autenticado, devolver su UID
    if (user != null) {
      return user.uid;
    } else {
      // Si no hay un usuario autenticado
      print("No hay un usuario autenticado.");
      return null;
    }
  } catch (e) {
    print("Error al obtener UID: $e");
    return null;
  }
}
}
