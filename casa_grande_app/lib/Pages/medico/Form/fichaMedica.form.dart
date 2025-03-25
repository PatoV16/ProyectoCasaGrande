import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Models/FichaMedica.model.dart';
import '../../../Services/FichaMedica.service.dart';
import '../../../Widgets/input_field.dart';
import '../../../Widgets/submit_button.dart';

class FichaMedicaForm extends StatefulWidget {
  final String idPaciente;
  final String idEmpleado;

  const FichaMedicaForm({Key? key, required this.idPaciente, required this.idEmpleado}) : super(key: key);

  @override
  _FichaMedicaFormState createState() => _FichaMedicaFormState();
}

class _FichaMedicaFormState extends State<FichaMedicaForm> {
  final FichaMedicaService fichaMedicaService = FichaMedicaService();

  final TextEditingController condicionFisicaController = TextEditingController();
  final TextEditingController condicionPsicologicaController = TextEditingController();
  final TextEditingController estadoSaludController = TextEditingController();
  final TextEditingController medicamentosController = TextEditingController();
  final TextEditingController intoleranciaMedicamentosController = TextEditingController();
  final TextEditingController referidoPorController = TextEditingController();
  final TextEditingController viveConController = TextEditingController();
  final TextEditingController relacionesFamiliaresController = TextEditingController();
  final TextEditingController observacionesController = TextEditingController();

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
    if (condicionFisicaController.text.trim().isEmpty ||
        condicionPsicologicaController.text.trim().isEmpty ||
        estadoSaludController.text.trim().isEmpty) {
      mostrarMensaje('Por favor, complete los campos obligatorios.');
      return false;
    }
    return true;
  }

  void guardarFichaMedica() async {
    if (!validarCampos()) return;

    FichaMedica nuevaFicha = FichaMedica(
      idPaciente: widget.idPaciente,
      idEmpleado: widget.idEmpleado,
      condicionFisica: condicionFisicaController.text.trim(),
      condicionPsicologica: condicionPsicologicaController.text.trim(),
      estadoSalud: estadoSaludController.text.trim(),
      medicamentos: medicamentosController.text.trim(),
      intoleranciaMedicamentos: intoleranciaMedicamentosController.text.trim(),
      referidoPor: referidoPorController.text.trim(),
      viveCon: viveConController.text.trim(),
      relacionesFamiliares: relacionesFamiliaresController.text.trim(),
      observaciones: observacionesController.text.trim(),
    );

    await fichaMedicaService.addFichaMedica(nuevaFicha);
    mostrarMensaje('Ficha médica guardada correctamente');
    limpiarCampos();
  }

  void limpiarCampos() {
    condicionFisicaController.clear();
    condicionPsicologicaController.clear();
    estadoSaludController.clear();
    medicamentosController.clear();
    intoleranciaMedicamentosController.clear();
    referidoPorController.clear();
    viveConController.clear();
    relacionesFamiliaresController.clear();
    observacionesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Registrar Ficha Médica'),
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
                InputField(placeholder: 'Condición Física', controller: condicionFisicaController, label: '',),
                const SizedBox(height: 10),
                InputField(placeholder: 'Condición Psicológica', controller: condicionPsicologicaController, label: '',),
                const SizedBox(height: 10),
                InputField(placeholder: 'Estado de Salud', controller: estadoSaludController, label: '',),
                const SizedBox(height: 10),
                InputField(placeholder: 'Medicamentos', controller: medicamentosController, label: '',),
                const SizedBox(height: 10),
                InputField(placeholder: 'Intolerancia a Medicamentos', controller: intoleranciaMedicamentosController, label: '',),
                const SizedBox(height: 10),
                InputField(placeholder: 'Referido por', controller: referidoPorController, label: '',),
                const SizedBox(height: 10),
                InputField(placeholder: 'Vive con', controller: viveConController, label: '',),
                const SizedBox(height: 10),
                InputField(placeholder: 'Relaciones Familiares', controller: relacionesFamiliaresController, label: '',),
                const SizedBox(height: 10),
                InputField(placeholder: 'Observaciones', controller: observacionesController, label: '',),
                const SizedBox(height: 20),
                SubmitButton(text: 'Guardar Ficha Médica', onPressed: guardarFichaMedica),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
