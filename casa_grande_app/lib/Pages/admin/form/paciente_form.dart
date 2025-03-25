import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Models/Paciente.model.dart';
import '../../../Services/Paciente.service.dart';
import '../../../Widgets/input_field.dart';
import '../../../Widgets/date_picker.dart';
import '../../../Widgets/submit_button.dart';
import '../../../Widgets/message_dialog_button.dart'; // Importar el nuevo widget

class PacienteForm extends StatefulWidget {
  const PacienteForm({Key? key}) : super(key: key);

  @override
  _PacienteFormState createState() => _PacienteFormState();
}

class _PacienteFormState extends State<PacienteForm> {
  final PacienteService pacienteService = PacienteService();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController estadoCivilController = TextEditingController();
  final TextEditingController nivelInstruccionController = TextEditingController();
  final TextEditingController profesionController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  DateTime fechaNacimiento = DateTime.now();
  DateTime fechaIngreso = DateTime.now();

  void mostrarMensaje(String mensaje) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Información"),
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

 bool validarCampos() {
  if (nombreController.text.trim().isEmpty ||
      apellidoController.text.trim().isEmpty ||
      cedulaController.text.trim().isEmpty ||
      estadoCivilController.text.trim().isEmpty ||
      nivelInstruccionController.text.trim().isEmpty ||
      profesionController.text.trim().isEmpty ||
      telefonoController.text.trim().isEmpty ||
      direccionController.text.trim().isEmpty) {
    mostrarMensaje('Por favor, complete todos los campos obligatorios.');
    return false;
  }

  // Validar cédula (exactamente 10 dígitos numéricos)
  if (!RegExp(r'^\d{10}$').hasMatch(cedulaController.text)) {
    mostrarMensaje('La cédula debe tener exactamente 10 dígitos numéricos.');
    return false;
  }

  // Validar teléfono (entre 7 y 10 dígitos)
  if (!RegExp(r'^\d{7,10}$').hasMatch(telefonoController.text)) {
    mostrarMensaje('El teléfono debe tener entre 7 y 10 dígitos numéricos.');
    return false;
  }

  // Validar que la fecha de nacimiento no sea futura
  if (fechaNacimiento.isAfter(DateTime.now())) {
    mostrarMensaje('La fecha de nacimiento no puede ser en el futuro.');
    return false;
  }

  // Validar que la fecha de ingreso no sea menor a la fecha de nacimiento
  if (fechaIngreso.isBefore(fechaNacimiento)) {
    mostrarMensaje('La fecha de ingreso no puede ser anterior a la fecha de nacimiento.');
    return false;
  }

  return true;
}


  void guardarPaciente() async {
  if (!validarCampos()) return;

  Paciente nuevoPaciente = Paciente(
    nombre: nombreController.text.trim(),
    apellido: apellidoController.text.trim(),
    cedula: cedulaController.text.trim(),
    fechaNacimiento: fechaNacimiento,
    estadoCivil: estadoCivilController.text.trim(),
    nivelInstruccion: nivelInstruccionController.text.trim(),
    profesionOcupacion: profesionController.text.trim(),
    telefono: telefonoController.text.trim(),
    direccion: direccionController.text.trim(),
    fechaIngreso: fechaIngreso,
  );

  await pacienteService.addPaciente(nuevoPaciente);

  mostrarMensaje('Paciente guardado correctamente');

  // Limpiar campos después de guardar
  nombreController.clear();
  apellidoController.clear();
  cedulaController.clear();
  estadoCivilController.clear();
  nivelInstruccionController.clear();
  profesionController.clear();
  telefonoController.clear();
  direccionController.clear();
  setState(() {
    fechaNacimiento = DateTime.now();
    fechaIngreso = DateTime.now();
  });
}

  @override
  Widget build(BuildContext context) {
   return CupertinoPageScaffold(
  navigationBar: CupertinoNavigationBar(
    middle: const Text('Registrar Paciente'),
    leading: CupertinoNavigationBarBackButton(
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ),
  child: SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            InputField(placeholder: 'Nombre', controller: nombreController, label: '',),
            const SizedBox(height: 10),
            InputField(placeholder: 'Apellido', controller: apellidoController, label: '',),
            const SizedBox(height: 10),
            InputField(
              placeholder: 'Cédula',
              controller: cedulaController,
              keyboardType: TextInputType.number, label: '',
            ),
            const SizedBox(height: 10),
            DatePickerField(
              label: 'Fecha de Nacimiento',
              selectedDate: fechaNacimiento,
              onDateSelected: (date) => setState(() => fechaNacimiento = date),
            ),
            const SizedBox(height: 10),
            InputField(placeholder: 'Estado Civil', controller: estadoCivilController, label: '',),
            const SizedBox(height: 10),
            InputField(placeholder: 'Nivel de Instrucción', controller: nivelInstruccionController, label: '',),
            const SizedBox(height: 10),
            InputField(placeholder: 'Profesión / Ocupación', controller: profesionController, label: '',),
            const SizedBox(height: 10),
            InputField(placeholder: 'Teléfono', controller: telefonoController, keyboardType: TextInputType.phone, label: '',),
            const SizedBox(height: 10),
            InputField(placeholder: 'Dirección', controller: direccionController, label: '',),
            const SizedBox(height: 10),
            DatePickerField(
              label: 'Fecha de Ingreso',
              selectedDate: fechaIngreso,
              onDateSelected: (date) => setState(() => fechaIngreso = date),
            ),
            const SizedBox(height: 20),
            SubmitButton(text: 'Guardar Paciente', onPressed: guardarPaciente),
          ],
        ),
      ),
    ),
  ),
);

  }
}
