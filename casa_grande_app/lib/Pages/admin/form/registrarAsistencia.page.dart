import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Models/Asistencia.model.dart';
import '../../../Services/Asistencia.service.dart';
import '../../../Widgets/checkBox_Days.dart';
import '../../../Widgets/input_field.dart';
import '../../../Widgets/date_picker.dart';
import '../../../Widgets/submit_button.dart';
import '../../../Widgets/message_dialog_button.dart';
import '../../../Widgets/select_field.dart';

class AgregarAsistenciaScreen extends StatefulWidget {
  const AgregarAsistenciaScreen({Key? key}) : super(key: key);

  @override
  _AgregarAsistenciaScreenState createState() => _AgregarAsistenciaScreenState();
}

class _AgregarAsistenciaScreenState extends State<AgregarAsistenciaScreen> {
  final AsistenciaService _asistenciaService = AsistenciaService();

  final TextEditingController _idPacienteController = TextEditingController();
  final TextEditingController _horarioTrabajoController = TextEditingController();
  final TextEditingController _nombreCentroController = TextEditingController();
  final TextEditingController _modalidadAtencionController = TextEditingController();
  final TextEditingController _distritoController = TextEditingController();
  List<bool> _diasAsistencia = List.filled(7, false);

  DateTime _semanaInicio = DateTime.now();
  DateTime _semanaFin = DateTime.now();
  DateTime _mes = DateTime.now();
  DateTime _anio = DateTime.now();

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
    if (_idPacienteController.text.isEmpty ||
        _horarioTrabajoController.text.isEmpty ||
        _nombreCentroController.text.isEmpty ||
        _modalidadAtencionController.text.isEmpty ||
        _distritoController.text.isEmpty) {
      mostrarMensaje('Por favor, complete todos los campos correctamente');
      return false;
    }
    if (_semanaFin.isBefore(_semanaInicio)) {
      mostrarMensaje('La fecha de fin no puede ser menor que la de inicio');
      return false;
    }
    if (!_diasAsistencia.contains(true)) {
      mostrarMensaje('Debe seleccionar al menos un día de asistencia');
      return false;
    }
    return true;
  }

  void guardarAsistencia() async {
    if (!validarCampos()) return;

    try {
      Asistencia nuevaAsistencia = Asistencia(
        idPaciente: _idPacienteController.text,
        semanaInicio: _semanaInicio.toString(),
        semanaFin: _semanaFin.toString(),
        mes: _mes.month.toString(),
        anio: _anio.year.toString(),
        horarioTrabajo: _horarioTrabajoController.text,
        nombreCentro: _nombreCentroController.text,
        modalidadAtencion: _modalidadAtencionController.text,
        distrito: _distritoController.text,
        diasAsistencia: _diasAsistencia,
      );

      await _asistenciaService.addAsistencia(nuevaAsistencia);

      mostrarMensaje('Asistencia guardada correctamente');

      _idPacienteController.clear();
      _horarioTrabajoController.clear();
      _nombreCentroController.clear();
      _modalidadAtencionController.clear();
      _distritoController.clear();
      setState(() {
        _diasAsistencia = List.filled(7, false);
        _semanaInicio = DateTime.now();
        _semanaFin = DateTime.now();
        _mes = DateTime.now();
        _anio = DateTime.now();
      });
    } catch (e) {
      mostrarMensaje('Error al guardar asistencia: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Agregar Asistencia'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectField(
                  onChanged: (String? cedula) {
                    _idPacienteController.text = cedula ?? '';
                  }, items: [], label: '',
                ),
                const SizedBox(height: 10),
                DatePickerField(
                  label: 'Semana Inicio',
                  selectedDate: _semanaInicio,
                  onDateSelected: (date) => setState(() => _semanaInicio = date),
                ),
                const SizedBox(height: 10),
                DatePickerField(
                  label: 'Semana Fin',
                  selectedDate: _semanaFin,
                  onDateSelected: (date) => setState(() => _semanaFin = date),
                ),
                const SizedBox(height: 10),
                DatePickerField(
                  label: 'Mes',
                  selectedDate: _mes,
                  onDateSelected: (date) => setState(() => _mes = date),
                ),
                const SizedBox(height: 10),
                DatePickerField(
                  label: 'Año',
                  selectedDate: _anio,
                  onDateSelected: (date) => setState(() => _anio = date),
                ),
                const SizedBox(height: 10),
                InputField(label: 'Horario de Trabajo', controller: _horarioTrabajoController, placeholder: 'Horario de Trabajo'),
                const SizedBox(height: 10),
                InputField(label: 'Nombre del Centro', controller: _nombreCentroController, placeholder: 'Nombre del Centro'),
                const SizedBox(height: 10),
                InputField(label: 'Modalidad de Atención', controller: _modalidadAtencionController, placeholder: 'Modalidad de Atención'),
                const SizedBox(height: 10),
                InputField(label: 'Distrito', controller: _distritoController, placeholder: 'Distrito'),
                const SizedBox(height: 10),
                DiasAsistenciaCheckbox(
                  diasAsistencia: _diasAsistencia,
                  onChanged: (nuevosDias) => setState(() => _diasAsistencia = nuevosDias),
                ),
                const SizedBox(height: 20),
                SubmitButton(text: 'Guardar Asistencia', onPressed: guardarAsistencia),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
