import 'package:casa_grande_app/Services/AsistenciaUsuario.service.dart';
import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/AsistenciaUsuario.model.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha

class RegistrarAsistenciaUsuarioScreen extends StatefulWidget {
  final String uid; // Recibimos el uid del usuario desde otra pantalla

  RegistrarAsistenciaUsuarioScreen({required this.uid});

  @override
  _RegistrarAsistenciaScreenState createState() =>
      _RegistrarAsistenciaScreenState();
}

class _RegistrarAsistenciaScreenState extends State<RegistrarAsistenciaUsuarioScreen> {
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _tipoAsistenciaController =
      TextEditingController();
  double _latitud = 0.0; // Podrías obtenerlo con alguna librería de geolocalización
  double _longitud = 0.0; // Igualmente para la longitud

  final AsistenciaUsuarioService _asistenciaService = AsistenciaUsuarioService();

  // Función para registrar la asistencia
  void _registrarAsistencia() async {
    if (_direccionController.text.isEmpty ||
        _tipoAsistenciaController.text.isEmpty) {
      // Asegúrate de validar que los campos no estén vacíos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor complete todos los campos")),
      );
      return;
    }

    // Crear el objeto AsistenciaUsuario
    AsistenciaUsuario nuevaAsistencia = AsistenciaUsuario(
      id: "", // El ID se generará automáticamente en el servicio
      idEmpleado: widget.uid, // Usamos el UID que recibimos en el constructor
      fechaHora: DateTime.now(),
      latitud: _latitud,
      longitud: _longitud,
      direccion: _direccionController.text,
      tipoAsistencia: _tipoAsistenciaController.text,
    );

    // Registrar la asistencia
    await _asistenciaService.registrarAsistencia(nuevaAsistencia);
    Navigator.pop(context); // Regresamos a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrar Asistencia"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _direccionController,
              decoration: InputDecoration(labelText: "Dirección"),
            ),
            TextField(
              controller: _tipoAsistenciaController,
              decoration: InputDecoration(labelText: "Tipo de Asistencia"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registrarAsistencia,
              child: Text("Registrar Asistencia"),
            ),
          ],
        ),
      ),
    );
  }
}
