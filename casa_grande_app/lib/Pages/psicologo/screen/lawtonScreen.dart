import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Lawton.model.dart';
import 'package:casa_grande_app/Models/Paciente.model.dart';
import 'package:casa_grande_app/Services/Lawton.service.dart';
import 'package:casa_grande_app/Services/Paciente.service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class LawtonDetalleScreen extends StatefulWidget {
  final String idPaciente;

  const LawtonDetalleScreen({Key? key, required this.idPaciente}) : super(key: key);

  @override
  _LawtonDetalleScreenState createState() => _LawtonDetalleScreenState();
}

class _LawtonDetalleScreenState extends State<LawtonDetalleScreen> {
  late Future<Paciente?> paciente;
  late Future<LawtonBrody?> lawton;
  bool _checkingData = true;

  @override
  void initState() {
    super.initState();
    paciente = PacienteService().obtenerPacientePorCedula(widget.idPaciente);
    lawton = LawtonBrodyService().getLawtonBrodyById(widget.idPaciente);
    print(widget.idPaciente);
    print(lawton);
    _verificarDatosDisponibles();
  }

  Future<void> _verificarDatosDisponibles() async {
    try {
      final resultados = await Future.wait([paciente, lawton]);

      if (resultados[0] == null || resultados[1] == null) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(context, '/FormLawton', arguments: {'idPaciente': widget.idPaciente});
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
  Future<void> _imprimirInforme(Paciente paciente, LawtonBrody lawton) async {
    final pdf = pw.Document();
    
    // Función auxiliar para determinar color según puntaje
    PdfColor _getColorForScore(int puntaje) {
      return puntaje < 5 ? PdfColors.red : PdfColors.green;
    }
    
    // Obtener interpretación según puntaje
    String _getInterpretacion(int puntaje) {
      return puntaje < 5 ? 'Dependencia' : 'Independencia';
    }
    
    // Crear lista de actividades
    final actividades = [
      {'actividad': 'Uso de teléfono', 'puntaje': lawton.usoTelefono},
      {'actividad': 'Hacer compras', 'puntaje': lawton.hacerCompras},
      {'actividad': 'Preparar comida', 'puntaje': lawton.prepararComida},
      {'actividad': 'Cuidado de la casa', 'puntaje': lawton.cuidadoCasa},
      {'actividad': 'Lavado de ropa', 'puntaje': lawton.lavadoRopa},
      {'actividad': 'Uso de transporte', 'puntaje': lawton.usoTransporte},
      {'actividad': 'Responsabilidad con medicamentos', 'puntaje': lawton.responsabilidadMedicacion},
      {'actividad': 'Manejo del dinero', 'puntaje': lawton.capacidadDinero},
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
                pw.Text('Escala de Lawton-Brody', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
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
                _buildPdfInfoRow('Fecha de Evaluación:', _formatDate(lawton.fechaEvaluacion ?? DateTime.now())),
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
                pw.Text('Resultados de la Escala de Lawton-Brody', 
                  style: pw.TextStyle(
                    fontSize: 16, 
                    fontWeight: pw.FontWeight.bold, 
                    color: PdfColors.deepPurple
                  )
                ),
                pw.SizedBox(height: 8),
                ...actividades.map((item) => _buildPdfInfoRow(
                  '${item['actividad']}:', 
                  '${item['puntaje']} puntos'
                )).toList(),
                pw.SizedBox(height: 16),
                
                // Resultados totales
                pw.Container(
                  padding: pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: _getColorForScore(lawton.puntajeTotal ?? 0).shade(0.1),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: _getColorForScore(lawton.puntajeTotal ?? 0)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Puntaje Total: ${lawton.puntajeTotal ?? 0}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Interpretación: ${_getInterpretacion(lawton.puntajeTotal ?? 0)}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: _getColorForScore(lawton.puntajeTotal ?? 0),
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
                pw.SizedBox(height: 8),
                _buildPdfInfoRow('Comentario:', lawton.observaciones ?? 'No especificado'),
              ],
            ),
          ),
        ],
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text('Casa Grande - Evaluación de Lawton-Brody'),
            pw.Text(' | '),
            pw.Text('Página ${context.pageNumber} de ${context.pagesCount}'),
          ],
        ),
      ),
    );
    
    // Mostrar vista previa e imprimir
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Escala_de_Lawton_${paciente.cedula}',
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
        title: const Text('Escala de Lawton-Brody'),
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
                final lawtonData = await lawton;
                
                if (pacienteData != null && lawtonData != null) {
                  await _imprimirInforme(pacienteData, lawtonData);
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
              future: Future.wait([paciente, lawton]),
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
                LawtonBrody lawton = snapshot.data![1] as LawtonBrody;

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
                          _buildInfoRow('Fecha de Evaluación:', _formatDate(lawton.fechaEvaluacion ?? DateTime.now())),
                        ],
                      ),
                      _buildSection(
                        title: 'Resultados de la Escala de Lawton-Brody',
                        icon: Icons.assessment,
                        children: [
                          ..._buildLawtonItems(lawton),
                          SizedBox(height: 16),
                          _buildTotalScore(lawton.puntajeTotal ?? 0),
                        ],
                      ),
                      _buildSection(
                        title: 'Observaciones',
                        icon: Icons.note,
                        children: [
                          _buildInfoRow('Comentario:', lawton.observaciones ?? 'No especificado'),
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
                              final lawtonData = await lawton;
                              
                              if (pacienteData != null && lawtonData != null) {
                                await _imprimirInforme(pacienteData, lawtonData);
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
                Navigator.pushNamed(context, '/FormLawton', arguments: widget.idPaciente);
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

   List<Widget> _buildLawtonItems(LawtonBrody lawton) {
    return [
      _buildInfoRow("Uso de teléfono:", "${lawton.usoTelefono} puntos"),
      _buildInfoRow("Hacer compras:", "${lawton.hacerCompras} puntos"),
      _buildInfoRow("Preparar comida:", "${lawton.prepararComida} puntos"),
      _buildInfoRow("Cuidado de la casa:", "${lawton.cuidadoCasa} puntos"),
      _buildInfoRow("Lavado de ropa:", "${lawton.lavadoRopa} puntos"),
      _buildInfoRow("Uso de transporte:", "${lawton.usoTransporte} puntos"),
      _buildInfoRow("Responsabilidad con medicamentos:", "${lawton.responsabilidadMedicacion} puntos"),
      _buildInfoRow("Manejo del dinero:", "${lawton.capacidadDinero} puntos"),
    ];
  }
}