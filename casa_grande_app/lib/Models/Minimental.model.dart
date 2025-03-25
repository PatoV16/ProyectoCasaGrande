import 'Paciente.model.dart';

class MiniExamen {
  String idPaciente;
  int? orientacionTiempo;
  int? orientacionEspacio;
  int? memoria;
  int? atencionCalculo;
  int? memoriaDiferida;
  int? denominacion;
  int? repeticionFrase;
  int? comprensionEjecucion;
  int? lectura;
  int? escritura;
  int? copiaDibujo;
  int? puntajeTotal;

  MiniExamen({
    required this.idPaciente,
    this.orientacionTiempo,
    this.orientacionEspacio,
    this.memoria,
    this.atencionCalculo,
    this.memoriaDiferida,
    this.denominacion,
    this.repeticionFrase,
    this.comprensionEjecucion,
    this.lectura,
    this.escritura,
    this.copiaDibujo,
    this.puntajeTotal,
  });

  // Método para convertir un JSON a una instancia de MiniExamen
  factory MiniExamen.fromJson(Map<String, dynamic> json) {
    return MiniExamen(
      idPaciente: json['id_paciente'],
      orientacionTiempo: json['orientacion_tiempo'],
      orientacionEspacio: json['orientacion_espacio'],
      memoria: json['memoria'],
      atencionCalculo: json['atencion_calculo'],
      memoriaDiferida: json['memoria_diferida'],
      denominacion: json['denominacion'],
      repeticionFrase: json['repeticion_frase'],
      comprensionEjecucion: json['comprension_ejecucion'],
      lectura: json['lectura'],
      escritura: json['escritura'],
      copiaDibujo: json['copia_dibujo'],
      puntajeTotal: json['puntaje_total'],
    );
  }

  // Método para convertir la instancia a un JSON
  Map<String, dynamic> toJson() {
    return {
      'id_paciente': idPaciente,
      'orientacion_tiempo': orientacionTiempo,
      'orientacion_espacio': orientacionEspacio,
      'memoria': memoria,
      'atencion_calculo': atencionCalculo,
      'memoria_diferida': memoriaDiferida,
      'denominacion': denominacion,
      'repeticion_frase': repeticionFrase,
      'comprension_ejecucion': comprensionEjecucion,
      'lectura': lectura,
      'escritura': escritura,
      'copia_dibujo': copiaDibujo,
      'puntaje_total': puntajeTotal,
    };
  }
}
