import 'package:intl/intl.dart'; // Para manejar la fecha en formato adecuado

class Yesavage {
  String idPaciente;
  String zona;
  String distrito;
  String modalidadAtencion;
  String unidadAtencion;
  int edad;
  Map<String, bool> respuestas; // Se utiliza un Map para las respuestas
  DateTime fechaAplicacion; // Usamos DateTime para las fechas
  int puntos;

  Yesavage({
    required this.idPaciente,
    required this.zona,
    required this.distrito,
    required this.modalidadAtencion,
    required this.unidadAtencion,
    required this.edad,
    required this.respuestas,
    required this.fechaAplicacion,
    required this.puntos
  });

  // Método para convertir un JSON a una instancia de Yesavage
 factory Yesavage.fromJson(Map json) {
  return Yesavage(
    idPaciente: json['id_paciente'].toString(),  // Asegurarse de que sea un String
    zona: json['zona'],
    distrito: json['distrito'],
    modalidadAtencion: json['modalidadAtencion'],
    unidadAtencion: json['unidadAtencion'],
    edad: json['edad'],
    respuestas: Map.from(json['respuestas']),
    fechaAplicacion: DateTime.parse(json['fechaAplicacion']),
    puntos: json['puntos'] is int ? json['puntos'] : int.parse(json['puntos'].toString()),  // Asegurar que 'puntos' es int
  );
}



  // Método para convertir una instancia a un JSON
  Map<String, dynamic> toJson() {
    return {
      'id_paciente': idPaciente, // Se convierte el objeto Paciente a JSON si no es nulo
      'zona': zona,
      'distrito': distrito,
      'modalidadAtencion': modalidadAtencion,
      'unidadAtencion': unidadAtencion,
      'edad': edad,
      'respuestas': respuestas,
      'fechaAplicacion': DateFormat('yyyy-MM-dd').format(fechaAplicacion), // Formateamos la fecha
      'puntos': puntos,
    };
  }
 
}
