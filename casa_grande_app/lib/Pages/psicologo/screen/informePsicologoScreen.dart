import 'package:flutter/material.dart';
import '../../../Models/InformePsicologico.model.dart';
import '../../../Models/Paciente.model.dart';
import '../../../Services/EvaluacionPsicologo.service.dart';
import '../../../Services/Paciente.service.dart';

class EvaluacionPsicologicaDetalleScreen extends StatefulWidget {
  final String idPaciente;

  const EvaluacionPsicologicaDetalleScreen({Key? key, required this.idPaciente}) : super(key: key);

  @override
  _EvaluacionPsicologicaDetalleScreenState createState() => _EvaluacionPsicologicaDetalleScreenState();
}

class _EvaluacionPsicologicaDetalleScreenState extends State<EvaluacionPsicologicaDetalleScreen> {
  late Future<Paciente?> paciente;
  late Future<EvaluacionPsicologica?> evaluacionPsicologica;
  bool _checkingData = true;

  @override
  void initState() {
    super.initState();
    paciente = PacienteService().obtenerPacientePorCedula(widget.idPaciente);
    evaluacionPsicologica = EvaluacionPsicologicaService().getEvaluacionPsicologicaByPaciente(widget.idPaciente);
    _verificarDatosDisponibles();
  }

  Future<void> _verificarDatosDisponibles() async {
    try {
      final resultados = await Future.wait([paciente, evaluacionPsicologica]);

      if (resultados[0] == null || resultados[1] == null) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(context, '/FormInforme', arguments: {'idPaciente': widget.idPaciente});
          });
        }
      }
    } catch (e) {
      print('Error al verificar datos: $e');
    } finally {
      if (mounted) {
        setState(() {
          _checkingData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la Evaluación Psicológica'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: _checkingData
          ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : FutureBuilder<List<dynamic>>(
              future: Future.wait([paciente, evaluacionPsicologica]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                } else if (snapshot.hasError) {
                  return _buildError('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data![0] == null || snapshot.data![1] == null) {
                  return _buildNoData();
                }

                Paciente paciente = snapshot.data![0] as Paciente;
                EvaluacionPsicologica evaluacion = snapshot.data![1] as EvaluacionPsicologica;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        title: 'Información del Paciente',
                        icon: Icons.person,
                        children: [
                          _buildInfoRow('Nombre:', '${paciente.nombre} ${paciente.apellido}'),
                          _buildInfoRow('C.I.:', paciente.cedula),
                          _buildInfoRow('Edad:', evaluacion.edad.toString()),
                        ],
                      ),
                      _buildSection(
                        title: 'Información de la Evaluación',
                        icon: Icons.info_outline,
                        children: [
                          _buildInfoRow('Fecha de Nacimiento:', _formatearFecha(evaluacion.fechaNacimiento)),
                          _buildInfoRow('Modalidad:', evaluacion.modalidad),
                          _buildInfoRow('Fecha de Ingreso al Servicio:', _formatearFecha(evaluacion.fechaIngresoServicio)),
                        ],
                      ),
                      _buildSection(
                        title: 'Antecedentes',
                        icon: Icons.history,
                        children: [
                          _buildInfoRow('Antecedentes Personales:', evaluacion.antecedentesPersonales),
                          _buildInfoRow('Antecedentes Familiares:', evaluacion.antecedentesFamiliares),
                          _buildInfoRow('Intervenciones Anteriores:', evaluacion.intervencionesAnteriores),
                        ],
                      ),
                      _buildSection(
                        title: 'Exploración del Estado Mental',
                        icon: Icons.psychology,
                        children: [
                          _buildInfoRow('Exploración del Estado Mental:', evaluacion.exploracionEstadoMental),
                        ],
                      ),
                      _buildSection(
                        title: 'Situación Actual',
                        icon: Icons.assessment,
                        children: [
                          _buildInfoRow('Situación Actual:', evaluacion.situacionActual),
                        ],
                      ),
                      _buildSection(
                        title: 'Resultado de las Pruebas Aplicadas',
                        icon: Icons.assignment,
                        children: [
                          _buildInfoRow('Resultado de las Pruebas Aplicadas:', evaluacion.resultadoPruebas),
                        ],
                      ),
                      _buildSection(
                        title: 'Conclusiones y Recomendaciones',
                        icon: Icons.note,
                        children: [
                          _buildInfoRow('Conclusiones:', evaluacion.conclusiones),
                          _buildInfoRow('Recomendaciones:', evaluacion.recomendaciones),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return "${fecha.day}/${fecha.month}/${fecha.year}";
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 48, color: Colors.amber),
          SizedBox(height: 16),
          Text('No hay datos disponibles para este paciente.'),
          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/FormEvaluacionPsicologica', arguments: {'idPaciente': widget.idPaciente});
            },
            child: Text('Registrar nueva evaluación'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.deepPurple),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])),
          SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            width: double.infinity,
            child: Text(value.isEmpty ? 'No especificado' : value, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}