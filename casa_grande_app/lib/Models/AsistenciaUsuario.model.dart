class AsistenciaUsuario{
  String id;
  String idEmpleado;
  DateTime fechaHora;
  double latitud;
  double longitud;
  String direccion;
  String tipoAsistencia;

  AsistenciaUsuario({
    required this.id,
    required this.idEmpleado,
    required this.fechaHora,
    required this.latitud,
    required this.longitud,
    required this.direccion,
    required this.tipoAsistencia,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idEmpleado': idEmpleado,
      'fechaHora': fechaHora.toIso8601String(),
      'latitud': latitud,
      'longitud': longitud,
      'direccion': direccion,
      'tipoAsistencia': tipoAsistencia,
    };
  }

  // Crear una instancia desde Firestore
  factory AsistenciaUsuario.fromMap(Map<String, dynamic> map, String documentId) {
    return AsistenciaUsuario(
      id: documentId,
      idEmpleado: map['idEmpleado'],
      fechaHora: DateTime.parse(map['fechaHora']),
      latitud: map['latitud'],
      longitud: map['longitud'],
      direccion: map['direccion'],
      tipoAsistencia: map['tipoAsistencia'],
    );
  }
}
  