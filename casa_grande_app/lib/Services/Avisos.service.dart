import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../Models/Avisoos.model.dart';

class AvisoService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _avisosCollection =
      FirebaseFirestore.instance.collection('avisos');

  /// 🔹 Crear un nuevo aviso y guardarlo como documento normal en Firestore
  Future<Aviso> crearAviso({
  required String titulo,
  required String descripcion,
  File? imagen,
}) async {
  try {
    String? imagenUrl;
    if (imagen != null) {
      imagenUrl = await _subirImagen(imagen);
    }

    final aviso = Aviso.crear(
      titulo: titulo,
      descripcion: descripcion,
      imagenUrl: imagenUrl,
    );

    // Usar add() para que Firestore genere automáticamente el ID
    final docRef = await _avisosCollection.add(aviso.toMap());
    print("✅ Aviso guardado con ID: ${docRef.id}");

    // Asignar el ID generado a tu objeto Aviso
    return Aviso.fromMap(docRef.id, aviso.toMap());
  } catch (e) {
    print('❌ Error al crear aviso: $e');
    rethrow;
  }
}


  /// 🔹 Obtener un aviso por ID
  Future<Aviso?> obtenerAvisoPorId(String id) async {
    try {
      final doc = await _avisosCollection.doc(id).get();
      if (doc.exists) {
        return Aviso.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        print("❌ No se encontró el aviso con ID: $id");
        return null;
      }
    } catch (e) {
      print("❌ Error al obtener el aviso: $e");
      return null;
    }
  }

  /// 🔹 Obtener todos los avisos sin índices
  Future<List<Aviso>> obtenerTodosLosAvisos() async {
    try {
      final snapshot = await _avisosCollection.get();
      List<Aviso> avisos = snapshot.docs
          .map((doc) => Aviso.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // Ordenar los avisos manualmente por fecha de expiración
      avisos.sort((a, b) => a.fechaExpiracion.compareTo(b.fechaExpiracion));

      return avisos;
    } catch (e) {
      print("❌ Error al obtener los avisos: $e");
      return [];
    }
  }

  /// 🔹 Actualizar un aviso existente
  Future<void> actualizarAviso(Aviso aviso) async {
    try {
      await _avisosCollection.doc(aviso.id).update(aviso.toMap());
      print("✅ Aviso actualizado con ID: ${aviso.id}");
    } catch (e) {
      print("❌ Error al actualizar el aviso: $e");
    }
  }

  /// 🔹 Eliminar un aviso y su imagen (si existe)
  Future<void> eliminarAviso(String avisoId) async {
    try {
      final doc = await _avisosCollection.doc(avisoId).get();
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      if (data['imagenUrl'] != null) {
        await _eliminarImagen(data['imagenUrl']);
      }

      await _avisosCollection.doc(avisoId).delete();
      print("✅ Aviso eliminado con ID: $avisoId");
    } catch (e) {
      print("❌ Error al eliminar aviso: $e");
      rethrow;
    }
  }

  /// 🔹 Subir una imagen a Firebase Storage
  Future<String> _subirImagen(File imagen) async {
    try {
      final uuid = Uuid();
      final nombreArchivo = '${uuid.v4()}.jpg';
      final ref = _storage.ref().child('avisos/$nombreArchivo');

      await ref.putFile(imagen);
      return await ref.getDownloadURL();
    } catch (e) {
      print('❌ Error al subir imagen: $e');
      rethrow;
    }
  }

  /// 🔹 Eliminar una imagen de Firebase Storage
  Future<void> _eliminarImagen(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print("✅ Imagen eliminada: $imageUrl");
    } catch (e) {
      print('❌ Error al eliminar imagen de Storage: $e');
    }
  }
}
