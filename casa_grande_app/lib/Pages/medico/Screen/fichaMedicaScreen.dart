import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/FichaMedica.model.dart';
import 'package:casa_grande_app/Models/Paciente.model.dart';
import 'package:casa_grande_app/Services/FichaMedica.service.dart';
import 'package:casa_grande_app/Services/Paciente.service.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart' show Icons;
import 'package:printing/printing.dart';
class FichaMedicaDetalleScreen extends StatefulWidget {
  final String idPaciente;

  FichaMedicaDetalleScreen({required this.idPaciente});

  @override
  _FichaMedicaDetalleScreenState createState() =>
      _FichaMedicaDetalleScreenState();
}

class _FichaMedicaDetalleScreenState extends State<FichaMedicaDetalleScreen> {
  late Future<Paciente?> paciente;
  late Future<FichaMedica?> fichaMedica;

  @override
  void initState() {
    super.initState();
    paciente = PacienteService().obtenerPacientePorCedula(widget.idPaciente);
    fichaMedica = FichaMedicaService().getFichaMedicaByPacienteCedula(widget.idPaciente);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ficha Médica'),
        backgroundColor: Colors.teal[700],
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([paciente, fichaMedica]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.teal[700]));
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data![0] == null || snapshot.data![1] == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No se encontró información del paciente o su ficha médica',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          } else {
            Paciente paciente = snapshot.data![0] as Paciente;
            FichaMedica fichaMedica = snapshot.data![1] as FichaMedica;

            return Container(
              color: Colors.grey[50],
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado con información del paciente
                    Container(
                      width: double.infinity,
                      color: Colors.teal[700],
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 30,
                                child: Icon(Icons.person, size: 40, color: Colors.teal[700]),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${paciente.nombre} ${paciente.apellido}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'C.I.: ${paciente.cedula}',
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                    ElevatedButton(
  onPressed: () {
    _imprimirFichaMedica(paciente, fichaMedica);
  },
  child: Icon(Icons.print),
)
                                  ],
                                ),
                                
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Información personal del paciente
                    _buildSection(
                      title: 'Información Personal',
                      icon: Icons.person,
                      children: [
                        _buildInfoRow('Fecha de Nacimiento:', _formatDate(paciente.fechaNacimiento)),
                        _buildInfoRow('Estado Civil:', paciente.estadoCivil),
                        _buildInfoRow('Nivel de Instrucción:', paciente.nivelInstruccion),
                        _buildInfoRow('Profesión/Ocupación:', paciente.profesionOcupacion),
                        _buildInfoRow('Fecha de Ingreso:', _formatDate(paciente.fechaIngreso)),
                      ],
                    ),

                    // Información de contacto
                    _buildSection(
                      title: 'Información de Contacto',
                      icon: Icons.contact_phone,
                      children: [
                        _buildInfoRow('Teléfono:', paciente.telefono),
                        _buildInfoRow('Dirección:', paciente.direccion),
                      ],
                    ),

                    // Condición física y psicológica
                    _buildSection(
                      title: 'Estado de Salud',
                      icon: Icons.medical_services,
                      children: [
                        _buildInfoRow('Condición Física:', fichaMedica.condicionFisica ?? 'No especificado', isMultiline: true),
                        _buildInfoRow('Condición Psicológica:', fichaMedica.condicionPsicologica ?? 'No especificado', isMultiline: true),
                        _buildInfoRow('Estado de Salud General:', fichaMedica.estadoSalud ?? 'No especificado', isMultiline: true),
                      ],
                    ),

                    // Medicamentos e intolerancias
                    _buildSection(
                      title: 'Medicamentos',
                      icon: Icons.medication,
                      children: [
                        _buildInfoRow('Medicamentos Actuales:', fichaMedica.medicamentos ?? 'No especificado', isMultiline: true),
                        _buildInfoRow('Intolerancias a Medicamentos:', fichaMedica.intoleranciaMedicamentos ?? 'No especificado', isMultiline: true),
                      ],
                    ),

                    // Información familiar
                    _buildSection(
                      title: 'Información Familiar',
                      icon: Icons.family_restroom,
                      children: [
                        _buildInfoRow('Vive Con:', fichaMedica.viveCon ?? 'No especificado'),
                        _buildInfoRow('Relaciones Familiares:', fichaMedica.relacionesFamiliares ?? 'No especificado', isMultiline: true),
                      ],
                    ),

