import 'package:flutter/material.dart';
import '../../../Models/Minimental.model.dart';
import '../../../Services/Minimental.service.dart';

class MiniExamenForm extends StatefulWidget {
  final String idPaciente;

  const MiniExamenForm({Key? key, required this.idPaciente}) : super(key: key);

  @override
  _MiniExamenFormState createState() => _MiniExamenFormState();
}

class _MiniExamenFormState extends State<MiniExamenForm> {
  final MiniExamenService miniExamenService = MiniExamenService();
  final TextEditingController _observacionesController = TextEditingController();
  bool _isLoading = false;
  DateTime fechaEvaluacion = DateTime.now();

 final Map<String, Map<String, dynamic>> escalaItems = {
  'orientacion_tiempo': {
    'title': 'Orientación en el tiempo',
    'value': 0,
    'options': [
      {'value': 3, 'label': 'Totalmente orientado'},
      {'value': 2, 'label': 'Parcialmente orientado'},
      {'value': 1, 'label': 'Desorientado'},
      {'value': 0, 'label': 'No responde'}
    ]
  },
  'orientacion_espacio': {
    'title': 'Orientación en el espacio',
    'value': 0,
    'options': [
      {'value': 3, 'label': 'Totalmente orientado'},
      {'value': 2, 'label': 'Parcialmente orientado'},
      {'value': 1, 'label': 'Desorientado'},
      {'value': 0, 'label': 'No responde'}
    ]
  },
  'memoria': {
    'title': 'Memoria inmediata',
    'value': 0,
    'options': [
      {'value': 3, 'label': 'Recuerda 3 palabras'},
      {'value': 2, 'label': 'Recuerda 2 palabras'},
      {'value': 1, 'label': 'Recuerda 1 palabra'},
      {'value': 0, 'label': 'No recuerda ninguna'}
    ]
  },
  'atencion_calculo': {
    'title': 'Atención y cálculo',
    'value': 0,
    'options': [
      {'value': 5, 'label': 'Cuenta correctamente'},
      {'value': 3, 'label': 'Cuenta con errores'},
      {'value': 1, 'label': 'No puede realizar la cuenta'},
      {'value': 0, 'label': 'No responde'}
    ]
  },
  'memoria_diferida': {
    'title': 'Recuerdo diferido',
    'value': 0,
    'options': [
      {'value': 3, 'label': 'Recuerda las palabras dadas'},
      {'value': 2, 'label': 'Recuerda algunas palabras'},
      {'value': 1, 'label': 'Recuerda solo una'},
      {'value': 0, 'label': 'No recuerda ninguna'}
    ]
  },
  'denominacion': {
    'title': 'Denominación',
    'value': 0,
    'options': [
      {'value': 2, 'label': 'Denomina correctamente'},
      {'value': 1, 'label': 'Dificultad para denominar'},
      {'value': 0, 'label': 'No puede denominar'}
    ]
  },
  'repeticion_frase': {
    'title': 'Repetición de frase',
    'value': 0,
    'options': [
      {'value': 2, 'label': 'Repite correctamente'},
      {'value': 1, 'label': 'Repite parcialmente'},
      {'value': 0, 'label': 'No repite'}
    ]
  },
  'comprension_ejecucion': {
    'title': 'Comprensión y ejecución',
    'value': 0,
    'options': [
      {'value': 3, 'label': 'Realiza correctamente la tarea'},
      {'value': 2, 'label': 'Realiza parcialmente la tarea'},
      {'value': 1, 'label': 'Realiza la tarea con ayuda'},
      {'value': 0, 'label': 'No realiza la tarea'}
    ]
  },
  'lectura': {
    'title': 'Lectura',
    'value': 0,
    'options': [
      {'value': 2, 'label': 'Lee correctamente'},
      {'value': 1, 'label': 'Lee parcialmente'},
      {'value': 0, 'label': 'No puede leer'}
    ]
  },
  'escritura': {
    'title': 'Escritura',
    'value': 0,
    'options': [
      {'value': 2, 'label': 'Escribe correctamente'},
      {'value': 1, 'label': 'Escribe parcialmente'},
      {'value': 0, 'label': 'No puede escribir'}
    ]
  },
  'copia_dibujo': {
    'title': 'Copia de dibujo',
    'value': 0,
    'options': [
      {'value': 2, 'label': 'Copia correctamente'},
      {'value': 1, 'label': 'Copia parcialmente'},
      {'value': 0, 'label': 'No puede copiar'}
    ]
  },
};


  int calcularPuntajeTotal() {
    return escalaItems.values.fold(0, (prev, item) => prev + (item['value'] as int));
  }

 void guardarMiniExamen() async {
  setState(() => _isLoading = true);
  try {
    MiniExamen nuevoMiniExamen = MiniExamen(
      idPaciente: widget.idPaciente,
      orientacionTiempo: escalaItems['orientacion_tiempo']!['value'],
      orientacionEspacio: escalaItems['orientacion_espacio']!['value'],
      memoria: escalaItems['memoria']!['value'],
      atencionCalculo: escalaItems['atencion_calculo']!['value'],
      memoriaDiferida: escalaItems['memoria_diferida']!['value'],
      denominacion: escalaItems['denominacion']!['value'],
      repeticionFrase: escalaItems['repeticion_frase']!['value'],
      comprensionEjecucion: escalaItems['comprension_ejecucion']!['value'],
      lectura: escalaItems['lectura']!['value'],
      escritura: escalaItems['escritura']!['value'],
      copiaDibujo: escalaItems['copia_dibujo']!['value'],
      puntajeTotal: calcularPuntajeTotal(),
    );

    await miniExamenService.addMiniExamen(nuevoMiniExamen);
    mostrarMensaje('Escala guardada correctamente');
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
      appBar: AppBar(title: const Text('Registrar Mini Examen Mental')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  for (var key in escalaItems.keys) _buildRadioGroup(key),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _observacionesController,
                    decoration: InputDecoration(
                      labelText: 'Observaciones',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: guardarMiniExamen,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRadioGroup(String key) {
    final item = escalaItems[key]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        for (var option in item['options'])
          RadioListTile<int>(
            title: Text(option['label']),
            value: option['value'],
            groupValue: item['value'],
            onChanged: (value) {
              setState(() {
                escalaItems[key]!['value'] = value!;
              });
            },
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
