import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormularioEvolucion extends StatefulWidget {
  final String idPaciente;

  FormularioEvolucion({required this.idPaciente});

  @override
  _FormularioEvolucionState createState() => _FormularioEvolucionState();
}

class _FormularioEvolucionState extends State<FormularioEvolucion> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _areaServicioController = TextEditingController();
  final TextEditingController _actividadesController = TextEditingController();
  final TextEditingController _evolucionController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _recomendacionesController = TextEditingController();

  late String tipoFicha;
  late String uidUsuario;

  @override
  void initState() {
    super.initState();
    _obtenerCargoYUidUsuario();
  }

  // Obtener el cargo del usuario logueado y su UID
  Future<void> _obtenerCargoYUidUsuario() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uidUsuario = user.uid;
      // Obtener el cargo del usuario desde Firestore
      DocumentSnapshot usuarioDoc = await FirebaseFirestore.instance.collection('usuarios').doc(uidUsuario).get();
      if (usuarioDoc.exists) {
        setState(() {
          tipoFicha = usuarioDoc['cargo'];  // Asumimos que el campo cargo está en el documento del usuario
        });
      }
    }
  }

  // Guardar los datos de la evolución en Firestore
  Future<void> _guardarEvolucion() async {
    if (_formKey.currentState!.validate()) {
      final evolucion = {
        'idPaciente': widget.idPaciente,
        'fechaHora': Timestamp.fromDate(DateTime.now()), // Fecha y hora actual
        'areaServicio': _areaServicioController.text,
        'actividades': _actividadesController.text.split(','), // Separar actividades por coma
        'evolucion': _evolucionController.text,
        'observaciones': _observacionesController.text,
        'recomendaciones': _recomendacionesController.text,
        'tipoFicha': tipoFicha,  // Guardamos el tipo de ficha determinado por el cargo
      };

      await FirebaseFirestore.instance.collection('evoluciones').add(evolucion);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Evolución guardada con éxito')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Formulario de Evolución')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _areaServicioController,
                decoration: InputDecoration(labelText: 'Área de Servicio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _actividadesController,
                decoration: InputDecoration(labelText: 'Actividades (separadas por coma)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _evolucionController,
                decoration: InputDecoration(labelText: 'Evolución'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _observacionesController,
                decoration: InputDecoration(labelText: 'Observaciones'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _recomendacionesController,
                decoration: InputDecoration(labelText: 'Recomendaciones'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarEvolucion,
                child: Text('Guardar Evolución'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
