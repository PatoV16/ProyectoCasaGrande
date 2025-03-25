import 'package:cloud_firestore/cloud_firestore.dart';

class ActaCompromiso {
  String id; // ID de Firestore
  String nombreCompleto;
  String cedulaIdentidad;
  String telefono;
  String direccion;
  DateTime fechaCreacion;
  String idPaciente; // Relación con paciente

  ActaCompromiso({
    this.id = '',
    required this.nombreCompleto,
    required this.cedulaIdentidad,
    required this.telefono,
    required this.direccion,
    required this.fechaCreacion,
    required this.idPaciente,
  });

  // Convertir objeto a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre_completo': nombreCompleto,
      'cedula_identidad': cedulaIdentidad,
      'telefono': telefono,
      'direccion': direccion,
      'fecha_creacion': Timestamp.fromDate(fechaCreacion),
      'id_paciente': idPaciente,
    };
  }

  // Crear objeto desde snapshot de Firestore
  factory ActaCompromiso.fromMap(Map<String, dynamic> map, String documentId) {
    return ActaCompromiso(
      id: documentId,
      nombreCompleto: map['nombre_completo'] ?? '',
      cedulaIdentidad: map['cedula_identidad'] ?? '',
      telefono: map['telefono'] ?? '',
      direccion: map['direccion'] ?? '',
      fechaCreacion: (map['fecha_creacion'] as Timestamp).toDate(),
      idPaciente: map['id_paciente'] ?? '',
    );
  }
}
