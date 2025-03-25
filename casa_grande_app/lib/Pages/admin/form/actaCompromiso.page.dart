import 'package:flutter/cupertino.dart';
import 'package:casa_grande_app/Models/ActaCompromiso.model.dart';
import 'package:casa_grande_app/Services/ActaCompromiso.service.dart';
import '../../../Widgets/input_field.dart';
import '../../../Widgets/date_picker.dart';
import '../../../Widgets/submit_button.dart';
import '../../../Widgets/select_field.dart'; // Importa el SelectField

class ActaCompromisoForm extends StatefulWidget {
  const ActaCompromisoForm();

  @override
  _ActaCompromisoFormState createState() => _ActaCompromisoFormState();
}

class _ActaCompromisoFormState extends State<ActaCompromisoForm> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  String? idPacienteSeleccionado;

  DateTime fechaCreacion = DateTime.now();
  final ActaCompromisoService _service = ActaCompromisoService();

  void guardarActa() async {
  // Validar si algún campo está vacío
  if (idPacienteSeleccionado == null ||
      nombreController.text.trim().isEmpty ||
      cedulaController.text.trim().isEmpty ||
      telefonoController.text.trim().isEmpty ||
      direccionController.text.trim().isEmpty) {
    mostrarAlerta("Error", "Todos los campos son obligatorios.");
    return;
  }

  // Validar formato de cédula (ejemplo: 10 dígitos numéricos)
  if (!RegExp(r'^\d{10}$').hasMatch(cedulaController.text)) {
    mostrarAlerta("Error", "La cédula debe tener 10 dígitos numéricos.");
    return;
  }

  // Validar formato de teléfono (ejemplo: 7 a 10 dígitos numéricos)
  if (!RegExp(r'^\d{7,10}$').hasMatch(telefonoController.text)) {
    mostrarAlerta("Error", "El teléfono debe tener entre 7 y 10 dígitos.");
    return;
  }

  // Crear el objeto ActaCompromiso si pasa las validaciones
  ActaCompromiso nuevaActa = ActaCompromiso(
    nombreCompleto: nombreController.text,
    cedulaIdentidad: cedulaController.text,
    telefono: telefonoController.text,
    direccion: direccionController.text,
    fechaCreacion: fechaCreacion,
    idPaciente: idPacienteSeleccionado!,
  );

  await _service.addActaCompromiso(nuevaActa);
  mostrarAlerta("Éxito", "Acta de compromiso guardada correctamente");
}

/// Función para mostrar alertas en Cupertino
void mostrarAlerta(String titulo, String mensaje) {
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        CupertinoDialogAction(
          child: const Text("OK"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Registrar Acta de Compromiso'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SelectField(
                onChanged: (String? cedula) {
                  setState(() {
                    idPacienteSeleccionado = cedula;
                  });
                }, label: '', items: [],
              ),
              const SizedBox(height: 10),
              InputField(placeholder: 'Nombre Completo', controller: nombreController, label: '',),
              const SizedBox(height: 10),
              InputField(placeholder: 'Cédula de Identidad', controller: cedulaController, label: '',),
              const SizedBox(height: 10),
              InputField(placeholder: 'Teléfono', controller: telefonoController, label: '',),
              const SizedBox(height: 10),
              InputField(placeholder: 'Dirección', controller: direccionController, label: '',),
              const SizedBox(height: 10),
              DatePickerField(
                label: 'Fecha de Creación',
                selectedDate: fechaCreacion,
                onDateSelected: (date) => setState(() => fechaCreacion = date),
              ),
              const SizedBox(height: 20),
              SubmitButton(text: 'Guardar Acta', onPressed: guardarActa),
            ],
          ),
        ),
      ),
    );
  }
}
