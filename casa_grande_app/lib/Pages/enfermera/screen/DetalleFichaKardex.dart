import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Kardex.model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class DetalleFichaKardex extends StatelessWidget {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat timeFormat = DateFormat('HH:mm');

  DetalleFichaKardex({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final KardexGerontologico kardex = ModalRoute.of(context)!.settings.arguments as KardexGerontologico;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Ficha de Medicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final pdfBytes = await _generatePdf(kardex);
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => pdfBytes,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(context, kardex),
              const SizedBox(height: 16),
              _buildAlergiaCard(context, kardex),
              const SizedBox(height: 16),
              _buildMedicamentosSection(context, kardex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, KardexGerontologico kardex) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'INFORMACIÓN BÁSICA',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('N° Historia Clínica:', kardex.numeroHistoriaClinica, context),
            _buildInfoRow('N° Archivo:', kardex.numeroArchivo, context),
            _buildInfoRow('Edad:', kardex.edad.toString(), context),
            _buildInfoRow('Fecha de creación:', dateFormat.format(kardex.fechaCreacion), context),
            if (kardex.fechaActualizacion != null)
              _buildInfoRow('Última actualización:', dateFormat.format(kardex.fechaActualizacion!), context),
          ],
        ),
      ),
    );
  }

  Widget _buildAlergiaCard(BuildContext context, KardexGerontologico kardex) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'INFORMACIÓN DE ALERGIAS',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              '¿Alergia a medicamentos?:',
              kardex.tieneAlergiaMedicamentos ? 'SÍ' : 'NO',
              context,
              kardex.tieneAlergiaMedicamentos ? Colors.red : Colors.green,
            ),
            if (kardex.tieneAlergiaMedicamentos && kardex.descripcionAlergia != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Descripción de la alergia:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(kardex.descripcionAlergia!),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicamentosSection(BuildContext context, KardexGerontologico kardex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'MEDICAMENTOS',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
        const SizedBox(height: 16),
        kardex.medicamentos.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No hay medicamentos registrados',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: kardex.medicamentos.length,
                itemBuilder: (context, index) {
                  final medicamento = kardex.medicamentos[index];
                  return _buildMedicamentoCard(context, medicamento, index);
                },
              ),
      ],
    );
  }

  Widget _buildMedicamentoCard(BuildContext context, Medicamento medicamento, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      child: ExpansionTile(
        title: Text(
          medicamento.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Dosis: ${medicamento.dosis} | ${dateFormat.format(medicamento.fecha)}',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Vía de administración:', medicamento.via, context),
                _buildInfoRow('Frecuencia:', medicamento.frecuencia, context),
                const SizedBox(height: 16),
                Text(
                  'REGISTRO DE ADMINISTRACIONES:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                medicamento.administraciones.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('No hay registros de administración'),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  topRight: Radius.circular(7),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'HORA',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'RESPONSABLE',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: medicamento.administraciones.length,
                              itemBuilder: (context, idx) {
                                final administracion = medicamento.administraciones[idx];
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    color: idx % 2 == 0 ? Colors.white : Colors.grey.shade50,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          administracion.hora,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          administracion.responsable,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generatePdf(KardexGerontologico kardex) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'FICHA DE MEDICACIÓN',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Información básica
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Center(
                      child: pw.Text(
                        'INFORMACIÓN BÁSICA',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildPdfInfoRow('N° Historia Clínica:', kardex.numeroHistoriaClinica),
                    _buildPdfInfoRow('N° Archivo:', kardex.numeroArchivo),
                    _buildPdfInfoRow('Edad:', kardex.edad.toString()),
                    _buildPdfInfoRow('Fecha de creación:', dateFormat.format(kardex.fechaCreacion)),
                    if (kardex.fechaActualizacion != null)
                      _buildPdfInfoRow('Última actualización:', dateFormat.format(kardex.fechaActualizacion!)),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 15),
              
              // Información de alergias
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Center(
                      child: pw.Text(
                        'INFORMACIÓN DE ALERGIAS',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildPdfInfoRow('¿Alergia a medicamentos?:', kardex.tieneAlergiaMedicamentos ? 'SÍ' : 'NO'),
                    if (kardex.tieneAlergiaMedicamentos && kardex.descripcionAlergia != null) pw.SizedBox(height: 5),
                    if (kardex.tieneAlergiaMedicamentos && kardex.descripcionAlergia != null)
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Descripción de la alergia:',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(height: 3),
                            pw.Text(kardex.descripcionAlergia!),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 15),
              
              // Medicamentos
              pw.Center(
                child: pw.Text(
                  'MEDICAMENTOS',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              
              kardex.medicamentos.isEmpty
                  ? pw.Center(
                      child: pw.Text('No hay medicamentos registrados'),
                    )
                  : pw.Column(
                      children: kardex.medicamentos.map((medicamento) {
                        return pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 10),
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                medicamento.nombre,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(height: 5),
                              _buildPdfInfoRow('Dosis:', medicamento.dosis),
                              _buildPdfInfoRow('Vía de administración:', medicamento.via),
                              _buildPdfInfoRow('Frecuencia:', medicamento.frecuencia),
                              _buildPdfInfoRow('Fecha:', dateFormat.format(medicamento.fecha)),
                              
                              pw.SizedBox(height: 8),
                              pw.Text(
                                'REGISTRO DE ADMINISTRACIONES:',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(height: 5),
                              
                              medicamento.administraciones.isEmpty
                                  ? pw.Text('No hay registros de administración')
                                  : pw.Table(
                                      border: pw.TableBorder.all(),
                                      children: [
                                        pw.TableRow(
                                          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                                          children: [
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.all(5),
                                              child: pw.Text(
                                                'HORA',
                                                textAlign: pw.TextAlign.center,
                                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                                              ),
                                            ),
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.all(5),
                                              child: pw.Text(
                                                'RESPONSABLE',
                                                textAlign: pw.TextAlign.center,
                                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        ...medicamento.administraciones.map(
                                          (admin) => pw.TableRow(
                                            children: [
                                              pw.Padding(
                                                padding: const pw.EdgeInsets.all(5),
                                                child: pw.Text(
                                                  admin.hora,
                                                  textAlign: pw.TextAlign.center,
                                                ),
                                              ),
                                              pw.Padding(
                                                padding: const pw.EdgeInsets.all(5),
                                                child: pw.Text(
                                                  admin.responsable,
                                                  textAlign: pw.TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 4,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            flex: 5,
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }
}