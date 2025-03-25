import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Models/Paciente.model.dart';
import '../../../Models/Referencia.model.dart';
import '../../../Services/Referencia.service.dart';
import '../../../Widgets/input_field.dart';
import '../../../Widgets/date_picker.dart';
import '../../../Widgets/submit_button.dart';
import '../../../Widgets/select_field.dart';
import '../../../Services/Paciente.service.dart';

class AgregarReferenciaScreen extends StatefulWidget {
  const AgregarReferenciaScreen({Key? key}) : super(key: key);

  @override
  _AgregarReferenciaScreenState createState() =>
      _AgregarReferenciaScreenState();
}

class _AgregarReferenciaScreenState extends State<AgregarReferenciaScreen> {
  final ReferenciaService _referenciaService = ReferenciaService();
  final TextEditingController _idPacienteController = TextEditingController();
  final TextEditingController _zonaController = TextEditingController();
  final TextEditingController _distritoController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _cantonController = TextEditingController();
  final TextEditingController _parroquiaController = TextEditingController();
  final TextEditingController _nombreInstitucionController =
      TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _razonSocialController = TextEditingController();
  final TextEditingController _directorCoordinadorController =
      TextEditingController();
  final TextEditingController _familiarAcompananteController =
      TextEditingController();
  final TextEditingController _institucionTransfiereController =
      TextEditingController();
  final TextEditingController _modalidadServiciosController =
      TextEditingController();
  final TextEditingController _motivoReferenciaController =
      TextEditingController();
  final TextEditingController _profesionalRefiereController =
      TextEditingController();
  final TextEditingController _personalAcompananteController =
      TextEditingController();
  final TextEditingController _telefonoFijoController =
      TextEditingController();
  final TextEditingController _telefonoCelularController =
      TextEditingController();
  final TextEditingController _recomendacionesController =
      TextEditingController();

  Paciente? _pacienteSeleccionado;
  DateTime _fecha = DateTime.now();

  bool validarCampos() {
    return _pacienteSeleccionado != null &&
        _zonaController.text.isNotEmpty &&
        _distritoController.text.isNotEmpty &&
        _ciudadController.text.isNotEmpty &&
        _cantonController.text.isNotEmpty &&
        _parroquiaController.text.isNotEmpty &&
        _nombreInstitucionController.text.isNotEmpty &&
        _direccionController.text.isNotEmpty &&
        _telefonoController.text.isNotEmpty &&
        _razonSocialController.text.isNotEmpty &&
        _directorCoordinadorController.text.isNotEmpty &&
        _familiarAcompananteController.text.isNotEmpty &&
        _institucionTransfiereController.text.isNotEmpty &&
        _modalidadServiciosController.text.isNotEmpty &&
        _motivoReferenciaController.text.isNotEmpty &&
        _profesionalRefiereController.text.isNotEmpty &&
        _personalAcompananteController.text.isNotEmpty &&
        _telefonoFijoController.text.isNotEmpty &&
        _telefonoCelularController.text.isNotEmpty &&
        _recomendacionesController.text.isNotEmpty;
  }

