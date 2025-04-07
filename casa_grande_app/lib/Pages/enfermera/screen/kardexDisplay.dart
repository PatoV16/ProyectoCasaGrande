import 'package:casa_grande_app/Models/Kardex.model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class KardexGerontologicoDisplay extends StatelessWidget {
  final String idPaciente;
  final KardexGerontologico? kardex;
  final String nombrePaciente;

  KardexGerontologicoDisplay({
    Key? key, 
    required this.idPaciente,
    required this.kardex,
    required this.nombrePaciente,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kardex == null) {
      return const Center(child: Text('No se encontró kardex para este paciente'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildKardexCard(kardex!, nombrePaciente, context),
      ),
    );
  }

  Widget _buildKardexCard(KardexGerontologico kardex, String nombrePaciente, BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              width: double.infinity,
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KARDEX GERONTOLÓGICO',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fecha de creación: ${dateFormat.format(kardex.fechaCreacion)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (kardex.fechaActualizacion != null)
                    Text(
                      'Última actualización: ${dateFormat.format(kardex.fechaActualizacion!)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INFORMACIÓN DEL PACIENTE',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildInfoRow(context, 'Nombre:', nombrePaciente),
                  _buildInfoRow(context, 'Cédula/ID:', kardex.idPaciente),
                  _buildInfoRow(context, 'Edad:', '${kardex.edad} años'),
                  _buildInfoRow(context, 'N° Historia Clínica:', kardex.numeroHistoriaClinica),
                  _buildInfoRow(context, 'N° Archivo:', kardex.numeroArchivo),
                  
                  const SizedBox(height: 16),
                  Text(
                    'INFORMACIÓN DE ALERGIAS',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context, 
                    'Alergia a medicamentos:', 
                    kardex.tieneAlergiaMedicamentos ? 'Sí' : 'No'
                  ),
                  if (kardex.tieneAlergiaMedicamentos && kardex.descripcionAlergia != null)
                    _buildInfoRow(context, 'Descripción:', kardex.descripcionAlergia!),
                  
                  const SizedBox(height: 16),
                  Text(
                    'MEDICAMENTOS',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                ],
              ),
            ),
            if (kardex.medicamentos.isEmpty)
              const Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Text('No hay medicamentos registrados'),
              )
            else
              ...kardex.medicamentos.map((medicamento) => _buildMedicamentoSection(context, medicamento)).toList(),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  final pdfBytes = await _generatePdf(kardex, nombrePaciente);
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdfBytes,
                  );
                },
                child: const Text('Imprimir Kardex'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicamentoSection(BuildContext context, Medicamento medicamento) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medicamento.nombre,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _buildInfoRow(context, 'Fecha:', dateFormat.format(medicamento.fecha)),
          _buildInfoRow(context, 'Dosis:', medicamento.dosis),
          _buildInfoRow(context, 'Vía de administración:', medicamento.via),
          _buildInfoRow(context, 'Frecuencia:', medicamento.frecuencia),
          
          const SizedBox(height: 8),
          Text(
            'Administraciones:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          
          if (medicamento.administraciones.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4.0, left: 16.0),
              child: Text('No hay administraciones registradas'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medicamento.administraciones.length,
              itemBuilder: (context, index) {
                final administracion = medicamento.administraciones[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 16.0),
                  child: Text('Hora: ${administracion.hora} - Responsable: ${administracion.responsable}'),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<Uint8List> _generatePdf(KardexGerontologico kardex, String nombrePaciente) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'KARDEX GERONTOLÓGICO',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Fecha de creación: ${dateFormat.format(kardex.fechaCreacion)}'),
              if (kardex.fechaActualizacion != null)
                pw.Text('Última actualización: ${dateFormat.format(kardex.fechaActualizacion!)}'),
              
              pw.SizedBox(height: 16),
              pw.Text(
                'INFORMACIÓN DEL PACIENTE',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
              ),
              pw.Divider(),
              _buildPdfInfoRow('Nombre:', nombrePaciente),
              _buildPdfInfoRow('Cédula/ID:', kardex.idPaciente),
              _buildPdfInfoRow('Edad:', '${kardex.edad} años'),
              _buildPdfInfoRow('N° Historia Clínica:', kardex.numeroHistoriaClinica),
              _buildPdfInfoRow('N° Archivo:', kardex.numeroArchivo),
              
              pw.SizedBox(height: 16),
              pw.Text(
                'INFORMACIÓN DE ALERGIAS',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
              ),
              pw.Divider(),
              _buildPdfInfoRow('Alergia a medicamentos:', kardex.tieneAlergiaMedicamentos ? 'Sí' : 'No'),
              if (kardex.tieneAlergiaMedicamentos && kardex.descripcionAlergia != null)
                _buildPdfInfoRow('Descripción:', kardex.descripcionAlergia!),
              
              pw.SizedBox(height: 16),
              pw.Text(
                'MEDICAMENTOS',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
              ),
              pw.Divider(),
              
              if (kardex.medicamentos.isEmpty)
                pw.Text('No hay medicamentos registrados')
              else
                ...kardex.medicamentos.map((medicamento) => _buildPdfMedicamentoSection(medicamento, dateFormat)),
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
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfMedicamentoSection(Medicamento medicamento, DateFormat dateFormat) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            medicamento.nombre,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          _buildPdfInfoRow('Fecha:', dateFormat.format(medicamento.fecha)),
          _buildPdfInfoRow('Dosis:', medicamento.dosis),
          _buildPdfInfoRow('Vía de administración:', medicamento.via),
          _buildPdfInfoRow('Frecuencia:', medicamento.frecuencia),
          
          pw.SizedBox(height: 8),
          pw.Text(
            'Administraciones:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          
          pw.SizedBox(height: 4),
          if (medicamento.administraciones.isEmpty)
            pw.Padding(
              padding: pw.EdgeInsets.only(left: 16),
              child: pw.Text('No hay administraciones registradas'),
            )
          else
            ...medicamento.administraciones.map(
              (administracion) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 16, top: 2),
                child: pw.Text(
                  'Hora: ${administracion.hora} - Responsable: ${administracion.responsable}'
                ),
              ),
            ),
        ],
      ),
    );
  }
}