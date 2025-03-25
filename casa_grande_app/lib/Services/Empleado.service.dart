import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:casa_grande_app/Models/Empleado.model.dart';

class EmpleadoService {
  final CollectionReference empleadosRef =
      FirebaseFirestore.instance.collection('empleados');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Guardar un empleado en Firestore
  Future<String> addEmpleado(Empleado empleado) async {
    try {
      DocumentReference docRef = await empleadosRef.add(empleado.toMap());
      return docRef.id; // Devuelve el ID del documento creado
    } catch (e) {
      throw Exception('Error al agregar empleado: $e');
    }
  }

  // Obtener todos los empleados
  Stream<List<Empleado>> getEmpleados() {
    return empleadosRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Empleado.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Actualizar un empleado
  // Actualizar un empleado usando la cédula como identificador
Future<void> updateEmpleado(Empleado empleado) async {
  try {
    // Primero buscamos el documento por cédula
    QuerySnapshot querySnapshot = await empleadosRef
        .where('cedula', isEqualTo: empleado.cedula)
        .limit(1)
        .get();
    
    // Verificar si se encontró algún documento
    if (querySnapshot.docs.isEmpty) {
      throw Exception('No se encontró ningún empleado con la cédula: ${empleado.cedula}');
    }
    
    // Obtener el ID del documento
    String docId = querySnapshot.docs.first.id;
    
    // Actualizar el documento usando su ID
    await empleadosRef.doc(docId).update(empleado.toMap());
    
    print('Empleado actualizado correctamente. ID: $docId');
  } catch (e) {
    print('Error al actualizar empleado: $e');
    throw Exception('Error al actualizar empleado: $e');
  }
}

  // Eliminar un empleado
  Future<void> deleteEmpleado(String id) async {
    try {
      await empleadosRef.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar empleado: $e');
    }
  }

  // Obtener el empleado por UID del usuario autenticado
  Future<Empleado?> obtenerEmpleadoPorUid() async {
    try {
      User? user = _auth.currentUser; // Obtener usuario autenticado
      if (user == null) return null; // Si no hay usuario, retorna null

      QuerySnapshot querySnapshot = await empleadosRef
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        return Empleado.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null; // Si no encuentra el empleado
    } catch (e) {
      throw Exception('Error al obtener empleado por UID: $e');
    }
  }
  // Buscar empleado por cédula
// Obtener un empleado por su cédula
Future<Empleado?> obtenerEmpleadoPorCedula(String cedula) async {
  try {
    QuerySnapshot querySnapshot = await empleadosRef
        .where('cedula', isEqualTo: cedula)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      return Empleado.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } else {
      return null; // No se encontró el empleado
    }
  } catch (e) {
    throw Exception('Error al obtener empleado por cédula: $e');
  }
}

  Future<void>  updateEmpleadoPorCedula(String cedula, Empleado empleado) async {
  try {
    // Buscar el documento por cédula
    final querySnapshot = await empleadosRef
        .where('cedula', isEqualTo: cedula)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Obtener el ID del documento
      final docId = querySnapshot.docs.first.id;

      // Actualizar el documento usando su ID
      await empleadosRef.doc(docId).update(empleado.toMap());
    } else {
      throw Exception('No se encontró ningún empleado con la cédula $cedula');
    }
  } catch (e) {
    throw Exception('Error al actualizar empleado: $e');
  }
}
}