                    // Información adicional
                    _buildSection(
                      title: 'Información Adicional',
                      icon: Icons.info,
                      children: [
                        _buildInfoRow('Referido Por:', fichaMedica.referidoPor ?? 'No especificado'),
                        _buildInfoRow('Observaciones:', fichaMedica.observaciones ?? 'No especificado', isMultiline: true),
                      ],
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.teal[700]),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.teal[50]),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: isMultiline
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  width: double.infinity,
                  child: Text(
                    value.isEmpty ? 'No especificado' : value,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(height: 8),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    value.isEmpty ? 'No especificado' : value,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
    );
  }
  Future<void> _imprimirFichaMedica(Paciente paciente, FichaMedica fichaMedica) async {
  final doc = pw.Document();

  // Estilos para el PDF
  final headerStyle = pw.TextStyle(
    fontSize: 18,
    fontWeight: pw.FontWeight.bold,
    color: PdfColor.fromInt(Colors.teal[700]!.value),
  );
  
  final titleStyle = pw.TextStyle(
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
  );
  
  final normalStyle = pw.TextStyle(
    fontSize: 14,
  );

  doc.addPage(
    pw.MultiPage(
      margin: pw.EdgeInsets.all(20),
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          // Encabezado
          pw.Container(
            width: double.infinity,
            color: PdfColor.fromInt(Colors.teal[700]!.value),
            padding: pw.EdgeInsets.all(16),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Icon(pw.IconData(Icons.person.codePoint)),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${paciente.nombre} ${paciente.apellido}',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'C.I.: ${paciente.cedula}',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Información personal del paciente
          _buildPdfSection(
            title: 'Información Personal',
            icon: Icons.person,
            content: [
              _buildPdfInfoRow('Fecha de Nacimiento:', _formatDate(paciente.fechaNacimiento), titleStyle, normalStyle),
              _buildPdfInfoRow('Estado Civil:', paciente.estadoCivil, titleStyle, normalStyle),
              _buildPdfInfoRow('Nivel de Instrucción:', paciente.nivelInstruccion, titleStyle, normalStyle),
              _buildPdfInfoRow('Profesión/Ocupación:', paciente.profesionOcupacion, titleStyle, normalStyle),
              _buildPdfInfoRow('Fecha de Ingreso:', _formatDate(paciente.fechaIngreso), titleStyle, normalStyle),
            ],
          ),
          
          pw.SizedBox(height: 10),
          
          // Información de contacto
          _buildPdfSection(
            title: 'Información de Contacto',
            icon: Icons.contact_phone,
            content: [
              _buildPdfInfoRow('Teléfono:', paciente.telefono, titleStyle, normalStyle),
              _buildPdfInfoRow('Dirección:', paciente.direccion, titleStyle, normalStyle),
            ],
          ),
          
          pw.SizedBox(height: 10),
          
          // Estado de salud
          _buildPdfSection(
            title: 'Estado de Salud',
            icon: Icons.medical_services,
            content: [
              _buildPdfInfoRow('Condición Física:', fichaMedica.condicionFisica ?? 'No especificado', titleStyle, normalStyle, isMultiline: true),
              _buildPdfInfoRow('Condición Psicológica:', fichaMedica.condicionPsicologica ?? 'No especificado', titleStyle, normalStyle, isMultiline: true),
              _buildPdfInfoRow('Estado de Salud General:', fichaMedica.estadoSalud ?? 'No especificado', titleStyle, normalStyle, isMultiline: true),
            ],
          ),
          
          pw.SizedBox(height: 10),
          
          // Medicamentos
          _buildPdfSection(
            title: 'Medicamentos',
            icon: Icons.medication,
            content: [
              _buildPdfInfoRow('Medicamentos Actuales:', fichaMedica.medicamentos ?? 'No especificado', titleStyle, normalStyle, isMultiline: true),
              _buildPdfInfoRow('Intolerancias a Medicamentos:', fichaMedica.intoleranciaMedicamentos ?? 'No especificado', titleStyle, normalStyle, isMultiline: true),
            ],
          ),
          
          pw.SizedBox(height: 10),
          
          // Información familiar
          _buildPdfSection(
            title: 'Información Familiar',
            icon: Icons.family_restroom,
            content: [
              _buildPdfInfoRow('Vive Con:', fichaMedica.viveCon ?? 'No especificado', titleStyle, normalStyle),
              _buildPdfInfoRow('Relaciones Familiares:', fichaMedica.relacionesFamiliares ?? 'No especificado', titleStyle, normalStyle, isMultiline: true),
            ],
          ),
          
          pw.SizedBox(height: 10),
          
          // Información adicional
          _buildPdfSection(
            title: 'Información Adicional',
            icon: Icons.info,
            content: [
              _buildPdfInfoRow('Referido Por:', fichaMedica.referidoPor ?? 'No especificado', titleStyle, normalStyle),
              _buildPdfInfoRow('Observaciones:', fichaMedica.observaciones ?? 'No especificado', titleStyle, normalStyle, isMultiline: true),
            ],
          ),
          
          pw.SizedBox(height: 20),
        ];
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => doc.save(),
  );
}


// Función auxiliar para construir secciones en PDF
pw.Widget _buildPdfSection({
  required String title,
  required IconData icon,
  required List<pw.Widget> content,
}) {
  return pw.Container(
    margin: pw.EdgeInsets.only(bottom: 10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColor.fromInt(Colors.grey[300]!.value)),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(Colors.teal[50]!.value),
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8)),
          ),
          child: pw.Row(
            children: [
              pw.Icon(pw.IconData(icon.codePoint)),
              pw.SizedBox(width: 8),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(Colors.teal[700]!.value),
                ),
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: content,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildPdfInfoRow(
  String label, 
  String value, 
  pw.TextStyle titleStyle, 
  pw.TextStyle normalStyle, {
  bool isMultiline = false,
}) {
  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: 8),
    child: isMultiline
        ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label, style: titleStyle),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(Colors.grey[50]!.value),
                  border: pw.Border.all(color: PdfColor.fromInt(Colors.grey[300]!.value)),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                width: double.infinity,
                child: pw.Text(
                  value.isEmpty ? 'No especificado' : value,
                  style: normalStyle,
                ),
              ),
            ],
          )
        : pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Text(label, style: titleStyle),
              ),
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  value.isEmpty ? 'No especificado' : value,
                  style: normalStyle,
                ),
              ),
            ],
          ),
  );
}
}