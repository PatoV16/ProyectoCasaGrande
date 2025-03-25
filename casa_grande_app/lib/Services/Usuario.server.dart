import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/UserModel.dart';

class UserService {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('usuarios');

  // Guardar un usuario en Firestore
 Future<void> addUser(UserModel user, String uid) async {
  try {
    // Guardar el usuario en Firestore usando el UID como ID del documento
    await usersRef.doc(uid).set(user.toJson());
  } catch (e) {
    throw Exception('Error al agregar usuario: $e');
  }
}

  // Obtener todos los usuarios
  Stream<List<UserModel>> getUsers() {
    return usersRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Ajustamos el mapa para incluir el id del documento
        data['id_empleado'] = int.tryParse(doc.id) ?? 0;
        return UserModel.fromJson(data);
      }).toList();
    });
  }

  // Buscar usuario por correo (útil para login)
 Future<UserModel?> getUserByEmail(String email) async {
  try {
    final snapshot = await usersRef.where('correo', isEqualTo: email).get();

    // Verificar que snapshot no esté vacío antes de acceder a docs.first
    if (snapshot.docs.isEmpty) {
      print("No se encontró usuario con el correo: $email");
      return null;
    }

    final doc = snapshot.docs.first;
    final data = doc.data() as Map<String, dynamic>?; 

    if (data == null) {
      print("Datos nulos para el usuario con correo: $email");
      return null;
    } 

    return UserModel.fromJson(data);
  } catch (e) {
    print('Error al buscar usuario por correo: $e');
    return null;  // Mejor retornar null que lanzar una excepción
  }
}


  // Actualizar un usuario
 Future<void> updateUser(UserModel user) async {
  try {
    if (user.idEmpleado == null) {
      throw Exception('No se puede actualizar un usuario sin ID');
    }
    await usersRef.doc(user.idEmpleado).update(user.toJson());
  } catch (e) {
    throw Exception('Error al actualizar usuario: $e');
  }
}

  // Eliminar un usuario
  Future<void> deleteUser(int id) async {
    try {
      await usersRef.doc(id.toString()).delete();
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }
  
  // Autenticar usuario (ejemplo básico, considera usar Firebase Auth para seguridad real)
  Future<UserModel?> authenticateUser(String email, String password) async {
    try {
      final snapshot = await usersRef
          .where('correo', isEqualTo: email)
          .where('contrasena', isEqualTo: password)
          .get();
          
      if (snapshot.docs.isEmpty) {
        return null;
      }
      
      final doc = snapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id_empleado'] = int.tryParse(doc.id) ?? 0;
      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Error al autenticar usuario: $e');
    }
  }
  
  // Obtener usuarios por cargo
  Stream<List<UserModel>> getUsersByCargo(String cargo) {
    return usersRef
        .where('cargo', isEqualTo: cargo)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id_empleado'] = int.tryParse(doc.id) ?? 0;
        return UserModel.fromJson(data);
      }).toList();
    });
  }
  // Obtener usuario por UID
Future<UserModel?> getUserById(String uid) async {
  try {
    final doc = await usersRef.doc(uid).get();

    if (!doc.exists) {
      print("No se encontró el usuario con UID: $uid");
      return null;
    }

    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      print("Datos nulos para el usuario con UID: $uid");
      return null;
    }

    return UserModel.fromJson(data);
  } catch (e) {
    print('Error al obtener usuario por UID: $e');
    return null;
  }
}

}