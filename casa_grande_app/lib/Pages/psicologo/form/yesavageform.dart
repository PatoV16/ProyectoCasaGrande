import 'package:flutter/material.dart';
import '../../../Models/Yesavage.model.dart';
import '../../../Services/Yesavage.service.dart';

class YesavageForm extends StatefulWidget {
  final String idPaciente;

  const YesavageForm({Key? key, required this.idPaciente}) : super(key: key);

  @override
  _YesavageFormState createState() => _YesavageFormState();
}

class _YesavageFormState extends State<YesavageForm> {
  final YesavageService yesavageService = YesavageService();
  final TextEditingController _observacionesController = TextEditingController();
  bool _isLoading = false;
  DateTime fechaAplicacion = DateTime.now();

  final Map<String, Map<String, dynamic>> escalaItems = {
    'zona': {
      'title': 'Zona',
      'value': '',
    },
    'distrito': {
      'title': 'Distrito',
      'value': '',
    },
    'modalidadAtencion': {
      'title': 'Modalidad de Atención',
      'value': '',
    },
    'unidadAtencion': {
      'title': 'Unidad de Atención',
      'value': '',
    },
    'edad': {
      'title': 'Edad',
      'value': 0,
    },
    // Map para las respuestas
    'respuestas': {
      'title': 'Respuestas',
      'value': <String, bool>{},
    },
  };

  final List<Map<String, String>> preguntas = [
    {'pregunta': '¿Está Ud. básicamente satisfecho con su vida?', 'respuesta1': 'NO', 'respuesta2': 'si'},
    {'pregunta': '¿Ha disminuido o abandonado muchos de sus intereses o actividades previas?', 'respuesta1': 'SI', 'respuesta2': 'no'},
    {'pregunta': '¿Siente que su vida está vacía?', 'respuesta1': 'SI', 'respuesta2': 'no'},
    {'pregunta': '¿Se siente aburrido frecuentemente?', 'respuesta1': 'SI', 'respuesta2': 'no'},
    {'pregunta': '¿Está Ud. de buen ánimo la mayoría del tiempo?', 'respuesta1': 'si', 'respuesta2': 'NO'},
    {'pregunta': '¿Está preocupado o teme que algo malo le va a pasar?', 'respuesta1': 'SI', 'respuesta2': 'no'},
    {'pregunta': '¿Se siente feliz la mayor parte del tiempo?', 'respuesta1': 'si', 'respuesta2': 'NO'},
    {'pregunta': '¿Se siente con frecuencia desamparado?', 'respuesta1': 'SI', 'respuesta2': 'no'},
    {'pregunta': '¿Prefiere Ud. quedarse en casa a salir a hacer cosas nuevas?', 'respuesta1': 'SI', 'respuesta2': 'no'},
    {'pregunta': '¿Siente Ud. que tiene más problemas con su memoria que otras personas de su edad?', 'respuesta1': 'SI', 'respuesta2': 'no'},
    {'pregunta': '¿Cree Ud. que es maravilloso estar vivo?', 'respuesta1': 'si', 'respuesta2': 'NO'},
    {'pregunta': '¿Se siente inútil o despreciable como está Ud. actualmente?', 'respuesta1': 'SI', 'respuesta2': 'no'},
    {'pregunta': '¿Se siente lleno de energía?', 'respuesta1': 'si', 'respuesta2': 'NO'},
    {'pregunta': '¿Se encuentra sin esperanza ante su situación actual?', 'respuesta1': 'SI', 'respuesta2': 'no'},
    {'pregunta': '¿Cree Ud. que las otras personas están en general mejor que Usted?', 'respuesta1': 'SI', 'respuesta2': 'no'},
  ];

  @override
  void initState() {
    super.initState();
    // Inicializa el mapa de respuestas con valores predeterminados (todos false)
    Map<String, bool> respuestasIniciales = {};
    for (int i = 0; i < preguntas.length; i++) {
      respuestasIniciales['$i'] = false;
    }
    escalaItems['respuestas']!['value'] = respuestasIniciales;
  }

  // Contar puntos de las respuestas
  int contarPuntos() {
    int puntos = 0;
    Map<String, bool> respuestas = escalaItems['respuestas']!['value'] as Map<String, bool>;
    for (int i = 0; i < preguntas.length; i++) {
      if (respuestas['$i'] == true) {
        puntos += 1;
      }
    }
    return puntos;
  }

  void guardarYesavage() async {
    setState(() => _isLoading = true);
    try {
      Yesavage nuevoYesavage = Yesavage(
        idPaciente: widget.idPaciente,
        zona: escalaItems['zona']!['value'],
        distrito: escalaItems['distrito']!['value'],
        modalidadAtencion: escalaItems['modalidadAtencion']!['value'],
        unidadAtencion: escalaItems['unidadAtencion']!['value'],
        edad: escalaItems['edad']!['value'],
        respuestas: escalaItems['respuestas']!['value'],
        fechaAplicacion: fechaAplicacion,
        puntos: contarPuntos(),
      );

      await yesavageService.addYesavage(nuevoYesavage);
      mostrarMensaje('Yesavage guardado correctamente');
    } catch (e) {
      mostrarMensaje('Error al guardar: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void mostrarMensaje(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Información"),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Yesavage')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Agregar campos para zona, distrito, etc.
                  _buildTextField('zona', 'Zona'),
                  _buildTextField('distrito', 'Distrito'),
                  _buildTextField('modalidadAtencion', 'Modalidad de Atención'),
                  _buildTextField('unidadAtencion', 'Unidad de Atención'),
                  _buildNumberField('edad', 'Edad'),
                  const SizedBox(height: 20),
                  for (int i = 0; i < preguntas.length; i++) _buildPregunta(preguntas[i], i),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _observacionesController,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: guardarYesavage,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget para construir campos de texto
  Widget _buildTextField(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            escalaItems[key]!['value'] = value;
          });
        },
      ),
    );
  }

  // Widget para construir campos numéricos
  Widget _buildNumberField(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            escalaItems[key]!['value'] = int.tryParse(value) ?? 0;
          });
        },
      ),
    );
  }

  // Función para construir las preguntas
  Widget _buildPregunta(Map<String, String> pregunta, int index) {
    // Accede correctamente al mapa de respuestas
    Map<String, bool> respuestas = escalaItems['respuestas']!['value'] as Map<String, bool>;
    bool? respuestaActual = respuestas['$index'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(pregunta['pregunta']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: Text(pregunta['respuesta1']!, 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                value: true,
                groupValue: respuestaActual,
                onChanged: (value) {
                  setState(() {
                    // Actualiza el mapa de respuestas correctamente
                    Map<String, bool> nuevasRespuestas = Map<String, bool>.from(respuestas);
                    nuevasRespuestas['$index'] = true;
                    escalaItems['respuestas']!['value'] = nuevasRespuestas;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: Text(pregunta['respuesta2']!),
                value: false,
                groupValue: respuestaActual,
                onChanged: (value) {
                  setState(() {
                    // Actualiza el mapa de respuestas correctamente
                    Map<String, bool> nuevasRespuestas = Map<String, bool>.from(respuestas);
                    nuevasRespuestas['$index'] = false;
                    escalaItems['respuestas']!['value'] = nuevasRespuestas;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}