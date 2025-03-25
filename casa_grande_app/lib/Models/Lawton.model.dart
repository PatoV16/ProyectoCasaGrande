class LawtonBrody {
  String? idLawtonBrody;
  String idPaciente;
  int usoTelefono;
  int hacerCompras;
  int prepararComida;
  int cuidadoCasa;
  int lavadoRopa;
  int usoTransporte;
  int responsabilidadMedicacion;
  int capacidadDinero;
  int puntajeTotal;
  DateTime? fechaEvaluacion;
  String? observaciones;

  LawtonBrody({
    this.idLawtonBrody,
    required this.idPaciente,
    this.usoTelefono = 0,
    this.hacerCompras = 0,
    this.prepararComida = 0,
    this.cuidadoCasa = 0,
    this.lavadoRopa = 0,
    this.usoTransporte = 0,
    this.responsabilidadMedicacion = 0,
    this.capacidadDinero = 0,
    this.puntajeTotal = 0,
    this.fechaEvaluacion,
    this.observaciones,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_lawton_brody': idLawtonBrody,
      'id_paciente': idPaciente,
      'uso_telefono': usoTelefono,
      'hacer_compras': hacerCompras,
      'preparar_comida': prepararComida,
      'cuidado_casa': cuidadoCasa,
      'lavado_ropa': lavadoRopa,
      'uso_transporte': usoTransporte,
      'responsabilidad_medicacion': responsabilidadMedicacion,
      'capacidad_dinero': capacidadDinero,
      'puntaje_total': puntajeTotal,
      'fecha_evaluacion': fechaEvaluacion?.toIso8601String(),
      'observaciones': observaciones,
    };
  }

  factory LawtonBrody.fromMap(Map<String, dynamic> map) {
    return LawtonBrody(
      idLawtonBrody: map['id_lawton_brody'] as String?,
      idPaciente: map['id_paciente'] as String,
      usoTelefono: map['uso_telefono'] as int? ?? 0,
      hacerCompras: map['hacer_compras'] as int? ?? 0,
      prepararComida: map['preparar_comida'] as int? ?? 0,
      cuidadoCasa: map['cuidado_casa'] as int? ?? 0,
      lavadoRopa: map['lavado_ropa'] as int? ?? 0,
      usoTransporte: map['uso_transporte'] as int? ?? 0,
      responsabilidadMedicacion: map['responsabilidad_medicacion'] as int? ?? 0,
      capacidadDinero: map['capacidad_dinero'] as int? ?? 0,
      puntajeTotal: map['puntaje_total'] as int? ?? 0,
      fechaEvaluacion: map['fecha_evaluacion'] != null
          ? DateTime.tryParse(map['fecha_evaluacion'])
          : null,
      observaciones: map['observaciones'] as String?,
    );
  }
  List<String> get actividades {
  return [
    if (usoTelefono! > 0) "Usa teléfono",
    if (hacerCompras! > 0) "Hace compras",
    if (prepararComida! > 0) "Prepara comida",
    if (cuidadoCasa! > 0) "Cuida la casa",
    if (lavadoRopa! > 0) "Lava la ropa",
    if (usoTransporte! > 0) "Usa transporte",
    if (responsabilidadMedicacion! > 0) "Responsable con medicamentos",
    if (capacidadDinero! > 0) "Maneja dinero",
  ];
}

}
