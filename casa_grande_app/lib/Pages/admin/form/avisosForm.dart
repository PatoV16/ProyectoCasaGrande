import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../Services/Avisos.service.dart';

class AgregarAvisoScreen extends StatefulWidget {
  const AgregarAvisoScreen({Key? key}) : super(key: key);

  @override
  _AgregarAvisoScreenState createState() => _AgregarAvisoScreenState();
}

class _AgregarAvisoScreenState extends State<AgregarAvisoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _avisoService = AvisoService();
  final _imagePicker = ImagePicker();

  File? _imagenSeleccionada; // Para móvil y escritorio
  Uint8List? _imagenSeleccionadaWeb; // Para Web
  bool _guardando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        // Para web, convertir a Uint8List
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imagenSeleccionadaWeb = bytes;
        });
      } else {
        // Para móvil y escritorio, usar File
        setState(() {
          _imagenSeleccionada = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _guardarAviso() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _guardando = true;
      });

      try {
        String? imagenUrl;

        if (_imagenSeleccionada != null || _imagenSeleccionadaWeb != null) {
          imagenUrl = await _subirImagen();
        }

        await _avisoService.crearAviso(
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          imagen: _imagenSeleccionada, // Para móviles
        );


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Aviso creado con éxito!'),
            backgroundColor: Colors.green,
          ),
        );

        _tituloController.clear();
        _descripcionController.clear();
        setState(() {
          _imagenSeleccionada = null;
          _imagenSeleccionadaWeb = null;
        });

         Navigator.of(context).pushReplacementNamed('/admin');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el aviso: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  Future<String?> _subirImagen() async {
    final storage = FirebaseStorage.instance;
    final nombreArchivo = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = storage.ref().child('avisos/$nombreArchivo.jpg');

    try {
      if (kIsWeb && _imagenSeleccionadaWeb != null) {
        // Para Web, usar putData()
        await ref.putData(_imagenSeleccionadaWeb!);
      } else if (_imagenSeleccionada != null) {
        // Para móvil/escritorio, usar putFile()
        await ref.putFile(_imagenSeleccionada!);
      }

      return await ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Aviso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título del Aviso',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text('Imagen (Opcional)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_imagenSeleccionadaWeb != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.memory(_imagenSeleccionadaWeb!,
                              fit: BoxFit.cover),
                        ),
                      if (_imagenSeleccionada != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.file(_imagenSeleccionada!,
                              fit: BoxFit.cover),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _seleccionarImagen,
                        icon: const Icon(Icons.image),
                        label: Text(_imagenSeleccionada == null &&
                                _imagenSeleccionadaWeb == null
                            ? 'Seleccionar Imagen'
                            : 'Cambiar Imagen'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _guardando ? null : _guardarAviso,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _guardando
                    ? const CircularProgressIndicator()
                    : const Text('GUARDAR AVISO',
                        style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
