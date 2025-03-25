import 'package:flutter/material.dart';
import '../../../Models/Minimental.model.dart';
import '../../../Models/Paciente.model.dart';
import '../../../Services/Minimental.service.dart';
import '../../../Services/Paciente.service.dart'; // Ajusta la ruta según tu estructura

class MiniExamenDetalleScreen extends StatefulWidget {
  final String idPaciente;

  const MiniExamenDetalleScreen({Key? key, required this.idPaciente}) : super(key: key);

  @override
  _MiniExamenDetalleScreenState createState() => _MiniExamenDetalleScreenState();
}

class _MiniExamenDetalleScreenState extends State<MiniExamenDetalleScreen> {
  late Future<Paciente?> paciente;
  late Future<MiniExamen?> miniExamen;
  bool _checkingData = true;

  @override
  void initState() {
    super.initState();
    paciente = PacienteService().obtenerPacientePorCedula(widget.idPaciente);
    miniExamen = MiniExamenService().getMiniExamenByPaciente(widget.idPaciente);
    _verificarDatosDisponibles();
  }

  Future<void> _verificarDatosDisponibles() async {
    try {
      final resultados = await Future.wait([paciente, miniExamen]);

      if (resultados[0] == null || resultados[1] == null) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(context, '/FormMiniExamen', arguments: {'idPaciente': widget.idPaciente});
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
        title: const Text('Detalle del Mini Examen'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: _checkingData
          ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : FutureBuilder<List<dynamic>>(
              future: Future.wait([paciente, miniExamen]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                } else if (snapshot.hasError) {
                  return _buildError('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data![0] == null || snapshot.data![1] == null) {
                  return _buildNoData();
                }

                Paciente paciente = snapshot.data![0] as Paciente;
                MiniExamen miniExamen = snapshot.data![1] as MiniExamen;

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
                        ],
                      ),
                      _buildSection(
                        title: 'Resultados del Mini Examen',
                        icon: Icons.assessment,
                        children: [
                          ..._buildMiniExamenItems(miniExamen),
                          SizedBox(height: 16),
                          _buildTotalScore(miniExamen.puntajeTotal ?? 0),
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
    String interpretacion = puntaje < 5 ? 'Dependencia' : 'Independencia';
    Color color = puntaje < 5 ? Colors.red : Colors.green;

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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Interpretación: $interpretacion',
            style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold),
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
              Navigator.pushNamed(context, '/FormMiniExamen', arguments: widget.idPaciente);
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

  List<Widget> _buildMiniExamenItems(MiniExamen miniExamen) {
    return [
   _buildInfoRow("Orientación en el tiempo:", miniExamen.orientacionTiempo.toString()),
          _buildInfoRow("Orientación en el espacio:", miniExamen.orientacionEspacio.toString()),
          _buildInfoRow("Memoria inmediata:", miniExamen.memoria.toString()),
          _buildInfoRow("Atención y cálculo:", miniExamen.atencionCalculo.toString()),
          _buildInfoRow("Memoria diferida:", miniExamen.memoriaDiferida.toString()),
          _buildInfoRow("Denominación:", miniExamen.denominacion.toString()),
          _buildInfoRow("Repetición de frase:", miniExamen.repeticionFrase.toString()),
          _buildInfoRow("Comprensión y ejecución:", miniExamen.comprensionEjecucion.toString()),
          _buildInfoRow("Lectura:", miniExamen.lectura.toString()),
          _buildInfoRow("Escritura:", miniExamen.escritura.toString()),
          _buildInfoRow("Copia de dibujo:", miniExamen.copiaDibujo.toString()),
          _buildInfoRow("Puntaje total:", miniExamen.puntajeTotal.toString()),
        
    ];
  }
}
