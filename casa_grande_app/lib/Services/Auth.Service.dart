import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/UserModel.dart';
import 'Usuario.server.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de cambios de estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Inicio de sesión con email y contraseña - Versión compatible con Vercel
  Future<User?> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error de inicio de sesión: $e');
      return null;
    }
  }

  // Obtener datos del usuario después de la autenticación
  Future<UserModel?> getUserDataAfterAuth(String uid) async {
    try {
      return await _userService.getUserById(uid);
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      return null;
    }
  }

  // Registro de usuario con email y contraseña
  Future<UserCredential> registerWithEmailAndPassword(
    String email, String password, UserModel userModel) async {
    try {
      // Registrar en Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si el registro en Auth fue exitoso, guardar datos adicionales en Firestore
      if (userCredential.user != null) {
        // Obtener el UID del usuario recién creado
        String uid = userCredential.user!.uid;

        // Guardar información adicional del usuario en Firestore usando el UID como id_empleado
        await _userService.addUser(userModel, uid);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Ya existe una cuenta con ese correo electrónico.');
      } else {
        throw Exception('Error al registrar usuario: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Cerrar sesión con confirmación
  Future<void> signOutWithConfirmation(BuildContext context) async {
    final shouldSignOut = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        content: const Text('Esta acción te cerrará la sesión de la aplicación.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await _auth.signOut();
      Navigator.of(context).popAndPushNamed('/');
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Error al restablecer la contraseña: ${e.message}');
    } catch (e) {
      throw Exception('Error al restablecer la contraseña: $e');
    }
  }

  // Actualizar perfil de usuario (nombre, foto, etc.)
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(displayName);
        await _auth.currentUser!.updatePhotoURL(photoURL);
      } else {
        throw Exception('No hay usuario autenticado');
      }
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // Obtener UID del usuario actual
  Future<String> obtenerUIDUsuario() async {
    User? usuario = FirebaseAuth.instance.currentUser;
    if (usuario != null) {
      return usuario.uid;
    } else {
      throw Exception("No hay usuario autenticado");
    }
  }

  // Cerrar sesión y navegar al login
  Future<void> signOutAndNavigateToLogin(BuildContext context) async {
    try {
      await _auth.signOut(); // Cerrar sesión en Firebase
      // Navegar al login y reemplazar la pantalla actual
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }
}