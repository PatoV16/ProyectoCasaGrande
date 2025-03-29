import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Yesavage.model.dart';
import 'package:casa_grande_app/Models/Paciente.model.dart';
import 'package:casa_grande_app/Services/Yesavage.service.dart';
import 'package:casa_grande_app/Services/Paciente.service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

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
    {'pregunta': '¿Está Ud. básicamente satisfecho con su vida?', 'respuesta1': 'NO', 'respuesta2': 'SI'},
    {'pregunta': '¿Ha disminuido o abandonado muchos de sus intereses o actividades previas?', 'respuesta1': 'SI', 'respuesta2': 'NO'},
    {'pregunta': '¿Siente que su vida está vacía?', 'respuesta1': 'SI', 'respuesta2': 'NO'},
    {'pregunta': '¿Se siente aburrido frecuentemente?', 'respuesta1': 'SI', 'respuesta2': 'NO'},
    {'pregunta': '¿Está Ud. de buen ánimo la mayoría del tiempo?', 'respuesta1': 'SI', 'respuesta2': 'NO'},
    {'pregunta': '¿Está preocupado o teme que algo malo le va a pasar?', 'respuesta1': 'SI', 'respuesta2': 'NO'},
    {'pregunta': '¿Se siente feliz la mayor parte del tiempo?', 'respuesta1': 'SI', 'respuesta2': 'NO'},
    {'pregunta': '¿Se siente con frecuencia desamparado?', 'respuesta1': 'SI', 'respuesta2': 'NO'},
    {'pregunta': '¿Prefiere Ud. quedarse en casa a salir a hacer cosas nuevas?', 'respuesta1': 'SI', 'respuesta2': 'NO'},
    {'pregunta': '¿Siente Ud. que tiene más problemas con su memoria que otras personas de su edad?', 'respuesta1': 'SI', 'respuesta2': 'NO'},
    {'pregunta': '¿Cree Ud. que es maravilloso estar vivo?', 'respuesta1': 'SI', 'respuesta2': 'NO'},
    {'pregunta': '¿Se siente inútil o despreciable como está Ud. actualmente?', 'respuesta1': 'SI', 'respuesta2': 'NO'},
    {'pregunta': '¿Se siente lleno de energía?', 'respuesta1': 'SI', 'respuesta2': 'NO'},
    {'pregunta': '¿Se encuentra sin esperanza ante su situación actual?', 'respuesta1': 'SI', 'respuesta2': 'NO'},
    {'pregunta': '¿Cree Ud. que las otras personas están en general mejor que Usted?', 'respuesta1': 'SI', 'respuesta2': 'NO'},
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

  // Función para generar e imprimir el informe PDF
  Future<void> _imprimirInforme(Paciente paciente, Yesavage yesavage) async {
    final pdf = pw.Document();
    
    // Función auxiliar para determinar color según puntaje
    PdfColor _getColorForScore(int puntaje) {
      if (puntaje <= 5) return PdfColors.green;
      if (puntaje <= 10) return PdfColors.orange;
      return PdfColors.red;
    }
    
    // Obtener interpretación según puntaje
    String _getInterpretacion(int puntaje) {
      if (puntaje <= 5) return 'Normal';
      if (puntaje <= 10) return 'Depresión Leve';
      return 'Depresión Establecida';
    }
    
    // Crear lista de preguntas y respuestas para el PDF
    final items = <pw.Widget>[];
    Map<String, bool> respuestas = yesavage.respuestas;
    
    for (int i = 0; i < preguntas.length; i++) {
      String pregunta = preguntas[i]['pregunta']!;
      String respuesta1 = preguntas[i]['respuesta1']!;
      String respuesta2 = preguntas[i]['respuesta2']!;
      
      bool? valorRespuesta = respuestas['$i'];
      if (valorRespuesta == null) continue;
      
      String respuestaSeleccionada = valorRespuesta ? respuesta1 : respuesta2;
      
      items.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(pregunta, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                color: valorRespuesta ? PdfColors.red.shade(0.1) : PdfColors.grey.shade(0.1),
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(
                  color: valorRespuesta ? PdfColors.red : PdfColors.grey,
                  width: 0.5,
                ),
              ),
              child: pw.Text(
                "Respuesta: $respuestaSeleccionada",
                style: pw.TextStyle(
                  color: valorRespuesta ? PdfColors.red : PdfColors.black,
                  fontWeight: valorRespuesta ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
              ),
            ),
            pw.SizedBox(height: 12),
          ],
        ),
      );
    }
    
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
                pw.Text('Escala de Depresión Geriátrica de Yesavage', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
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
                _buildPdfInfoRow('Edad:', yesavage.edad.toString()),
              ],
            ),
          ),
          
          // Sección de información del examen
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
                pw.Text('Información del Examen', 
                  style: pw.TextStyle(
                    fontSize: 16, 
                    fontWeight: pw.FontWeight.bold, 
                    color: PdfColors.deepPurple
                  )
                ),
                pw.SizedBox(height: 8),
                _buildPdfInfoRow('Zona:', yesavage.zona),
                _buildPdfInfoRow('Distrito:', yesavage.distrito),
                _buildPdfInfoRow('Modalidad de Atención:', yesavage.modalidadAtencion),
                _buildPdfInfoRow('Unidad de Atención:', yesavage.unidadAtencion),
                _buildPdfInfoRow('Fecha de Aplicación:', _formatDate(yesavage.fechaAplicacion)),
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
                pw.Text('Respuestas del Examen Yesavage', 
                  style: pw.TextStyle(
                    fontSize: 16, 
                    fontWeight: pw.FontWeight.bold, 
                    color: PdfColors.deepPurple
                  )
                ),
                pw.SizedBox(height: 8),
                ...items,
                pw.SizedBox(height: 16),
                
                // Resultados totales
                pw.Container(
                  padding: pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: _getColorForScore(yesavage.puntos).shade(0.1),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: _getColorForScore(yesavage.puntos)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Puntaje Total: ${yesavage.puntos}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Interpretación: ${_getInterpretacion(yesavage.puntos)}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: _getColorForScore(yesavage.puntos),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text('Casa Grande - Escala de Yesavage'),
            pw.Text(' | '),
            pw.Text('Página ${context.pageNumber} de ${context.pagesCount}'),
          ],
        ),
      ),
    );
    
    // Mostrar vista previa e imprimir
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Escala_Yesavage_${paciente.cedula}',
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
        title: const Text('Escala de Yesavage'),
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
                final yesavageData = await yesavage;
                
                if (pacienteData != null && yesavageData != null) {
                  await _imprimirInforme(pacienteData, yesavageData);
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
              future: Future.wait([paciente, yesavage]),
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
                          _buildInfoRow('Fecha de Aplicación:', _formatDate(yesavage.fechaAplicacion)),
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
                              final yesavageData = await yesavage;
                              
                              if (pacienteData != null && yesavageData != null) {
                                await _imprimirInforme(pacienteData, yesavageData);
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
    
    if (puntaje <= 5) {
      interpretacion = 'Normal';
      color = Colors.green;
    } else if (puntaje <= 10) {
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

  List<Widget> _buildYesavageItems(Yesavage yesavage) {
    List<Widget> items = [];
    Map<String, bool> respuestas = yesavage.respuestas;

    for (int i = 0; i < preguntas.length; i++) {
      String pregunta = preguntas[i]['pregunta']!;
      String respuesta1 = preguntas[i]['respuesta1']!;
      String respuesta2 = preguntas[i]['respuesta2']!;
      
      bool? valorRespuesta = respuestas['$i'];
      if (valorRespuesta == null) continue;
      
      String respuestaSeleccionada = valorRespuesta ? respuesta1 : respuesta2;
      
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