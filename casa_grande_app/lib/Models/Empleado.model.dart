  import 'package:cloud_firestore/cloud_firestore.dart';

  class Empleado {
    String id; // ID de Firebase
    String nombre;
    String apellido;
    String cedula;
    String cargo;
    DateTime? fechaContratacion; // Permite que sea nullable
    String telefono;
    String correo;
    String estado;

    Empleado({
      this.id = '',
      required this.nombre,
      required this.apellido,
      required this.cedula,
      required this.cargo,
      this.fechaContratacion, // Ahora es nullable
      required this.telefono,
      required this.correo,
      required this.estado,
    });

    // Convertir objeto a mapa para Firestore
    Map<String, dynamic> toMap() {
      return {
        'nombre': nombre,
        'apellido': apellido,
        'cedula': cedula,
        'cargo': cargo,
        'fecha_contratacion': fechaContratacion != null
            ? Timestamp.fromDate(fechaContratacion!)
            : null, // Manejo de null
        'telefono': telefono,
        'correo': correo,
        'estado': estado,
      };
    }

    // Crear objeto desde snapshot de Firestore
    factory Empleado.fromMap(Map<String, dynamic> map, String documentId) {
      return Empleado(
        id: documentId,
        nombre: map['nombre'] ?? '',
        apellido: map['apellido'] ?? '',
        cedula: map['cedula'] ?? '',
        cargo: map['cargo'] ?? '',
        fechaContratacion: map['fecha_contratacion'] != null
            ? (map['fecha_contratacion'] as Timestamp).toDate()
            : null, // Manejo de null
        telefono: map['telefono'] ?? '',
        correo: map['correo'] ?? '',
        estado: map['estado'] ?? 'Activo',
      );
    }
  }