class Barthel {
  String? idBarthel;
  String idPaciente;
  int? comer;
  int? traslado;
  int? aseoPersonal;
  int? usoRetrete;
  int? banarse;
  int? desplazarse;
  int? subirEscaleras;
  int? vestirse;
  int? controlHeces;
  int? controlOrina;
  int? puntajeTotal;
  DateTime? fechaEvaluacion;
  String? observaciones;

  Barthel({
    this.idBarthel,
    required this.idPaciente,
    this.comer,
    this.traslado,
    this.aseoPersonal,
    this.usoRetrete,
    this.banarse,
    this.desplazarse,
    this.subirEscaleras,
    this.vestirse,
    this.controlHeces,
    this.controlOrina,
    this.puntajeTotal,
    this.fechaEvaluacion,
    this.observaciones,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_barthel': idBarthel,
      'id_paciente': idPaciente,
      'comer': comer,
      'traslado': traslado,
      'aseo_personal': aseoPersonal,
      'uso_retrete': usoRetrete,
      'banarse': banarse,
      'desplazarse': desplazarse,
      'subir_escaleras': subirEscaleras,
      'vestirse': vestirse,
      'control_heces': controlHeces,
      'control_orina': controlOrina,
      'puntaje_total': puntajeTotal,
      'fecha_evaluacion': fechaEvaluacion?.toIso8601String(), // Guardamos como String ISO
      'observaciones': observaciones,
    };
  }

  factory Barthel.fromMap(Map<String, dynamic> map) {
    return Barthel(
      idBarthel: map['id_barthel'] as String?,
      idPaciente: map['id_paciente'] as String,
      comer: map['comer'] as int?,
      traslado: map['traslado'] as int?,
      aseoPersonal: map['aseo_personal'] as int?,
      usoRetrete: map['uso_retrete'] as int?,
      banarse: map['banarse'] as int?,
      desplazarse: map['desplazarse'] as int?,
      subirEscaleras: map['subir_escaleras'] as int?,
      vestirse: map['vestirse'] as int?,
      controlHeces: map['control_heces'] as int?,
      controlOrina: map['control_orina'] as int?,
      puntajeTotal: map['puntaje_total'] as int?,
      fechaEvaluacion: map['fecha_evaluacion'] != null
          ? DateTime.parse(map['fecha_evaluacion'])
          : null,
      observaciones: map['observaciones'] as String?,
    );
  }
}
