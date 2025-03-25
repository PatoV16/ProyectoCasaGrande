import 'package:flutter/material.dart';

import '../../../Models/InformePsicologico.model.dart';
import '../../../Services/EvaluacionPsicologo.service.dart';

class EvaluacionPsicologicaForm extends StatefulWidget {
  final String idPaciente;

  const EvaluacionPsicologicaForm({Key? key, required this.idPaciente}) : super(key: key);

  @override
  _EvaluacionPsicologicaFormState createState() => _EvaluacionPsicologicaFormState();
}

class _EvaluacionPsicologicaFormState extends State<EvaluacionPsicologicaForm> {
  final EvaluacionPsicologicaService evaluacionPsicologicaService = EvaluacionPsicologicaService();
  final TextEditingController _antecedentesPersonalesController = TextEditingController();
  final TextEditingController _antecedentesFamiliaresController = TextEditingController();
  final TextEditingController _intervencionesAnterioresController = TextEditingController();
  final TextEditingController _exploracionEstadoMentalController = TextEditingController();
  final TextEditingController _situacionActualController = TextEditingController();
  final TextEditingController _resultadoPruebasController = TextEditingController();
  final TextEditingController _conclusionesController = TextEditingController();
  final TextEditingController _recomendacionesController = TextEditingController();
  bool _isLoading = false;
  DateTime fechaEvaluacion = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Evaluación Psicológica')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDateField('Fecha de Evaluacion'),
                  _buildTextField(_antecedentesPersonalesController, 'Antecedentes Personales'),
                  _buildTextField(_antecedentesFamiliaresController, 'Antecedentes Familiares'),
                  _buildTextField(_intervencionesAnterioresController, 'Intervenciones Anteriores'),
                  _buildTextField(_exploracionEstadoMentalController, 'Exploración del Estado Mental'),
                  _buildTextField(_situacionActualController, 'Situación Actual'),
                  _buildTextField(_resultadoPruebasController, 'Resultado de las Pruebas Aplicadas'),
                  _buildTextField(_conclusionesController, 'Conclusiones'),
                  _buildTextField(_recomendacionesController, 'Recomendaciones'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: guardarEvaluacionPsicologica,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDateField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null && picked != fechaEvaluacion) {
            setState(() {
              fechaEvaluacion = picked;
            });
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "${fechaEvaluacion.toLocal()}".split(' ')[0],
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.calendar_today),
            ],
          ),
        ),
      ),
    );
  }

  void guardarEvaluacionPsicologica() async {
    setState(() => _isLoading = true);
    try {
      EvaluacionPsicologica nuevaEvaluacion = EvaluacionPsicologica(
        id_paciente: widget.idPaciente,
        fechaNacimiento: fechaEvaluacion,
        edad: DateTime.now().year - fechaEvaluacion.year,
        modalidad: 'Presencial', // Puedes cambiar esto según sea necesario
        fechaIngresoServicio: DateTime.now(),
        antecedentesPersonales: _antecedentesPersonalesController.text,
        antecedentesFamiliares: _antecedentesFamiliaresController.text,
        intervencionesAnteriores: _intervencionesAnterioresController.text,
        exploracionEstadoMental: _exploracionEstadoMentalController.text,
        situacionActual: _situacionActualController.text,
        resultadoPruebas: _resultadoPruebasController.text,
        conclusiones: _conclusionesController.text,
        recomendaciones: _recomendacionesController.text,
      );

      await evaluacionPsicologicaService.addEvaluacionPsicologica(nuevaEvaluacion);
      mostrarMensaje('Evaluación Psicológica guardada correctamente');
    } catch (e) {
      mostrarMensaje('Error al guardar: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void mostrarMensaje(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Información"),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}