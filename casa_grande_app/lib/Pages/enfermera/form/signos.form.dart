import 'package:casa_grande_app/Models/signos.vitales.model.dart';
import 'package:casa_grande_app/Services/signos.service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:casa_grande_app/Models/Paciente.model.dart'; // Importa el modelo Paciente

class SignosVitalesScreen extends StatefulWidget {
  final Paciente paciente; // Cambia idPaciente por Paciente

  const SignosVitalesScreen({Key? key, required this.paciente}) : super(key: key); // Modifica el constructor

  @override
  State<SignosVitalesScreen> createState() => _SignosVitalesScreenState();
}

class _SignosVitalesScreenState extends State<SignosVitalesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SignosVitalesService();

  // Controladores
  final _tempCtrl = TextEditingController();
  final _fcCtrl = TextEditingController();
  final _frCtrl = TextEditingController();
  final _psCtrl = TextEditingController();
  final _pdCtrl = TextEditingController();
  final _soCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _tallaCtrl = TextEditingController();

  List<SignosVitales> _lista = [];

  @override
  void initState() {
    super.initState();
    _cargarSignos();
  }

  Future<void> _cargarSignos() async {
    final datos = await _service.obtenerSignosPorPaciente(widget.paciente.cedula); // Usa widget.paciente.cedula
    setState(() {
      _lista = datos;
    });
  }

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      final nuevo = SignosVitales(
        idPaciente: widget.paciente.cedula, // Usa widget.paciente.cedula
        temperatura: double.parse(_tempCtrl.text),
        frecuenciaCardiaca: int.parse(_fcCtrl.text),
        frecuenciaRespiratoria: int.parse(_frCtrl.text),
        presionSistolica: int.parse(_psCtrl.text),
        presionDiastolica: int.parse(_pdCtrl.text),
        saturacionOxigeno: int.parse(_soCtrl.text),
        peso: double.parse(_pesoCtrl.text),
        talla: double.parse(_tallaCtrl.text),
        fechaRegistro: DateTime.now(),
      );

      await _service.agregarSignosVitales(nuevo);
      _limpiar();
      _cargarSignos();
    }
  }

  void _limpiar() {
    _tempCtrl.clear();
    _fcCtrl.clear();
    _frCtrl.clear();
    _psCtrl.clear();
    _pdCtrl.clear();
    _soCtrl.clear();
    _pesoCtrl.clear();
    _tallaCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signos Vitales')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _formulario()),
                      const SizedBox(width: 20),
                      Expanded(child: _listaSignos()),
                    ],
                  )
                : Column(
                    children: [
                      _formulario(),
                      const SizedBox(height: 20),
                      _listaSignos(),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _formulario() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _campo('Temperatura (°C)', _tempCtrl),
          _campo('Frecuencia cardíaca (bpm)', _fcCtrl),
          _campo('Frecuencia respiratoria (rpm)', _frCtrl),
          _campo('Presión sistólica (mmHg)', _psCtrl),
          _campo('Presión diastólica (mmHg)', _pdCtrl),
          _campo('Saturación de oxígeno (%)', _soCtrl),
          _campo('Peso (kg)', _pesoCtrl),
          _campo('Talla (m)', _tallaCtrl),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _guardar,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _campo(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _listaSignos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Historial', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._lista.map((e) => Card(
              child: ListTile(
                title: Text('Temp: ${e.temperatura}°C, FC: ${e.frecuenciaCardiaca} bpm'),
                subtitle: Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(e.fechaRegistro)}',
                ),
              ),
            )),
      ],
    );
  }
}