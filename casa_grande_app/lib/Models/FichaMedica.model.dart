class FichaMedica {
  String? idFichaMedica;
  String idPaciente;
  String idEmpleado;
  String? condicionFisica;
  String? condicionPsicologica;
  String? estadoSalud;
  String? medicamentos;
  String? intoleranciaMedicamentos;
  String? referidoPor;
  String? viveCon;
  String? relacionesFamiliares;
  String? observaciones;

  FichaMedica({
    this.idFichaMedica,
    required this.idPaciente,
    required this.idEmpleado,
    this.condicionFisica,
    this.condicionPsicologica,
    this.estadoSalud,
    this.medicamentos,
    this.intoleranciaMedicamentos,
    this.referidoPor,
    this.viveCon,
    this.relacionesFamiliares,
    this.observaciones,
  });

  // Convertir el objeto a un Mapa (para bases de datos locales, SQLite, etc.)
  Map<String, dynamic> toMap() {
    return {
      'id_ficha_medica': idFichaMedica,
      'id_paciente': idPaciente,
      'id_empleado': idEmpleado,
      'condicion_fisica': condicionFisica,
      'condicion_psicologica': condicionPsicologica,
      'estado_salud': estadoSalud,
      'medicamentos': medicamentos,
      'intolerancia_medicamentos': intoleranciaMedicamentos,
      'referido_por': referidoPor,
      'vive_con': viveCon,
      'relaciones_familiares': relacionesFamiliares,
      'observaciones': observaciones,
    };
  }

  // Convertir a JSON (para Firestore o API REST)
  Map<String, dynamic> toJson() {
    return toMap(); // Mismo formato que `toMap()`, se pueden unificar
  }

  // Crear una instancia desde un Mapa o JSON
  factory FichaMedica.fromMap(Map<String, dynamic> map) {
    return FichaMedica(
      idFichaMedica: map['id_ficha_medica'] as String?,
      idPaciente: map['id_paciente'] as String,
      idEmpleado: map['id_empleado'] as String,
      condicionFisica: map['condicion_fisica'] as String?,
      condicionPsicologica: map['condicion_psicologica'] as String?,
      estadoSalud: map['estado_salud'] as String?,
      medicamentos: map['medicamentos'] as String?,
      intoleranciaMedicamentos: map['intolerancia_medicamentos'] as String?,
      referidoPor: map['referido_por'] as String?,
      viveCon: map['vive_con'] as String?,
      relacionesFamiliares: map['relaciones_familiares'] as String?,
      observaciones: map['observaciones'] as String?,
    );
  }

  // Alias para fromMap en caso de trabajar con Firestore
  factory FichaMedica.fromJson(Map<String, dynamic> json) {
    return FichaMedica.fromMap(json);
  }
}