 void guardarReferencia() async {
  print('Botón presionado: guardarReferencia llamado');

  if (_pacienteSeleccionado == null) {
    print("Error: No se ha seleccionado un paciente.");
    return;
  }

  Referencia nuevaReferencia = Referencia(
    idPaciente: _pacienteSeleccionado!,
    zona: _zonaController.text,
    distrito: _distritoController.text,
    ciudad: _ciudadController.text,
    canton: _cantonController.text,
    parroquia: _parroquiaController.text,
    nombreInstitucion: _nombreInstitucionController.text,
    direccion: _direccionController.text,
    telefono: _telefonoController.text,
    razonSocial: _razonSocialController.text,
    directorCoordinador: _directorCoordinadorController.text,
    familiarAcompanante: _familiarAcompananteController.text,
    institucionTransfiere: _institucionTransfiereController.text,
    modalidadServicios: _modalidadServiciosController.text,
    motivoReferencia: _motivoReferenciaController.text,
    profesionalRefiere: _profesionalRefiereController.text,
    personalAcompanante: _personalAcompananteController.text,
    telefonoFijo: _telefonoFijoController.text,
    telefonoCelular: _telefonoCelularController.text,
    recomendaciones: _recomendacionesController.text,
    fecha: _fecha,
  );

  await _referenciaService.addReferencia(nuevaReferencia);
  print('Referencia guardada: ${nuevaReferencia.toJson()}');
  Navigator.pop(context);
}


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Agregar Referencia'),
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
  onChanged: (String? cedula) async {
    if (cedula != null && cedula.isNotEmpty) {
      _pacienteSeleccionado = await PacienteService().obtenerPacientePorCedula(cedula);
    } else {
      _pacienteSeleccionado = null;
    }
    setState(() {}); 
  }, items: [], label: '',
),

                const SizedBox(height: 10),
                DatePickerField(
                  label: 'Fecha de Referencia',
                  selectedDate: _fecha,
                  onDateSelected: (date) {
                    setState(() {
                      _fecha = date;
                    });
                  },
                ),
                InputField(
                    label: 'Zona',
                    controller: _zonaController,
                    placeholder: 'Zona'),
                InputField(
                    label: 'Distrito',
                    controller: _distritoController,
                    placeholder: 'Distrito'),
                InputField(
                    label: 'Ciudad',
                    controller: _ciudadController,
                    placeholder: 'Ciudad'),
                InputField(
                    label: 'Cantón',
                    controller: _cantonController,
                    placeholder: 'Cantón'),
                InputField(
                    label: 'Parroquia',
                    controller: _parroquiaController,
                    placeholder: 'Parroquia'),
                InputField(
                    label: 'Nombre Institución',
                    controller: _nombreInstitucionController,
                    placeholder: 'Nombre Institución'),
                InputField(
                    label: 'Dirección',
                    controller: _direccionController,
                    placeholder: 'Dirección'),
                InputField(
                    label: 'Teléfono',
                    controller: _telefonoController,
                    placeholder: 'Teléfono'),
                InputField(
                    label: 'Razón Social',
                    controller: _razonSocialController,
                    placeholder: 'Razón Social'),
                InputField(
                    label: 'Director/Coordinador',
                    controller: _directorCoordinadorController,
                    placeholder: 'Director/Coordinador'),
                InputField(
                    label: 'Familiar Acompañante',
                    controller: _familiarAcompananteController,
                    placeholder: 'Familiar Acompañante'),
                InputField(
                    label: 'Institución que Transfiere',
                    controller: _institucionTransfiereController,
                    placeholder: 'Institución que Transfiere'),
                InputField(
                    label: 'Modalidad de Servicios',
                    controller: _modalidadServiciosController,
                    placeholder: 'Modalidad de Servicios'),
                InputField(
                    label: 'Motivo de Referencia',
                    controller: _motivoReferenciaController,
                    placeholder: 'Motivo de Referencia'),
                InputField(
                    label: 'Profesional que Refiere',
                    controller: _profesionalRefiereController,
                    placeholder: 'Profesional que Refiere'),
                InputField(
                    label: 'Personal Acompañante',
                    controller: _personalAcompananteController,
                    placeholder: 'Personal Acompañante'),
                InputField(
                    label: 'Teléfono Fijo',
                    controller: _telefonoFijoController,
                    placeholder: 'Teléfono Fijo'),
                InputField(
                    label: 'Teléfono Celular',
                    controller: _telefonoCelularController,
                    placeholder: 'Teléfono Celular'),
                InputField(
                    label: 'Recomendaciones',
                    controller: _recomendacionesController,
                    placeholder: 'Recomendaciones'),
                const SizedBox(height: 20),
                SubmitButton(
                  text: 'Guardar Referencia',
                  onPressed: guardarReferencia,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
