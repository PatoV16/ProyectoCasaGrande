class FichaSocial {
  String idPaciente;
  
  // Red social de apoyo
  bool? ocupaTiempoLibre;
  String? actividadesTiempoLibre;
  bool? perteneceAsociacion;
  String? nombreOrganizacion;
  String? frecuenciaAcudeAsociacion;
  String? actividadAsociacion;
  
  // Situación económica
  bool? recibePension;
  String? tipoPension;
  bool? tieneOtrosIngresos;
  double? montoOtrosIngresos;
  String? fuenteIngresos;
  String? quienCobraIngresos;
  String? destinoRecursos;
  
  // Vivienda
  String? tipoVivienda;
  String? accesoVivienda;
  
  // Nutrición
  bool? seAlimentaBien;
  int? numeroComidasDiarias;
  String? especificarComidas;
  
  // Salud
  String? estadoSalud;
  bool? enfermedadCatastrofica;
  String? especificarEnfermedad;
  bool? discapacidad;
  bool? tomaMedicamentoConstante;
  String? especificarMedicamento;
  bool? utilizaAyudaTecnica;
  String? especificarAyudaTecnica;
  
  // Servicio que desea ingresar
  bool? deseaServicioResidencial;
  bool? deseaServicioDiurno;
  bool? deseaEspaciosSocializacion;
  bool? deseaAtencionDomiciliaria;
  
  FichaSocial({
    required this.idPaciente,
    this.ocupaTiempoLibre,
    this.actividadesTiempoLibre,
    this.perteneceAsociacion,
    this.nombreOrganizacion,
    this.frecuenciaAcudeAsociacion,
    this.actividadAsociacion,
    this.recibePension,
    this.tipoPension,
    this.tieneOtrosIngresos,
    this.montoOtrosIngresos,
    this.fuenteIngresos,
    this.quienCobraIngresos,
    this.destinoRecursos,
    this.tipoVivienda,
    this.accesoVivienda,
    this.seAlimentaBien,
    this.numeroComidasDiarias,
    this.especificarComidas,
    this.estadoSalud,
    this.enfermedadCatastrofica,
    this.especificarEnfermedad,
    this.discapacidad,
    this.tomaMedicamentoConstante,
    this.especificarMedicamento,
    this.utilizaAyudaTecnica,
    this.especificarAyudaTecnica,
    this.deseaServicioResidencial,
    this.deseaServicioDiurno,
    this.deseaEspaciosSocializacion,
    this.deseaAtencionDomiciliaria,
  });
  
  factory FichaSocial.fromJson(Map<String, dynamic> json) {
    return FichaSocial(
      idPaciente: json['id_paciente'],
      ocupaTiempoLibre: json['ocupa_tiempo_libre'],
      actividadesTiempoLibre: json['actividades_tiempo_libre'],
      perteneceAsociacion: json['pertenece_asociacion'],
      nombreOrganizacion: json['nombre_organizacion'],
      frecuenciaAcudeAsociacion: json['frecuencia_acude_asociacion'],
      actividadAsociacion: json['actividad_asociacion'],
      recibePension: json['recibe_pension'],
      tipoPension: json['tipo_pension'],
      tieneOtrosIngresos: json['tiene_otros_ingresos'],
      montoOtrosIngresos: json['monto_otros_ingresos']?.toDouble(),
      fuenteIngresos: json['fuente_ingresos'],
      quienCobraIngresos: json['quien_cobra_ingresos'],
      destinoRecursos: json['destino_recursos'],
      tipoVivienda: json['tipo_vivienda'],
      accesoVivienda: json['acceso_vivienda'],
      seAlimentaBien: json['se_alimenta_bien'],
      numeroComidasDiarias: json['numero_comidas_diarias'],
      especificarComidas: json['especificar_comidas'],
      estadoSalud: json['estado_salud'],
      enfermedadCatastrofica: json['enfermedad_catastrofica'],
      especificarEnfermedad: json['especificar_enfermedad'],
      discapacidad: json['discapacidad'],
      tomaMedicamentoConstante: json['toma_medicamento_constante'],
      especificarMedicamento: json['especificar_medicamento'],
      utilizaAyudaTecnica: json['utiliza_ayuda_tecnica'],
      especificarAyudaTecnica: json['especificar_ayuda_tecnica'],
      deseaServicioResidencial: json['desea_servicio_residencial'],
      deseaServicioDiurno: json['desea_servicio_diurno'],
      deseaEspaciosSocializacion: json['desea_espacios_socializacion'],
      deseaAtencionDomiciliaria: json['desea_atencion_domiciliaria'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id_paciente': idPaciente,
      'ocupa_tiempo_libre': ocupaTiempoLibre,
      'actividades_tiempo_libre': actividadesTiempoLibre,
      'pertenece_asociacion': perteneceAsociacion,
      'nombre_organizacion': nombreOrganizacion,
      'frecuencia_acude_asociacion': frecuenciaAcudeAsociacion,
      'actividad_asociacion': actividadAsociacion,
      'recibe_pension': recibePension,
      'tipo_pension': tipoPension,
      'tiene_otros_ingresos': tieneOtrosIngresos,
      'monto_otros_ingresos': montoOtrosIngresos,
      'fuente_ingresos': fuenteIngresos,
      'quien_cobra_ingresos': quienCobraIngresos,
      'destino_recursos': destinoRecursos,
      'tipo_vivienda': tipoVivienda,
      'acceso_vivienda': accesoVivienda,
      'se_alimenta_bien': seAlimentaBien,
      'numero_comidas_diarias': numeroComidasDiarias,
      'especificar_comidas': especificarComidas,
      'estado_salud': estadoSalud,
      'enfermedad_catastrofica': enfermedadCatastrofica,
      'especificar_enfermedad': especificarEnfermedad,
      'discapacidad': discapacidad,
      'toma_medicamento_constante': tomaMedicamentoConstante,
      'especificar_medicamento': especificarMedicamento,
      'utiliza_ayuda_tecnica': utilizaAyudaTecnica,
      'especificar_ayuda_tecnica': especificarAyudaTecnica,
      'desea_servicio_residencial': deseaServicioResidencial,
      'desea_servicio_diurno': deseaServicioDiurno,
      'desea_espacios_socializacion': deseaEspaciosSocializacion,
      'desea_atencion_domiciliaria': deseaAtencionDomiciliaria,
    };
  }
}
