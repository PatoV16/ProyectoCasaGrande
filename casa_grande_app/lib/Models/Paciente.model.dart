class Paciente {
  int? id;
  String nombre;
  String apellido;
  String cedula;
  DateTime fechaNacimiento;
  String estadoCivil;
  String nivelInstruccion;
  String profesionOcupacion;
  String telefono;
  String direccion;
  DateTime fechaIngreso;

  Paciente({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.cedula,
    required this.fechaNacimiento,
    required this.estadoCivil,
    required this.nivelInstruccion,
    required this.profesionOcupacion,
    required this.telefono,
    required this.direccion,
    required this.fechaIngreso,
  });

  // Convertir a JSON (para Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id_paciente': id,
      'nombre': nombre,
      'apellido': apellido,
      'cedula': cedula,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'estado_civil': estadoCivil,
      'nivel_instruccion': nivelInstruccion,
      'profesion_ocupacion': profesionOcupacion,
      'telefono': telefono,
      'direccion': direccion,
      'fecha_ingreso': fechaIngreso.toIso8601String(),
    };
  }

  // Crear desde JSON (para obtener datos de Firebase)
  factory Paciente.fromJson(Map<String, dynamic> json) {
  return Paciente(
    id: json['id_paciente'] as int?, // Puede ser null y está permitido
    nombre: json['nombre'] ?? '', // Si es null, asigna cadena vacía
    apellido: json['apellido'] ?? '',
    cedula: json['cedula'] ?? '',
    fechaNacimiento: json['fecha_nacimiento'] != null
        ? DateTime.parse(json['fecha_nacimiento'])
        : DateTime.now(), // Si es null, usa una fecha por defecto
    estadoCivil: json['estado_civil'] ?? '',
    nivelInstruccion: json['nivel_instruccion'] ?? '',
    profesionOcupacion: json['profesion_ocupacion'] ?? '',
    telefono: json['telefono'] ?? '',
    direccion: json['direccion'] ?? '',
    fechaIngreso: json['fecha_ingreso'] != null
        ? DateTime.parse(json['fecha_ingreso'])
        : DateTime.now(),
  );
}
// Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'id_paciente': id,
      'nombre': nombre,
      'apellido': apellido,
      'cedula': cedula,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'estado_civil': estadoCivil,
      'nivel_instruccion': nivelInstruccion,
      'profesion_ocupacion': profesionOcupacion,
      'telefono': telefono,
      'direccion': direccion,
      'fecha_ingreso': fechaIngreso.toIso8601String(),
    };
  }

  // Crear desde Map
  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      id: map['id_paciente'] as int?,
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      cedula: map['cedula'] ?? '',
      fechaNacimiento: map['fecha_nacimiento'] != null
          ? DateTime.parse(map['fecha_nacimiento'])
          : DateTime.now(),
      estadoCivil: map['estado_civil'] ?? '',
      nivelInstruccion: map['nivel_instruccion'] ?? '',
      profesionOcupacion: map['profesion_ocupacion'] ?? '',
      telefono: map['telefono'] ?? '',
      direccion: map['direccion'] ?? '',
      fechaIngreso: map['fecha_ingreso'] != null
          ? DateTime.parse(map['fecha_ingreso'])
          : DateTime.now(),
    );
  }
}
