  import 'package:flutter/material.dart';
  import '../../../Models/Yesavage.model.dart';
  import '../../../Models/Paciente.model.dart';
  import '../../../Services/Yesavage.service.dart';
  import '../../../Services/Paciente.service.dart';

  class YesavageDetalleScreen extends StatefulWidget {
    final String idPaciente;

    const YesavageDetalleScreen({Key? key, required this.idPaciente}) : super(key: key);

    @override
    _YesavageDetalleScreenState createState() => _YesavageDetalleScreenState();
  }

  class _YesavageDetalleScreenState extends State<YesavageDetalleScreen> {
    late Future<Paciente?> paciente;
    late Future<Yesavage?> yesavage;
    bool _checkingData = true;

    // Lista de preguntas para mostrar (misma lista del formulario)
    final List<Map<String, String>> preguntas = [
      {'pregunta': '¿Está Ud. básicamente satisfecho con su vida?', 'respuesta1': 'NO', 'respuesta2': 'si'},
      {'pregunta': '¿Ha disminuido o abandonado muchos de sus intereses o actividades previas?', 'respuesta1': 'SI', 'respuesta2': 'no'},
      {'pregunta': '¿Siente que su vida está vacía?', 'respuesta1': 'SI', 'respuesta2': 'no'},
      {'pregunta': '¿Se siente aburrido frecuentemente?', 'respuesta1': 'SI', 'respuesta2': 'no'},
      {'pregunta': '¿Está Ud. de buen ánimo la mayoría del tiempo?', 'respuesta1': 'si', 'respuesta2': 'NO'},
      {'pregunta': '¿Está preocupado o teme que algo malo le va a pasar?', 'respuesta1': 'SI', 'respuesta2': 'no'},
      {'pregunta': '¿Se siente feliz la mayor parte del tiempo?', 'respuesta1': 'si', 'respuesta2': 'NO'},
      {'pregunta': '¿Se siente con frecuencia desamparado?', 'respuesta1': 'SI', 'respuesta2': 'no'},
      {'pregunta': '¿Prefiere Ud. quedarse en casa a salir a hacer cosas nuevas?', 'respuesta1': 'SI', 'respuesta2': 'no'},
      {'pregunta': '¿Siente Ud. que tiene más problemas con su memoria que otras personas de su edad?', 'respuesta1': 'SI', 'respuesta2': 'no'},
      {'pregunta': '¿Cree Ud. que es maravilloso estar vivo?', 'respuesta1': 'si', 'respuesta2': 'NO'},
      {'pregunta': '¿Se siente inútil o despreciable como está Ud. actualmente?', 'respuesta1': 'SI', 'respuesta2': 'no'},
      {'pregunta': '¿Se siente lleno de energía?', 'respuesta1': 'si', 'respuesta2': 'NO'},
      {'pregunta': '¿Se encuentra sin esperanza ante su situación actual?', 'respuesta1': 'SI', 'respuesta2': 'no'},
      {'pregunta': '¿Cree Ud. que las otras personas están en general mejor que Usted?', 'respuesta1': 'SI', 'respuesta2': 'no'},
    ];

    @override
    void initState() {
      super.initState();
      paciente = PacienteService().obtenerPacientePorCedula(widget.idPaciente);
      yesavage = YesavageService().getYesavageByPaciente(widget.idPaciente);
      _verificarDatosDisponibles();
    }

    Future<void> _verificarDatosDisponibles() async {
      try {
        final resultados = await Future.wait([paciente, yesavage]);

        if (resultados[0] == null || resultados[1] == null) {
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamed(context, '/FormYesavage', arguments: {'idPaciente': widget.idPaciente});
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
          title: const Text('Detalle del Examen Yesavage'),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
        ),
        body: _checkingData
            ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
            : FutureBuilder<List<dynamic>>(
                future: Future.wait([paciente, yesavage]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                  } else if (snapshot.hasError) {
                    return _buildError('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data![0] == null || snapshot.data![1] == null) {
                    return _buildNoData();
                  }

                  Paciente paciente = snapshot.data![0] as Paciente;
                  Yesavage yesavage = snapshot.data![1] as Yesavage;

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
                            _buildInfoRow('Edad:', yesavage.edad.toString()),
                          ],
                        ),
                        _buildSection(
                          title: 'Información del Examen',
                          icon: Icons.info_outline,
                          children: [
                            _buildInfoRow('Zona:', yesavage.zona),
                            _buildInfoRow('Distrito:', yesavage.distrito),
                            _buildInfoRow('Modalidad de Atención:', yesavage.modalidadAtencion),
                            _buildInfoRow('Unidad de Atención:', yesavage.unidadAtencion),
                            _buildInfoRow('Fecha de Aplicación:', _formatearFecha(yesavage.fechaAplicacion)),
                          ],
                        ),
                        _buildSection(
                          title: 'Respuestas del Examen Yesavage',
                          icon: Icons.assessment,
                          children: [
                            ..._buildYesavageItems(yesavage),
                            SizedBox(height: 16),
                            _buildTotalScore(yesavage.puntos),
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

    Widget _buildTotalScore(int puntaje) {
      String interpretacion = '';
      Color color;
      
      // Evaluación según criterios de Yesavage
      if (puntaje <= 5) {
        interpretacion = 'Normal';
        color = Colors.green;
      } else if (puntaje > 5 && puntaje <= 10) {
        interpretacion = 'Depresión Leve';
        color = Colors.orange;
      } else {
        interpretacion = 'Depresión Establecida';
        color = Colors.red;
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
                Navigator.pushNamed(context, '/FormYesavage', arguments: {'idPaciente': widget.idPaciente});
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

    List<Widget> _buildYesavageItems(Yesavage yesavage) {
      List<Widget> items = [];
      Map<String, bool> respuestas = yesavage.respuestas;

      for (int i = 0; i < preguntas.length; i++) {
        String pregunta = preguntas[i]['pregunta']!;
        String respuesta1 = preguntas[i]['respuesta1']!; // El valor SI (positivo)
        String respuesta2 = preguntas[i]['respuesta2']!; // El valor no (negativo)
        
        // Obtenemos la respuesta del índice correspondiente
        bool? valorRespuesta = respuestas['$i'];
        
        // Si no hay respuesta para esta pregunta, saltamos
        if (valorRespuesta == null) continue;
        
        // Determinamos cuál respuesta mostrar según el valor booleano
        String respuestaSeleccionada = valorRespuesta ? respuesta1 : respuesta2;
        
        // Estilo para resaltar las respuestas positivas
        TextStyle estiloRespuesta = valorRespuesta 
            ? TextStyle(fontWeight: FontWeight.bold, color: Colors.red) 
            : TextStyle(color: Colors.black);
        
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pregunta, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: valorRespuesta ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: valorRespuesta ? Colors.red.withOpacity(0.3) : Colors.grey.withOpacity(0.3)),
                  ),
                  width: double.infinity,
                  child: Text(
                    "Respuesta: $respuestaSeleccionada",
                    style: estiloRespuesta,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return items;
    }
  }