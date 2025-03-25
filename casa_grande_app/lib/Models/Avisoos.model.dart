  import 'package:cloud_firestore/cloud_firestore.dart';

  class Aviso {
    String id;
    String titulo;
    String descripcion;
    String? imagenUrl;
    DateTime fechaCreacion;
    DateTime fechaExpiracion;
    bool activo;

    Aviso({
      required this.id,
      required this.titulo,
      required this.descripcion,
      this.imagenUrl,
      required this.fechaCreacion,
      required this.fechaExpiracion,
      this.activo = true,
    });

    factory Aviso.crear({
      required String titulo,
      required String descripcion,
      String? imagenUrl,
    }) {
      final ahora = DateTime.now();
      // Por defecto, el aviso expira en 7 días
      final expiracion = ahora.add(Duration(days: 7));
      
      return Aviso(
        id: '', // El ID será asignado por Firebase
        titulo: titulo,
        descripcion: descripcion,
        imagenUrl: imagenUrl,
        fechaCreacion: ahora,
        fechaExpiracion: expiracion,
        activo: true,
      );
    }

    // Convertir Aviso a un Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion), // 👈 Convertir a Timestamp
      'fechaExpiracion': Timestamp.fromDate(fechaExpiracion), // 👈 Convertir a Timestamp
      'activo': activo,
    };
  }


    // Crear un Aviso desde un Map (documento de Firestore)
    factory Aviso.fromMap(String id, Map<String, dynamic> map) {
      return Aviso(
        id: id,
        titulo: map['titulo'],
        descripcion: map['descripcion'],
        imagenUrl: map['imagenUrl'],
      fechaCreacion: map['fechaCreacion'] != null
      ? (map['fechaCreacion'] as Timestamp).toDate()
      : DateTime.now(),
  fechaExpiracion: map['fechaExpiracion'] != null
      ? (map['fechaExpiracion'] as Timestamp).toDate()
      : DateTime.now().add(Duration(days: 7)),

        activo: map['activo'],
      );
    }

    // Verificar si el aviso ha expirado
    bool get haExpirado => DateTime.now().isAfter(fechaExpiracion);
  }