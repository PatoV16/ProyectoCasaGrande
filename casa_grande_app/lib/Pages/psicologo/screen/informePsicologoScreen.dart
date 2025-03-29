import 'package:casa_grande_app/Models/InformePsicologico.model.dart';
import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Paciente.model.dart';
import 'package:casa_grande_app/Services/EvaluacionPsicologo.service.dart';
import 'package:casa_grande_app/Services/Paciente.service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

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
            Navigator.pushNamed(context, '/FormEvaluacionPsicologica', arguments: {'idPaciente': widget.idPaciente});
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
  Future<void> _imprimirInforme(Paciente paciente, EvaluacionPsicologica evaluacion) async {
    final pdf = pw.Document();
    
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
                pw.Text('Informe Psicológico', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
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
                _buildPdfInfoRow('Edad:', evaluacion.edad.toString()),
              ],
            ),
          ),
          
          // Sección de información de la evaluación
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
                pw.Text('Información de la Evaluación', 
                  style: pw.TextStyle(
                    fontSize: 16, 
                    fontWeight: pw.FontWeight.bold, 
                    color: PdfColors.deepPurple
                  )
                ),
                pw.SizedBox(height: 8),
                _buildPdfInfoRow('Fecha de Nacimiento:', _formatDate(evaluacion.fechaNacimiento)),
                _buildPdfInfoRow('Modalidad:', evaluacion.modalidad),
                _buildPdfInfoRow('Fecha de Ingreso al Servicio:', _formatDate(evaluacion.fechaIngresoServicio)),
              ],
            ),
          ),
          
          // Sección de antecedentes
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
                pw.Text('Antecedentes', 
                  style: pw.TextStyle(
                    fontSize: 16, 
                    fontWeight: pw.FontWeight.bold, 
                    color: PdfColors.deepPurple
                  )
                ),
                pw.SizedBox(height: 8),
                _buildPdfMultiline('Antecedentes Personales:', evaluacion.antecedentesPersonales),
                _buildPdfMultiline('Antecedentes Familiares:', evaluacion.antecedentesFamiliares),
                _buildPdfMultiline('Intervenciones Anteriores:', evaluacion.intervencionesAnteriores),
              ],
            ),
          ),
          
          // Sección de exploración del estado mental
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
                pw.Text('Exploración del Estado Mental', 
                  style: pw.TextStyle(
                    fontSize: 16, 
                    fontWeight: pw.FontWeight.bold, 
                    color: PdfColors.deepPurple
                  )
                ),
                pw.SizedBox(height: 8),
                _buildPdfMultiline('', evaluacion.exploracionEstadoMental),
              ],
            ),
          ),
          
          // Sección de situación actual
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
                pw.Text('Situación Actual', 
                  style: pw.TextStyle(
                    fontSize: 16, 
                    fontWeight: pw.FontWeight.bold, 
                    color: PdfColors.deepPurple
                  )
                ),
                pw.SizedBox(height: 8),
                _buildPdfMultiline('', evaluacion.situacionActual),
              ],
            ),
          ),
          
          // Sección de resultados de pruebas
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
                pw.Text('Resultado de las Pruebas Aplicadas', 
                  style: pw.TextStyle(
                    fontSize: 16, 
                    fontWeight: pw.FontWeight.bold, 
                    color: PdfColors.deepPurple
                  )
                ),
                pw.SizedBox(height: 8),
                _buildPdfMultiline('', evaluacion.resultadoPruebas),
              ],
            ),
          ),
          
          // Sección de conclusiones y recomendaciones
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.deepPurple),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Conclusiones y Recomendaciones', 
                  style: pw.TextStyle(
                    fontSize: 16, 
                    fontWeight: pw.FontWeight.bold, 
                    color: PdfColors.deepPurple
                  )
                ),
                pw.SizedBox(height: 8),
                _buildPdfMultiline('Conclusiones:', evaluacion.conclusiones),
                _buildPdfMultiline('Recomendaciones:', evaluacion.recomendaciones),
              ],
            ),
          ),
        ],
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text('Casa Grande - Informe Psicológico'),
            pw.Text(' | '),
            pw.Text('Página ${context.pageNumber} de ${context.pagesCount}'),
          ],
        ),
      ),
    );
    
    // Mostrar vista previa e imprimir
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Informe_Psicologico_${paciente.cedula}',
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
  
  // Función para texto multilínea en PDF
  pw.Widget _buildPdfMultiline(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 12.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          if (label.isNotEmpty) pw.SizedBox(height: 4),
          pw.Container(
            padding: pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            width: double.infinity,
            child: pw.Text(
              value.isEmpty ? 'No especificado' : value,
              textAlign: pw.TextAlign.justify,
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
        title: const Text('Evaluación Psicológica'),
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
                final evaluacionData = await evaluacionPsicologica;
                
                if (pacienteData != null && evaluacionData != null) {
                  await _imprimirInforme(pacienteData, evaluacionData);
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
              future: Future.wait([paciente, evaluacionPsicologica]),
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
                          _buildInfoRow('Fecha de Nacimiento:', _formatDate(evaluacion.fechaNacimiento)),
                          _buildInfoRow('Modalidad:', evaluacion.modalidad),
                          _buildInfoRow('Fecha de Ingreso al Servicio:', _formatDate(evaluacion.fechaIngresoServicio)),
                        ],
                      ),
                      _buildSection(
                        title: 'Antecedentes',
                        icon: Icons.history,
                        children: [
                          _buildMultiline('Antecedentes Personales:', evaluacion.antecedentesPersonales),
                          _buildMultiline('Antecedentes Familiares:', evaluacion.antecedentesFamiliares),
                          _buildMultiline('Intervenciones Anteriores:', evaluacion.intervencionesAnteriores),
                        ],
                      ),
                      _buildSection(
                        title: 'Exploración del Estado Mental',
                        icon: Icons.psychology,
                        children: [
                          _buildMultiline('', evaluacion.exploracionEstadoMental),
                        ],
                      ),
                      _buildSection(
                        title: 'Situación Actual',
                        icon: Icons.assessment,
                        children: [
                          _buildMultiline('', evaluacion.situacionActual),
                        ],
                      ),
                      _buildSection(
                        title: 'Resultado de las Pruebas Aplicadas',
                        icon: Icons.assignment,
                        children: [
                          _buildMultiline('', evaluacion.resultadoPruebas),
                        ],
                      ),
                      _buildSection(
                        title: 'Conclusiones y Recomendaciones',
                        icon: Icons.note,
                        children: [
                          _buildMultiline('Conclusiones:', evaluacion.conclusiones),
                          _buildMultiline('Recomendaciones:', evaluacion.recomendaciones),
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
                              final evaluacionData = await evaluacionPsicologica;
                              
                              if (pacienteData != null && evaluacionData != null) {
                                await _imprimirInforme(pacienteData, evaluacionData);
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

  Widget _buildMultiline(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])),
          if (label.isNotEmpty) SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            width: double.infinity,
            child: Text(
              value.isEmpty ? 'No especificado' : value,
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}