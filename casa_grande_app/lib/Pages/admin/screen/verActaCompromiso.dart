import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/ActaCompromiso.model.dart';
import 'package:casa_grande_app/Services/ActaCompromiso.service.dart';
import 'package:casa_grande_app/Services/Paciente.service.dart';
import 'package:intl/intl.dart';
import '../../../Models/Paciente.model.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
class ActaCompromisoDisplay extends StatelessWidget {
  final ActaCompromisoService _actaService = ActaCompromisoService();
  final PacienteService _pacienteService = PacienteService();
  final String idPaciente;

  ActaCompromisoDisplay({Key? key, required this.idPaciente}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ActaCompromiso?>(
      future: _actaService.getActaPorPaciente(idPaciente),
      builder: (context, actaSnapshot) {
        if (actaSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (actaSnapshot.hasError || !actaSnapshot.hasData || actaSnapshot.data == null) {
          return const Center(child: Text('No se encontró acta para este paciente'));
        }

        final ActaCompromiso acta = actaSnapshot.data!;

        return FutureBuilder<Paciente?>(
          future: _pacienteService.obtenerPacientePorCedula(idPaciente),
          builder: (context, pacienteSnapshot) {
            if (pacienteSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (pacienteSnapshot.hasError || !pacienteSnapshot.hasData || pacienteSnapshot.data == null) {
              return const Center(child: Text('No se encontró el paciente'));
            }

            final String nombrePaciente = pacienteSnapshot.data!.nombre+' '+ pacienteSnapshot.data!.apellido;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildActaCard(acta, nombrePaciente, context),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActaCard(ActaCompromiso acta, String nombrePaciente, BuildContext context) {
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
                    'INSTRUCCIONES:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cuando ingresa la persona adulta mayor al Centro Gerontológico Diurno suscribe una carta de compromiso, en la cual se compromete a respetar los reglamentos y códigos de convivencia existentes, aceptar el apoyo e intervención profesional que requiera durante su permanencia en el centro o servicio, de acuerdo a los derechos establecidos en la Constitución de Ecuador y en la Norma Técnica.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FICHA N° 7 CARTA DE COMPROMISO Y ACEPTACIÓN DEL USUARIO/A /RESPONSABLE O REFERENTE',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Yo, **$nombrePaciente** con C.I. ${acta.idPaciente} ingreso voluntariamente al Centro o Servicio para personas adultas mayores, a partir de la presente fecha:'),
                  const SizedBox(height: 8),
                  Text('${dateFormat.format(acta.fechaCreacion)}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Además manifiesto, que he sido informado/a de los reglamentos y códigos de convivencia existentes en el Centro Gerontológico, comprometiéndome a través de la presente a cumplir con las responsabilidades y deberes, así como a aceptar las acciones del Plan de Atención Integral Individual que el equipo técnico programe, y colaborar para que éste se cumpla. Además me comprometo a mantener las instalaciones, muebles y equipos en buen estado, dando el trato adecuado para su conservación.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOMBRE PERSONA ADULTA MAYOR',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text('$nombrePaciente', style: Theme.of(context).textTheme.labelSmall),
                          const SizedBox(height: 8),
                          Text(
                            'FAMILIAR O REFERENTE',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text('${acta.nombreCompleto}', style: Theme.of(context).textTheme.labelSmall),
                          Text('C.I: ${acta.cedulaIdentidad}', style: Theme.of(context).textTheme.labelSmall),
                          Text('TELÉFONO: ${acta.telefono}', style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  final pdfBytes = await _generatePdf(acta, nombrePaciente, context);
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdfBytes,
                  );
                },
                child: const Text('Imprimir Acta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
Future<Uint8List> _generatePdf(ActaCompromiso acta, String nombrePaciente, BuildContext context) async {
  final pdf = pw.Document();

  final dateFormat = DateFormat('dd/MM/yyyy');

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'INSTRUCCIONES:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Cuando ingresa la persona adulta mayor al Centro Gerontológico Diurno suscribe una carta de compromiso, en la cual se compromete a respetar los reglamentos y códigos de convivencia existentes, aceptar el apoyo e intervención profesional que requiera durante su permanencia en el centro o servicio, de acuerdo a los derechos establecidos en la Constitución de Ecuador y en la Norma Técnica.',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'FICHA N° 7 CARTA DE COMPROMISO Y ACEPTACIÓN DEL USUARIO/A /RESPONSABLE O REFERENTE',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 16),
            pw.Text('Yo, **$nombrePaciente** con C.I. ${acta.idPaciente} ingreso voluntariamente al Centro o Servicio para personas adultas mayores, a partir de la presente fecha:'),
            pw.SizedBox(height: 8),
            pw.Text('${dateFormat.format(acta.fechaCreacion)}'),
            pw.SizedBox(height: 16),
            pw.Text(
              'Además manifiesto, que he sido informado/a de los reglamentos y códigos de convivencia existentes en el Centro Gerontológico, comprometiéndome a través de la presente a cumplir con las responsabilidades y deberes, así como a aceptar las acciones del Plan de Atención Integral Individual que el equipo técnico programe, y colaborar para que éste se cumpla. Además me comprometo a mantener las instalaciones, muebles y equipos en buen estado, dando el trato adecuado para su conservación.',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'NOMBRE PERSONA ADULTA MAYOR',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('$nombrePaciente'),
            pw.SizedBox(height: 8),
            pw.Text(
              'FAMILIAR O REFERENTE',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('${acta.nombreCompleto}'),
            pw.Text('C.I: ${acta.cedulaIdentidad}'),
            pw.Text('TELÉFONO: ${acta.telefono}'),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

}
