class EvaluacionPsicologica {
  // 1. DATOS DE IDENTIFICACIÓN
  String id_paciente;
  DateTime fechaNacimiento;
  int edad;
  String modalidad;
  DateTime fechaIngresoServicio;

  // 2. ANAMNESIS
  String antecedentesPersonales;
  String antecedentesFamiliares;
  String intervencionesAnteriores;

  // 3. EXPLORACIÓN DEL ESTADO MENTAL
  String exploracionEstadoMental;

  // 4. SITUACIÓN ACTUAL
  String situacionActual;

  // 5. RESULTADO DE LAS PRUEBAS APLICADAS O PSICODIAGNÓSTICO
  String resultadoPruebas;

  // 6. CONCLUSIONES
  String conclusiones;

  // 7. RECOMENDACIONES
  String recomendaciones;

  // Constructor
  EvaluacionPsicologica({
    required this.id_paciente,
    required this.fechaNacimiento,
    required this.edad,
    required this.modalidad,
    required this.fechaIngresoServicio,
    required this.antecedentesPersonales,
    required this.antecedentesFamiliares,
    required this.intervencionesAnteriores,
    required this.exploracionEstadoMental,
    required this.situacionActual,
    required this.resultadoPruebas,
    required this.conclusiones,
    required this.recomendaciones,
  });

  // Método para convertir el objeto a un mapa (útil para serialización)
  Map<String, dynamic> toMap() {
    return {
      'id_paciente': id_paciente,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'edad': edad,
      'modalidad': modalidad,
      'fechaIngresoServicio': fechaIngresoServicio.toIso8601String(),
      'antecedentesPersonales': antecedentesPersonales,
      'antecedentesFamiliares': antecedentesFamiliares,
      'intervencionesAnteriores': intervencionesAnteriores,
      'exploracionEstadoMental': exploracionEstadoMental,
      'situacionActual': situacionActual,
      'resultadoPruebas': resultadoPruebas,
      'conclusiones': conclusiones,
      'recomendaciones': recomendaciones,
    };
  }

  // Método para crear un objeto desde un mapa (útil para deserialización)
  factory EvaluacionPsicologica.fromMap(Map<String, dynamic> map) {
    return EvaluacionPsicologica(
      id_paciente: map['id_paciente'],
      fechaNacimiento: DateTime.parse(map['fechaNacimiento']),
      edad: map['edad'],
      modalidad: map['modalidad'],
      fechaIngresoServicio: DateTime.parse(map['fechaIngresoServicio']),
      antecedentesPersonales: map['antecedentesPersonales'],
      antecedentesFamiliares: map['antecedentesFamiliares'],
      intervencionesAnteriores: map['intervencionesAnteriores'],
      exploracionEstadoMental: map['exploracionEstadoMental'],
      situacionActual: map['situacionActual'],
      resultadoPruebas: map['resultadoPruebas'],
      conclusiones: map['conclusiones'],
      recomendaciones: map['recomendaciones'],
    );
  }
}