class KardexGerontologico {
  final String id;
  final String idPaciente;
  final int edad;
  final String numeroHistoriaClinica;
  final String numeroArchivo;
  final bool tieneAlergiaMedicamentos;
  final String? descripcionAlergia;
  final List<Medicamento> medicamentos;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  KardexGerontologico({
    required this.id,
    required this.idPaciente,
    required this.edad,
    required this.numeroHistoriaClinica,
    required this.numeroArchivo,
    required this.tieneAlergiaMedicamentos,
    this.descripcionAlergia,
    required this.medicamentos,
    required this.fechaCreacion,
    this.fechaActualizacion,
  });

  factory KardexGerontologico.fromMap(Map<String, dynamic> map, String id) {
    return KardexGerontologico(
      id: id,
      idPaciente: map['idPaciente'] ?? '',
      edad: map['edad'] ?? 0,
      numeroHistoriaClinica: map['numeroHistoriaClinica'] ?? '',
      numeroArchivo: map['numeroArchivo'] ?? '',
      tieneAlergiaMedicamentos: map['tieneAlergiaMedicamentos'] ?? false,
      descripcionAlergia: map['descripcionAlergia'],
      medicamentos: List<Medicamento>.from(
        (map['medicamentos'] ?? []).map((x) => Medicamento.fromMap(x))),
      fechaCreacion: DateTime.fromMillisecondsSinceEpoch(map['fechaCreacion']),
      fechaActualizacion: map['fechaActualizacion'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['fechaActualizacion']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idPaciente': idPaciente,
      'edad': edad,
      'numeroHistoriaClinica': numeroHistoriaClinica,
      'numeroArchivo': numeroArchivo,
      'tieneAlergiaMedicamentos': tieneAlergiaMedicamentos,
      'descripcionAlergia': descripcionAlergia,
      'medicamentos': medicamentos.map((x) => x.toMap()).toList(),
      'fechaCreacion': fechaCreacion.millisecondsSinceEpoch,
      'fechaActualizacion': fechaActualizacion?.millisecondsSinceEpoch,
    };
  }
}

class Medicamento {
  final String nombre;
  final DateTime fecha;
  final String dosis;
  final String via;
  final String frecuencia;
  final List<Administracion> administraciones;

  Medicamento({
    required this.nombre,
    required this.fecha,
    required this.dosis,
    required this.via,
    required this.frecuencia,
    required this.administraciones,
  });

  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      nombre: map['nombre'] ?? '',
      fecha: DateTime.fromMillisecondsSinceEpoch(map['fecha']),
      dosis: map['dosis'] ?? '',
      via: map['via'] ?? '',
      frecuencia: map['frecuencia'] ?? '',
      administraciones: List<Administracion>.from(
        (map['administraciones'] ?? []).map((x) => Administracion.fromMap(x))),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'fecha': fecha.millisecondsSinceEpoch,
      'dosis': dosis,
      'via': via,
      'frecuencia': frecuencia,
      'administraciones': administraciones.map((x) => x.toMap()).toList(),
    };
  }
}

class Administracion {
  final String hora;
  final String responsable;

  Administracion({
    required this.hora,
    required this.responsable,
  });

  factory Administracion.fromMap(Map<String, dynamic> map) {
    return Administracion(
      hora: map['hora'] ?? '',
      responsable: map['responsable'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hora': hora,
      'responsable': responsable,
    };
  }
}