import 'package:cloud_firestore/cloud_firestore.dart';

class SignosVitales {
  String id; // ID de Firestore
  String idPaciente; // Relación con paciente
  double temperatura; // en °C
  int frecuenciaCardiaca; // en bpm
  int frecuenciaRespiratoria; // en rpm
  int presionSistolica; // mmHg
  int presionDiastolica; // mmHg
  int saturacionOxigeno; // en %
  double peso; // en kg
  double talla; // en metros
  DateTime fechaRegistro;

  SignosVitales({
    this.id = '',
    required this.idPaciente,
    required this.temperatura,
    required this.frecuenciaCardiaca,
    required this.frecuenciaRespiratoria,
    required this.presionSistolica,
    required this.presionDiastolica,
    required this.saturacionOxigeno,
    required this.peso,
    required this.talla,
    required this.fechaRegistro,
  });

  // Convertir objeto a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id_paciente': idPaciente,
      'temperatura': temperatura,
      'frecuencia_cardiaca': frecuenciaCardiaca,
      'frecuencia_respiratoria': frecuenciaRespiratoria,
      'presion_sistolica': presionSistolica,
      'presion_diastolica': presionDiastolica,
      'saturacion_oxigeno': saturacionOxigeno,
      'peso': peso,
      'talla': talla,
      'fecha_registro': Timestamp.fromDate(fechaRegistro),
    };
  }

  // Crear objeto desde snapshot de Firestore
  factory SignosVitales.fromMap(Map<String, dynamic> map, String documentId) {
    return SignosVitales(
      id: documentId,
      idPaciente: map['id_paciente'] ?? '',
      temperatura: (map['temperatura'] ?? 0).toDouble(),
      frecuenciaCardiaca: map['frecuencia_cardiaca'] ?? 0,
      frecuenciaRespiratoria: map['frecuencia_respiratoria'] ?? 0,
      presionSistolica: map['presion_sistolica'] ?? 0,
      presionDiastolica: map['presion_diastolica'] ?? 0,
      saturacionOxigeno: map['saturacion_oxigeno'] ?? 0,
      peso: (map['peso'] ?? 0).toDouble(),
      talla: (map['talla'] ?? 0).toDouble(),
      fechaRegistro: (map['fecha_registro'] as Timestamp).toDate(),
    );
  }
}
