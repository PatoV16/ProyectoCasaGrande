import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Minimental.model.dart';
import 'package:casa_grande_app/Models/Paciente.model.dart';
import 'package:casa_grande_app/Services/Minimental.service.dart';
import 'package:casa_grande_app/Services/Paciente.service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

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

  // Función para generar e imprimir el informe PDF
  Future<void> _imprimirInforme(Paciente paciente, MiniExamen miniExamen) async {
    final pdf = pw.Document();
    
    // Función auxiliar para determinar color según puntaje
    PdfColor _getColorForScore(int puntaje) {
      if (puntaje >= 27) return PdfColors.green;
      if (puntaje >= 24) return PdfColors.lightGreen;
      if (puntaje >= 19) return PdfColors.orange;
      return PdfColors.red;
    }
    
    // Obtener interpretación según puntaje
    String _getInterpretacion(int puntaje) {
      if (puntaje >= 27) return 'Normal';
      if (puntaje >= 24) return 'Deterioro cognitivo leve';
      if (puntaje >= 19) return 'Deterioro cognitivo moderado';
      return 'Deterioro cognitivo severo';
    }
    
    // Crear lista de actividades
    final items = [
      {'item': 'Orientación en el tiempo', 'puntaje': miniExamen.orientacionTiempo},
      {'item': 'Orientación en el espacio', 'puntaje': miniExamen.orientacionEspacio},
      {'item': 'Memoria inmediata', 'puntaje': miniExamen.memoria},
      {'item': 'Atención y cálculo', 'puntaje': miniExamen.atencionCalculo},
      {'item': 'Memoria diferida', 'puntaje': miniExamen.memoriaDiferida},
      {'item': 'Denominación', 'puntaje': miniExamen.denominacion},
      {'item': 'Repetición de frase', 'puntaje': miniExamen.repeticionFrase},
      {'item': 'Comprensión y ejecución', 'puntaje': miniExamen.comprensionEjecucion},
      {'item': 'Lectura', 'puntaje': miniExamen.lectura},
      {'item': 'Escritura', 'puntaje': miniExamen.escritura},
      {'item': 'Copia de dibujo', 'puntaje': miniExamen.copiaDibujo},
    ];
    
    // Crear el documento PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Mini Examen del Estado Mental', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text('Fecha: ${_formatDate(DateTime.now())}', style: pw.TextStyle(fontSize: 12)),
              ],
            ),
            pw.Divider(thickness: 1),
          ],
        ),
        build: (context) => [
          // Sección de información del paciente
          pw.Container(
            margin: pw.EdgeInsets.only(bottom: 16),
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.deepPurple),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Información del Paciente', 
                  style: pw.TextStyle(
                    fontSize: 16, 
                    fontWeight: pw.FontWeight.bold, 
                    color: PdfColors.deepPurple
                  )
                ),
                pw.SizedBox(height: 8),
                _buildPdfInfoRow('Nombre:', '${paciente.nombre} ${paciente.apellido}'),
                _buildPdfInfoRow('C.I.:', paciente.cedula),
              ],
            ),
          ),
          
          // Sección de resultados
          pw.Container(
            margin: pw.EdgeInsets.only(bottom: 16),
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.deepPurple),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Resultados del Mini Examen', 
                  style: pw.TextStyle(
                    fontSize: 16, 
                    fontWeight: pw.FontWeight.bold, 
                    color: PdfColors.deepPurple
                  )
                ),
                pw.SizedBox(height: 8),
                ...items.map((item) => _buildPdfInfoRow(
                  '${item['item']}:', 
                  '${item['puntaje']} puntos'
                )).toList(),
                pw.SizedBox(height: 16),
                
                // Resultados totales
                pw.Container(
                  padding: pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: _getColorForScore(miniExamen.puntajeTotal ?? 0).shade(0.1),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: _getColorForScore(miniExamen.puntajeTotal ?? 0)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Puntaje Total: ${miniExamen.puntajeTotal ?? 0}/30',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Interpretación: ${_getInterpretacion(miniExamen.puntajeTotal ?? 0)}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: _getColorForScore(miniExamen.puntajeTotal ?? 0),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Sección de observaciones
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.deepPurple),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Observaciones', 
                  style: pw.TextStyle(
                    fontSize: 16, 
                    fontWeight: pw.FontWeight.bold, 
                    color: PdfColors.deepPurple
                  )
                ),
              ],
            ),
          ),
        ],
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text('Casa Grande - Mini Examen del Estado Mental'),
            pw.Text(' | '),
            pw.Text('Página ${context.pageNumber} de ${context.pagesCount}'),
          ],
        ),
      ),
    );
    
    // Mostrar vista previa e imprimir
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'MiniExamen_${paciente.cedula}',
    );
  }
  
  // Función auxiliar para filas de información en PDF
  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            width: double.infinity,
            child: pw.Text(
              value.isEmpty ? 'No especificado' : value,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Examen del Estado Mental'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          // Botón de impresión en el AppBar
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () async {
              try {
                // Obtener los datos más recientes
                final pacienteData = await paciente;
                final miniExamenData = await miniExamen;
                
                if (pacienteData != null && miniExamenData != null) {
                  await _imprimirInforme(pacienteData, miniExamenData);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No hay datos disponibles para imprimir')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al generar el informe: $e')),
                );
              }
            },
          ),
        ],
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
                  print("Datos en snapshot: ${snapshot.data}");
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
                      // Botón de impresión al final del documento
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.print),
                          label: Text('Imprimir Informe'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            minimumSize: Size(double.infinity, 48),
                          ),
                          onPressed: () async {
                            try {
                              final pacienteData = await paciente;
                              final miniExamenData = await miniExamen;
                              
                              if (pacienteData != null && miniExamenData != null) {
                                await _imprimirInforme(pacienteData, miniExamenData);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('No hay datos disponibles para imprimir')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al generar el informe: $e')),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTotalScore(int puntaje) {
    String interpretacion;
    Color color;
    
    if (puntaje >= 27) {
      interpretacion = 'Normal';
      color = Colors.green;
    } else if (puntaje >= 24) {
      interpretacion = 'Deterioro cognitivo leve';
      color = Colors.lightGreen;
    } else if (puntaje >= 19) {
      interpretacion = 'Deterioro cognitivo moderado';
      color = Colors.orange;
    } else {
      interpretacion = 'Deterioro cognitivo severo';
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
            'Puntaje Total: $puntaje/30',
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
      _buildInfoRow("Orientación en el tiempo:", "${miniExamen.orientacionTiempo} puntos"),
      _buildInfoRow("Orientación en el espacio:", "${miniExamen.orientacionEspacio} puntos"),
      _buildInfoRow("Memoria inmediata:", "${miniExamen.memoria} puntos"),
      _buildInfoRow("Atención y cálculo:", "${miniExamen.atencionCalculo} puntos"),
      _buildInfoRow("Memoria diferida:", "${miniExamen.memoriaDiferida} puntos"),
      _buildInfoRow("Denominación:", "${miniExamen.denominacion} puntos"),
      _buildInfoRow("Repetición de frase:", "${miniExamen.repeticionFrase} puntos"),
      _buildInfoRow("Comprensión y ejecución:", "${miniExamen.comprensionEjecucion} puntos"),
      _buildInfoRow("Lectura:", "${miniExamen.lectura} puntos"),
      _buildInfoRow("Escritura:", "${miniExamen.escritura} puntos"),
      _buildInfoRow("Copia de dibujo:", "${miniExamen.copiaDibujo} puntos"),
    ];
  }
}