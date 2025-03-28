import 'package:cloud_firestore/cloud_firestore.dart';

class Evolucion {
  String id;
  String idPaciente;
  DateTime fechaHora;
  String areaServicio;
  List<String> actividades;
  String evolucion;
  String observaciones;
  String recomendaciones;
  String tipoFicha;

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

  Map<String, dynamic> toMap() {
    return {
      'idPaciente': idPaciente,
      'fechaHora': fechaHora.toIso8601String(), // Guardamos como String para evitar índices de Firestore
      'areaServicio': areaServicio,
      'actividades': actividades,
      'evolucion': evolucion,
      'observaciones': observaciones,
      'recomendaciones': recomendaciones,
      'tipoFicha': tipoFicha,
    };
  }

  factory Evolucion.fromMap(String id, Map<String, dynamic> map) {
    return Evolucion(
      id: id,
      idPaciente: map['idPaciente'],
      fechaHora: DateTime.parse(map['fechaHora']), // Convertimos desde String
      areaServicio: map['areaServicio'],
      actividades: List<String>.from(map['actividades'] ?? []),
      evolucion: map['evolucion'],
      observaciones: map['observaciones'],
      recomendaciones: map['recomendaciones'],
      tipoFicha: map['tipoFicha'],
    );
  }
}