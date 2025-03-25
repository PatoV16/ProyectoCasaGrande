import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Barthel.model.dart';
import 'package:casa_grande_app/Models/Paciente.model.dart';
import 'package:casa_grande_app/Services/Barthel.service.dart';
import 'package:casa_grande_app/Services/Paciente.service.dart';

class BarthelDetalleScreen extends StatefulWidget {
  final String idPaciente;

  const BarthelDetalleScreen({Key? key, required this.idPaciente}) : super(key: key);

  @override
  _BarthelDetalleScreenState createState() => _BarthelDetalleScreenState();
}

class _BarthelDetalleScreenState extends State<BarthelDetalleScreen> {
  late Future<Paciente?> paciente;
  late Future<Barthel?> barthel;
  bool _checkingData = true;

  @override
  void initState() {
    super.initState();
    paciente = PacienteService().obtenerPacientePorCedula(widget.idPaciente);
    barthel = BarthelService().getBarthelById(widget.idPaciente);
    print(widget.idPaciente);
    print(barthel);
    // Verificar si hay datos y navegar después de la inicialización
   _verificarDatosDisponibles();
  }

  Future<void> _verificarDatosDisponibles() async {
    try {
      final resultados = await Future.wait([paciente, barthel]);
      
      // Verificar si tenemos datos válidos
      if (resultados[0] == null || resultados[1] == null) {
        // Esperar a que el widget esté montado antes de navegar
        if (mounted) {
          // Usar addPostFrameCallback para evitar navegar durante el build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(context, '/FormBarthel', arguments: {'idPaciente': widget.idPaciente});
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
        title: const Text('Escala de Barthel'),
        backgroundColor: Colors.teal[700],
        elevation: 0,
      ),
      body: _checkingData
          ? Center(child: CircularProgressIndicator(color: Colors.teal[700]))
          : FutureBuilder<List<dynamic>>(
              future: Future.wait([paciente, barthel]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.teal[700]));
                } else if (snapshot.hasError) {
                  return _buildError('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data![0] == null || snapshot.data![1] == null) {
                  // En lugar de navegar, mostrar un mensaje
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
                            backgroundColor: Colors.teal[700],
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context, 
                              '/FormBarthel', 
                              arguments: widget.idPaciente
                            );
                          },
                          child: Text('Registrar nueva evaluación'),
                        ),
                      ],
                    ),
                  );
                }

                Paciente paciente = snapshot.data![0] as Paciente;
                Barthel barthel = snapshot.data![1] as Barthel;

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
                          _buildInfoRow('Fecha de Evaluación:', _formatDate(barthel.fechaEvaluacion ?? DateTime.now())),
                        ],
                      ),
                      _buildSection(
                        title: 'Resultados de la Escala de Barthel',
                        icon: Icons.assessment,
                        children: [
                          ..._buildBarthelItems(barthel),
                          SizedBox(height: 16),
                          _buildTotalScore(barthel.puntajeTotal ?? 0),
                        ],
                      ),
                      _buildSection(
                        title: 'Observaciones',
                        icon: Icons.note,
                        children: [
                          _buildInfoRow('Comentario:', barthel.observaciones ?? 'No especificado'),
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

  Widget _buildTotalScore(int puntaje) {
    String interpretacion = '';
    Color color = Colors.green;
    
    if (puntaje < 21) {
      interpretacion = 'Dependencia total';
      color = Colors.red;
    } else if (puntaje < 61) {
      interpretacion = 'Dependencia severa';
      color = Colors.orange;
    } else if (puntaje < 91) {
      interpretacion = 'Dependencia moderada';
      color = Colors.amber;
    } else if (puntaje < 100) {
      interpretacion = 'Dependencia leve';
      color = Colors.lightGreen;
    } else {
      interpretacion = 'Independencia';
      color = Colors.green;
    }
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Puntaje Total: $puntaje',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Interpretación: $interpretacion',
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.teal[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.teal),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
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
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800]),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!)),
            width: double.infinity,
            child: Text(
              value.isEmpty ? 'No especificado' : value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBarthelItems(Barthel barthel) {
    final actividades = [
      {'actividad': 'Comer', 'puntaje': barthel.comer},
      {'actividad': 'Traslado', 'puntaje': barthel.traslado},
      {'actividad': 'Aseo Personal', 'puntaje': barthel.aseoPersonal},
      {'actividad': 'Uso de Retrete', 'puntaje': barthel.usoRetrete},
      {'actividad': 'Bañarse', 'puntaje': barthel.banarse},
      {'actividad': 'Desplazarse', 'puntaje': barthel.desplazarse},
      {'actividad': 'Subir Escaleras', 'puntaje': barthel.subirEscaleras},
      {'actividad': 'Vestirse', 'puntaje': barthel.vestirse},
      {'actividad': 'Control de Heces', 'puntaje': barthel.controlHeces},
      {'actividad': 'Control de Orina', 'puntaje': barthel.controlOrina},
    ];

    return actividades
        .where((item) => item['puntaje'] != null) // Filtrar los valores nulos
        .map((item) => _buildInfoRow(item['actividad'].toString(), '${item['puntaje']} puntos'))
        .toList();
  }
}