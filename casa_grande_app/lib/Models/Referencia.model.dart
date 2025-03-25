import 'Paciente.model.dart';

class Referencia {
  int? id;
  Paciente idPaciente;
  String zona;
  String distrito;
  String ciudad;
  String canton;
  String parroquia;
  String nombreInstitucion;
  String direccion;
  String telefono;
  String razonSocial;
  String directorCoordinador;
  String familiarAcompanante;
  String institucionTransfiere;
  String modalidadServicios;
  String motivoReferencia;
  String profesionalRefiere;
  String personalAcompanante;
  String telefonoFijo;
  String telefonoCelular;
  String recomendaciones;
  DateTime fecha;

  Referencia({
    this.id,
    required this.idPaciente,
    required this.zona,
    required this.distrito,
    required this.ciudad,
    required this.canton,
    required this.parroquia,
    required this.nombreInstitucion,
    required this.direccion,
    required this.telefono,
    required this.razonSocial,
    required this.directorCoordinador,
    required this.familiarAcompanante,
    required this.institucionTransfiere,
    required this.modalidadServicios,
    required this.motivoReferencia,
    required this.profesionalRefiere,
    required this.personalAcompanante,
    required this.telefonoFijo,
    required this.telefonoCelular,
    required this.recomendaciones,
    required this.fecha,
  });

  // Método para convertir un JSON en un objeto Referencia
  factory Referencia.fromJson(Map<String, dynamic> json) {
    return Referencia(
      id: json['id'],
      idPaciente: Paciente.fromJson(json['id_paciente']),
      zona: json['zona'],
      distrito: json['distrito'],
      ciudad: json['ciudad'],
      canton: json['canton'],
      parroquia: json['parroquia'],
      nombreInstitucion: json['nombreInstitucion'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      razonSocial: json['razonSocial'],
      directorCoordinador: json['directorCoordinador'],
      familiarAcompanante: json['familiarAcompanante'],
      institucionTransfiere: json['institucionTransfiere'],
      modalidadServicios: json['modalidadServicios'],
      motivoReferencia: json['motivoReferencia'],
      profesionalRefiere: json['profesionalRefiere'],
      personalAcompanante: json['personalAcompanante'],
      telefonoFijo: json['telefonoFijo'],
      telefonoCelular: json['telefonoCelular'],
      recomendaciones: json['recomendaciones'],
      fecha: DateTime.parse(json['fecha']),
    );
  }

  // Método para convertir un objeto Referencia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_paciente': idPaciente.toJson(),
      'zona': zona,
      'distrito': distrito,
      'ciudad': ciudad,
      'canton': canton,
      'parroquia': parroquia,
      'nombreInstitucion': nombreInstitucion,
      'direccion': direccion,
      'telefono': telefono,
      'razonSocial': razonSocial,
      'directorCoordinador': directorCoordinador,
      'familiarAcompanante': familiarAcompanante,
      'institucionTransfiere': institucionTransfiere,
      'modalidadServicios': modalidadServicios,
      'motivoReferencia': motivoReferencia,
      'profesionalRefiere': profesionalRefiere,
      'personalAcompanante': personalAcompanante,
      'telefonoFijo': telefonoFijo,
      'telefonoCelular': telefonoCelular,
      'recomendaciones': recomendaciones,
      'fecha': fecha.toIso8601String(),
    };
  }
}
