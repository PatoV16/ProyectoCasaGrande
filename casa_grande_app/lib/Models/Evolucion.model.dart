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
      'fechaHora': fechaHora, // Puedes dejarlo como DateTime o usar toIso8601String()
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
      idPaciente: map['idPaciente'] ?? '',
      fechaHora: map['fechaHora'] is Timestamp 
          ? (map['fechaHora'] as Timestamp).toDate()
          : DateTime.parse(map['fechaHora']),
      areaServicio: map['areaServicio'] ?? '',
      actividades: List<String>.from(map['actividades'] ?? []),
      evolucion: map['evolucion'] ?? '',
      observaciones: map['observaciones'] ?? '',
      recomendaciones: map['recomendaciones'] ?? '',
      tipoFicha: map['tipoFicha'] ?? '',
    );
  }

  // Método fromJson para crear desde un Map
  factory Evolucion.fromJson(Map<String, dynamic> json) {
    return Evolucion.fromMap(json['id'] ?? '', json);
  }

  // Método toJson para convertir a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      ...toMap(), // Incluye todos los campos de toMap()
    };
  }

  // Método especial para DocumentSnapshot de Firestore
  factory Evolucion.fromFirestore(DocumentSnapshot doc) {
    return Evolucion.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}