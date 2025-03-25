import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:casa_grande_app/Models/ActaCompromiso.model.dart';

import '../../../Services/ActaCompromiso.service.dart';


class CartaCompromisoScreen extends StatefulWidget {
  @override
  _CartaCompromisoScreenState createState() => _CartaCompromisoScreenState();
}

class _CartaCompromisoScreenState extends State<CartaCompromisoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final ActaCompromisoService _service = ActaCompromisoService();

  void _guardarActa() async {
    if (_formKey.currentState!.validate()) {
      final acta = ActaCompromiso(
        nombreCompleto: _nombreController.text,
        cedulaIdentidad: _cedulaController.text,
        telefono: _telefonoController.text,
        direccion: _direccionController.text,
        fechaCreacion: DateTime.now(),
        idPaciente: "12345", // Aquí puedes enlazar con el paciente real
      );
      await _service.addActaCompromiso(acta);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Acta guardada con éxito')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carta de Compromiso'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INSTRUCCIONES:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Cuando ingresa la persona adulta mayor al Centro Gerontológico Diurno...'
                  'aceptar el apoyo e intervención profesional que requiera durante su permanencia en el centro.',
                ),
                Divider(),
                Center(
                  child: Text(
                    'Ficha N° 7 CARTA DE COMPROMISO Y ACEPTACIÓN',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _cedulaController,
                  decoration: InputDecoration(labelText: 'Cédula de Identidad'),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _telefonoController,
                  decoration: InputDecoration(labelText: 'Teléfono'),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _direccionController,
                  decoration: InputDecoration(labelText: 'Dirección'),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _guardarActa,
                  child: Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
