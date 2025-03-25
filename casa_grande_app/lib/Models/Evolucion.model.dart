import 'package:cloud_firestore/cloud_firestore.dart';

class Evolucion {
  String id;  // ID único de la evolución
  String idPaciente;  // ID del paciente al que pertenece la evolución
  DateTime fechaHora;  // Fecha y hora de la evolución
  String areaServicio;  // Área o servicio prestado durante la evolución
  List<String> actividades;  // Lista de actividades realizadas en la evolución
  String evolucion;  // Descripción de la evolución del paciente
  String observaciones;  // Observaciones sobre el estado del paciente
  String recomendaciones;  // Recomendaciones para el tratamiento futuro
  String tipoFicha;  // Tipo de ficha (consulta general, urgencias, etc.)

  Evolucion({
    required this.id,
    required this.idPaciente,
    required this.fechaHora,
    required this.areaServicio,
    required this.actividades,
    required this.evolucion,
    required this.observaciones,
    required this.recomendaciones,
    required this.tipoFicha,
  });

  // Convertir Evolucion a un Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'idPaciente': idPaciente,
      'fechaHora': Timestamp.fromDate(fechaHora),  // Convertir a Timestamp de Firestore
      'areaServicio': areaServicio,
      'actividades': actividades,
      'evolucion': evolucion,
      'observaciones': observaciones,
      'recomendaciones': recomendaciones,
      'tipoFicha': tipoFicha,  // Guardar el tipo de ficha
    };
  }

  // Crear un objeto Evolucion desde un mapa (documento de Firestore)
  factory Evolucion.fromMap(String id, Map<String, dynamic> map) {
    return Evolucion(
      id: id,
      idPaciente: map['idPaciente'],
      fechaHora: (map['fechaHora'] as Timestamp).toDate(),
      areaServicio: map['areaServicio'],
      actividades: List<String>.from(map['actividades']),
      evolucion: map['evolucion'],
      observaciones: map['observaciones'],
      recomendaciones: map['recomendaciones'],
      tipoFicha: map['tipoFicha'],  // Obtener el tipo de ficha del mapa
    );
  }

  
}
