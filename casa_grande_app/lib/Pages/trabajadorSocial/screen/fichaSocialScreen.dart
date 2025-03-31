import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../Models/FichaSocial.model.dart';
import '../../../Models/Paciente.model.dart';
import '../../../Services/FichaSocial.service.dart';
import '../../../Services/Paciente.service.dart';

class FichaSocialScreen extends StatefulWidget {
  final String idPaciente;

  const FichaSocialScreen({Key? key, required this.idPaciente}) : super(key: key);

  @override
  _FichaSocialScreenState createState() => _FichaSocialScreenState();
}

class _FichaSocialScreenState extends State<FichaSocialScreen> {
  late Future<Paciente?> paciente;
  late Future<FichaSocial?> fichaSocial;
  bool _checkingData = true;

  @override
  void initState() {
    super.initState();
    paciente = PacienteService().obtenerPacientePorCedula(widget.idPaciente);
    fichaSocial = FichaSocialService().getFichaSocialByPaciente(widget.idPaciente);
    _verificarDatosDisponibles();
  }

  Future<void> _verificarDatosDisponibles() async {
    try {
      final resultados = await Future.wait([paciente, fichaSocial]);

      if (resultados[0] == null || resultados[1] == null) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(context, '/FormFichaSocial', arguments: {'idPaciente': widget.idPaciente});
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

  Future<void> _imprimirFichaSocial(Paciente paciente, FichaSocial ficha) async {
    final pdf = pw.Document();
    
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('FICHA SOCIAL DEL PACIENTE', 
                  style: pw.TextStyle(font: fontBold, fontSize: 18)),
                pw.SizedBox(height: 5),
                pw.Divider(thickness: 1),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Center(
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: pw.TextStyle(font: font, fontSize: 10),
            ),
          );
        },
        build: (pw.Context context) => [
          _buildPdfSection(
            title: 'Información del Paciente',
            items: [
              {'label': 'Nombre:', 'value': '${paciente.nombre} ${paciente.apellido}'},
              {'label': 'C.I.:', 'value': paciente.cedula},
              if (paciente.fechaNacimiento != null)
                {'label': 'Fecha de Nacimiento:', 'value': _formatearFecha(paciente.fechaNacimiento!)},
            ],
            font: font,
            fontBold: fontBold,
          ),
          pw.SizedBox(height: 15),
          _buildPdfSection(
            title: 'Red Social de Apoyo',
            items: [
              {'label': '¿Ocupa tiempo libre?', 'value': ficha.ocupaTiempoLibre == true ? 'Sí' : 'No'},
              {'label': 'Actividades de tiempo libre:', 'value': ficha.actividadesTiempoLibre ?? 'No especificado'},
              {'label': '¿Pertenece a una asociación?', 'value': ficha.perteneceAsociacion == true ? 'Sí' : 'No'},
              {'label': 'Nombre de la organización:', 'value': ficha.nombreOrganizacion ?? 'No especificado'},
              {'label': 'Frecuencia con que acude:', 'value': ficha.frecuenciaAcudeAsociacion ?? 'No especificado'},
              {'label': 'Actividad en la asociación:', 'value': ficha.actividadAsociacion ?? 'No especificado'},
            ],
            font: font,
            fontBold: fontBold,
          ),
          pw.SizedBox(height: 15),
          _buildPdfSection(
            title: 'Situación Económica',
            items: [
              {'label': '¿Recibe pensión?', 'value': ficha.recibePension == true ? 'Sí' : 'No'},
              {'label': 'Tipo de pensión:', 'value': ficha.tipoPension ?? 'No especificado'},
              {'label': '¿Tiene otros ingresos?', 'value': ficha.tieneOtrosIngresos == true ? 'Sí' : 'No'},
              {'label': 'Monto de otros ingresos:', 'value': ficha.montoOtrosIngresos?.toString() ?? 'No especificado'},
              {'label': 'Fuente de ingresos:', 'value': ficha.fuenteIngresos ?? 'No especificado'},
              {'label': '¿Quién cobra los ingresos?', 'value': ficha.quienCobraIngresos ?? 'No especificado'},
              {'label': '¿A dónde van los recursos?', 'value': ficha.destinoRecursos ?? 'No especificado'},
            ],
            font: font,
            fontBold: fontBold,
          ),
          pw.SizedBox(height: 15),
          _buildPdfSection(
            title: 'Vivienda',
            items: [
              {'label': 'Tipo de vivienda:', 'value': ficha.tipoVivienda ?? 'No especificado'},
              {'label': 'Acceso a la vivienda:', 'value': ficha.accesoVivienda ?? 'No especificado'},
            ],
            font: font,
            fontBold: fontBold,
          ),
          pw.SizedBox(height: 15),
          _buildPdfSection(
            title: 'Nutrición',
            items: [
              {'label': '¿Se alimenta bien?', 'value': ficha.seAlimentaBien == true ? 'Sí' : 'No'},
              {'label': 'Número de comidas diarias:', 'value': ficha.numeroComidasDiarias?.toString() ?? 'No especificado'},
              {'label': 'Especificar comidas:', 'value': ficha.especificarComidas ?? 'No especificado'},
            ],
            font: font,
            fontBold: fontBold,
          ),
          pw.SizedBox(height: 15),
          _buildPdfSection(
            title: 'Salud',
            items: [
              {'label': 'Estado de salud:', 'value': ficha.estadoSalud ?? 'No especificado'},
              {'label': '¿Enfermedad catastrófica?', 'value': ficha.enfermedadCatastrofica == true ? 'Sí' : 'No'},
              {'label': 'Especificar enfermedad:', 'value': ficha.especificarEnfermedad ?? 'No especificado'},
              {'label': '¿Discapacidad?', 'value': ficha.discapacidad == true ? 'Sí' : 'No'},
              {'label': '¿Toma medicación constante?', 'value': ficha.tomaMedicamentoConstante == true ? 'Sí' : 'No'},
              {'label': 'Especificar medicamento:', 'value': ficha.especificarMedicamento ?? 'No especificado'},
              {'label': '¿Utiliza ayuda técnica?', 'value': ficha.utilizaAyudaTecnica == true ? 'Sí' : 'No'},
              {'label': 'Especificar ayuda técnica:', 'value': ficha.especificarAyudaTecnica ?? 'No especificado'},
            ],
            font: font,
            fontBold: fontBold,
          ),
          pw.SizedBox(height: 15),
          _buildPdfSection(
            title: 'Servicios que desea ingresar',
            items: [
              {'label': '¿Desea servicio residencial?', 'value': ficha.deseaServicioResidencial == true ? 'Sí' : 'No'},
              {'label': '¿Desea servicio diurno?', 'value': ficha.deseaServicioDiurno == true ? 'Sí' : 'No'},
              {'label': '¿Desea espacios de socialización?', 'value': ficha.deseaEspaciosSocializacion == true ? 'Sí' : 'No'},
              {'label': '¿Desea atención domiciliaria?', 'value': ficha.deseaAtencionDomiciliaria == true ? 'Sí' : 'No'},
            ],
            font: font,
            fontBold: fontBold,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Ficha_Social_${paciente.cedula}.pdf',
    );
  }

  pw.Widget _buildPdfSection({
    required String title,
    required List<Map<String, String>> items,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.deepPurple50,
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(4),
                topRight: pw.Radius.circular(4),
              ),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColors.deepPurple),
            ),
          ),
          pw.Divider(color: PdfColors.deepPurple, thickness: 0.5),
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              children: items.map((item) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      item['label']!,
                      style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.grey800),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        borderRadius: pw.BorderRadius.circular(2),
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Text(
                        item['value']!.isEmpty ? 'No especificado' : item['value']!,
                        style: pw.TextStyle(font: font, fontSize: 11),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                  ],
                );
              }).toList(),
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
        title: const Text('Ficha Social del Paciente'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          // Botón de imprimir en la barra de acciones
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final pacienteData = await paciente;
              final fichaSocialData = await fichaSocial;
              if (pacienteData != null && fichaSocialData != null) {
                await _imprimirFichaSocial(pacienteData, fichaSocialData);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No hay datos disponibles para imprimir'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _checkingData
          ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : FutureBuilder<List<dynamic>>(
              future: Future.wait([paciente, fichaSocial]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                } else if (snapshot.hasError) {
                  return _buildError('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data![0] == null || snapshot.data![1] == null) {
                  return _buildNoData();
                }

                Paciente paciente = snapshot.data![0] as Paciente;
                FichaSocial ficha = snapshot.data![1] as FichaSocial;

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
                          if (paciente.fechaNacimiento != null)
                            _buildInfoRow('Fecha de Nacimiento:', _formatearFecha(paciente.fechaNacimiento!)),
                        ],
                      ),
                      _buildSection(
                        title: 'Red Social de Apoyo',
                        icon: Icons.people,
                        children: [
                          _buildInfoRow('¿Ocupa tiempo libre?', ficha.ocupaTiempoLibre == true ? 'Sí' : 'No'),
                          _buildInfoRow('Actividades de tiempo libre:', ficha.actividadesTiempoLibre ?? 'No especificado'),
                          _buildInfoRow('¿Pertenece a una asociación?', ficha.perteneceAsociacion == true ? 'Sí' : 'No'),
                          _buildInfoRow('Nombre de la organización:', ficha.nombreOrganizacion ?? 'No especificado'),
                          _buildInfoRow('Frecuencia con que acude:', ficha.frecuenciaAcudeAsociacion ?? 'No especificado'),
                          _buildInfoRow('Actividad en la asociación:', ficha.actividadAsociacion ?? 'No especificado'),
                        ],
                      ),
                      _buildSection(
                        title: 'Situación Económica',
                        icon: Icons.monetization_on,
                        children: [
                          _buildInfoRow('¿Recibe pensión?', ficha.recibePension == true ? 'Sí' : 'No'),
                          _buildInfoRow('Tipo de pensión:', ficha.tipoPension ?? 'No especificado'),
                          _buildInfoRow('¿Tiene otros ingresos?', ficha.tieneOtrosIngresos == true ? 'Sí' : 'No'),
                          _buildInfoRow('Monto de otros ingresos:', ficha.montoOtrosIngresos?.toString() ?? 'No especificado'),
                          _buildInfoRow('Fuente de ingresos:', ficha.fuenteIngresos ?? 'No especificado'),
                          _buildInfoRow('¿Quién cobra los ingresos?', ficha.quienCobraIngresos ?? 'No especificado'),
                          _buildInfoRow('¿A dónde van los recursos?', ficha.destinoRecursos ?? 'No especificado'),
                        ],
                      ),
                      _buildSection(
                        title: 'Vivienda',
                        icon: Icons.home,
                        children: [
                          _buildInfoRow('Tipo de vivienda:', ficha.tipoVivienda ?? 'No especificado'),
                          _buildInfoRow('Acceso a la vivienda:', ficha.accesoVivienda ?? 'No especificado'),
                        ],
                      ),
                      _buildSection(
                        title: 'Nutrición',
                        icon: Icons.fastfood,
                        children: [
                          _buildInfoRow('¿Se alimenta bien?', ficha.seAlimentaBien == true ? 'Sí' : 'No'),
                          _buildInfoRow('Número de comidas diarias:', ficha.numeroComidasDiarias?.toString() ?? 'No especificado'),
                          _buildInfoRow('Especificar comidas:', ficha.especificarComidas ?? 'No especificado'),
                        ],
                      ),
                      _buildSection(
                        title: 'Salud',
                        icon: Icons.local_hospital,
                        children: [
                          _buildInfoRow('Estado de salud:', ficha.estadoSalud ?? 'No especificado'),
                          _buildInfoRow('¿Enfermedad catastrófica?', ficha.enfermedadCatastrofica == true ? 'Sí' : 'No'),
                          _buildInfoRow('Especificar enfermedad:', ficha.especificarEnfermedad ?? 'No especificado'),
                          _buildInfoRow('¿Discapacidad?', ficha.discapacidad == true ? 'Sí' : 'No'),
                          _buildInfoRow('¿Toma medicación constante?', ficha.tomaMedicamentoConstante == true ? 'Sí' : 'No'),
                          _buildInfoRow('Especificar medicamento:', ficha.especificarMedicamento ?? 'No especificado'),
                          _buildInfoRow('¿Utiliza ayuda técnica?', ficha.utilizaAyudaTecnica == true ? 'Sí' : 'No'),
                          _buildInfoRow('Especificar ayuda técnica:', ficha.especificarAyudaTecnica ?? 'No especificado'),
                        ],
                      ),
                      _buildSection(
                        title: 'Servicios que desea ingresar',
                        icon: Icons.medical_services,
                        children: [
                          _buildInfoRow('¿Desea servicio residencial?', ficha.deseaServicioResidencial == true ? 'Sí' : 'No'),
                          _buildInfoRow('¿Desea servicio diurno?', ficha.deseaServicioDiurno == true ? 'Sí' : 'No'),
                          _buildInfoRow('¿Desea espacios de socialización?', ficha.deseaEspaciosSocializacion == true ? 'Sí' : 'No'),
                          _buildInfoRow('¿Desea atención domiciliaria?', ficha.deseaAtencionDomiciliaria == true ? 'Sí' : 'No'),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Botón flotante para imprimir
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.print),
                          label: const Text('Imprimir Ficha Social'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () async {
                            await _imprimirFichaSocial(paciente, ficha);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
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
          Text('No hay ficha social disponible para este paciente.'),
          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/FormFichaSocial', arguments: {'idPaciente': widget.idPaciente});
            },
            child: Text('Registrar nueva ficha social'),
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