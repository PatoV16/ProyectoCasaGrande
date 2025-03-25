import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Models/Lawton.model.dart';
import '../../../Services/Lawton.service.dart';

class LawtonBrodyForm extends StatefulWidget {
  final String idPaciente;

  const LawtonBrodyForm({Key? key, required this.idPaciente}) : super(key: key);

  @override
  _LawtonBrodyFormState createState() => _LawtonBrodyFormState();
}

class _LawtonBrodyFormState extends State<LawtonBrodyForm> {
  final LawtonBrodyService lawtonBrodyService = LawtonBrodyService();
  final TextEditingController _observacionesController = TextEditingController();
  bool _isLoading = false;
  DateTime fechaEvaluacion = DateTime.now();

  final Map<String, Map<String, dynamic>> escalaItems = {
    'uso_telefono': {
      'title': 'Capacidad para usar el teléfono',
      'value': 0,
      'options': [
        {'value': 3, 'label': 'Utiliza el teléfono por iniciativa propia'},
        {'value': 2, 'label': 'Es capaz de marcar algunos números'},
        {'value': 1, 'label': 'Solo puede contestar, no marcar'},
        {'value': 0, 'label': 'No usa el teléfono'}
      ]
    },
    'hacer_compras': {
      'title': 'Hacer compras',
      'value': 0,
      'options': [
        {'value': 3, 'label': 'Compra solo'},
        {'value': 2, 'label': 'Realiza pequeñas compras'},
        {'value': 1, 'label': 'Necesita ayuda'},
        {'value': 0, 'label': 'No puede comprar'}
      ]
    },
    'preparar_comida': {
      'title': 'Preparar comidas',
      'value': 0,
      'options': [
        {'value': 3, 'label': 'Prepara comidas solo'},
        {'value': 2, 'label': 'Prepara comidas con ayuda'},
        {'value': 1, 'label': 'No cocina pero puede servirse'},
        {'value': 0, 'label': 'No puede preparar comida'}
      ]
    },
    'cuidado_casa': {
      'title': 'Cuidado de la casa',
      'value': 0,
      'options': [
        {'value': 3, 'label': 'Mantiene su hogar solo'},
        {'value': 2, 'label': 'Realiza tareas menores'},
        {'value': 1, 'label': 'Solo realiza tareas livianas'},
        {'value': 0, 'label': 'No puede mantener su hogar'}
      ]
    },
    'lavado_ropa': {
      'title': 'Lavado de ropa',
      'value': 0,
      'options': [
        {'value': 3, 'label': 'Lava toda su ropa'},
        {'value': 2, 'label': 'Lava solo ropa ligera'},
        {'value': 1, 'label': 'Necesita ayuda'},
        {'value': 0, 'label': 'No lava su ropa'}
      ]
    },
    'uso_transporte': {
      'title': 'Uso del transporte',
      'value': 0,
      'options': [
        {'value': 3, 'label': 'Usa transporte público solo'},
        {'value': 2, 'label': 'Usa transporte con ayuda'},
        {'value': 1, 'label': 'Solo usa taxi acompañado'},
        {'value': 0, 'label': 'No usa transporte'}
      ]
    },
    'responsabilidad_medicacion': {
      'title': 'Manejo de medicamentos',
      'value': 0,
      'options': [
        {'value': 3, 'label': 'Toma medicamentos solo'},
        {'value': 2, 'label': 'Toma medicamentos con recordatorio'},
        {'value': 1, 'label': 'Necesita supervisión'},
        {'value': 0, 'label': 'No maneja medicamentos'}
      ]
    },
    'capacidad_dinero': {
      'title': 'Manejo del dinero',
      'value': 0,
      'options': [
        {'value': 3, 'label': 'Maneja dinero y pagos solo'},
        {'value': 2, 'label': 'Maneja dinero con ayuda'},
        {'value': 1, 'label': 'Solo maneja gastos pequeños'},
        {'value': 0, 'label': 'No maneja dinero'}
      ]
    },
  };

  int calcularPuntajeTotal() {
    return escalaItems.values.fold(0, (prev, item) => prev + (item['value'] as int));
  }

  void guardarLawtonBrody() async {
    setState(() => _isLoading = true);
    try {
      LawtonBrody nuevoLawtonBrody = LawtonBrody(
        idPaciente: widget.idPaciente,
        usoTelefono: escalaItems['uso_telefono']!['value'],
        hacerCompras: escalaItems['hacer_compras']!['value'],
        prepararComida: escalaItems['preparar_comida']!['value'],
        cuidadoCasa: escalaItems['cuidado_casa']!['value'],
        lavadoRopa: escalaItems['lavado_ropa']!['value'],
        usoTransporte: escalaItems['uso_transporte']!['value'],
        responsabilidadMedicacion: escalaItems['responsabilidad_medicacion']!['value'],
        capacidadDinero: escalaItems['capacidad_dinero']!['value'],
        puntajeTotal: calcularPuntajeTotal(),
        fechaEvaluacion: fechaEvaluacion,
        observaciones: _observacionesController.text,
      );
      await lawtonBrodyService.addLawtonBrody(nuevoLawtonBrody);
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
      appBar: AppBar(title: const Text('Registrar Escala Lawton-Brody')),
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
                    onPressed: guardarLawtonBrody,
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
