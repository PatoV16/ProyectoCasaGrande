import 'package:cloud_firestore/cloud_firestore.dart';
class Asistencia {
  String? id; // ID de Firebase
  String idPaciente; // Referencia al paciente
  String semanaInicio; // Semana del (inicio)
  String semanaFin; // Semana hasta (fin)
  String mes; // Mes
  String anio; // Año
  String horarioTrabajo; // Horario de trabajo
  String nombreCentro; // Nombre del centro
  String modalidadAtencion; // Modalidad de atención
  String distrito; // Distrito
  List<bool> diasAsistencia; // Días de asistencia

  Asistencia({
    this.id,
    required this.idPaciente,
    required this.semanaInicio,
    required this.semanaFin,
    required this.mes,
    required this.anio,
    required this.horarioTrabajo,
    required this.nombreCentro,
    required this.modalidadAtencion,
    required this.distrito,
    required this.diasAsistencia,
  });

  // Convertir objeto a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id_paciente': idPaciente,
      'semana_inicio': semanaInicio,
      'semana_fin': semanaFin,
      'mes': mes,
      'anio': anio,
      'horario_trabajo': horarioTrabajo,
      'nombre_centro': nombreCentro,
      'modalidad_atencion': modalidadAtencion,
      'distrito': distrito,
      'dias_asistencia': diasAsistencia,
    };
  }

  // Crear objeto desde snapshot de Firestore
  factory Asistencia.fromMap(Map<String, dynamic> map, String documentId) {
    return Asistencia(
      id: documentId,
      idPaciente: map['id_paciente'] ?? '',
      semanaInicio: map['semana_inicio'] ?? '',
      semanaFin: map['semana_fin'] ?? '',
      mes: map['mes'] ?? '',
      anio: map['anio'] ?? '',
      horarioTrabajo: map['horario_trabajo'] ?? '',
      nombreCentro: map['nombre_centro'] ?? '',
      modalidadAtencion: map['modalidad_atencion'] ?? '',
      distrito: map['distrito'] ?? '',
      diasAsistencia: List<bool>.from(map['dias_asistencia'] ?? []),
    );
  }
}