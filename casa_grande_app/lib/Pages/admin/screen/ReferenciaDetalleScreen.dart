import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Referencia.model.dart';
import '../../../Services/Referencia.service.dart';

class ReferenciaDetalleScreen extends StatefulWidget {
  final String idPaciente;

  ReferenciaDetalleScreen({required this.idPaciente});

  @override
  _ReferenciaDetalleScreenState createState() =>
      _ReferenciaDetalleScreenState();
}

class _ReferenciaDetalleScreenState extends State<ReferenciaDetalleScreen> {
  late Future<Referencia?> referencia;

  @override
  void initState() {
    super.initState();
    referencia = ReferenciaService().getReferenciaByPacienteCedula(widget.idPaciente);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Referencia Geriátrica'),
        backgroundColor: Colors.teal[700],
        elevation: 0,
      ),
      body: FutureBuilder<Referencia?>(
        future: referencia,
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
          } else if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No se encontró información del paciente',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          } else {
            Referencia referencia = snapshot.data!;

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
                                      '${referencia.idPaciente.nombre} ${referencia.idPaciente.apellido}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'C.I.: ${referencia.idPaciente.cedula}',
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Información de contacto del paciente
                    _buildSection(
                      title: 'Información de Contacto',
                      icon: Icons.contact_phone,
                      children: [
                        _buildInfoRow('Teléfono:', referencia.idPaciente.telefono),
                        _buildInfoRow('Dirección:', referencia.idPaciente.direccion),
                      ],
                    ),

                    // Información de la referencia médica
                    _buildSection(
                      title: 'Información de Referencia Geriátrica',
                      icon: Icons.medical_services,
                      children: [
                        _buildInfoRow('Fecha de Referencia:', referencia.fecha.toIso8601String()),
                        _buildInfoRow('Institución:', referencia.nombreInstitucion),
                        _buildInfoRow('Motivo de Referencia:', referencia.motivoReferencia, isMultiline: true),
                        _buildInfoRow('Recomendaciones:', referencia.recomendaciones, isMultiline: true),
                      ],
                    ),

                    // Ubicación de la institución
                    _buildSection(
                      title: 'Ubicación de la Institución',
                      icon: Icons.location_on,
                      children: [
                        _buildInfoRow('Dirección:', referencia.direccion),
                        _buildInfoRow('Zona:', referencia.zona),
                        _buildInfoRow('Distrito:', referencia.distrito),
                        _buildInfoRow('Ciudad:', referencia.ciudad),
                        _buildInfoRow('Cantón:', referencia.canton),
                        _buildInfoRow('Parroquia:', referencia.parroquia),
                      ],
                    ),

                    // Contactos de la institución
                    _buildSection(
                      title: 'Contactos de la Institución',
                      icon: Icons.phone,
                      children: [
                        _buildInfoRow('Teléfono:', referencia.telefono),
                        _buildInfoRow('Teléfono Celular:', referencia.telefonoCelular),
                        _buildInfoRow('Teléfono Fijo:', referencia.telefonoFijo),
                      ],
                    ),

                    // Información adicional
                    _buildSection(
                      title: 'Información Institucional',
                      icon: Icons.business,
                      children: [
                        _buildInfoRow('Institución que Transfiere:', referencia.institucionTransfiere),
                        _buildInfoRow('Modalidad de Servicios:', referencia.modalidadServicios),
                        _buildInfoRow('Director/Coordinador:', referencia.directorCoordinador),
                        _buildInfoRow('Razón Social:', referencia.razonSocial),
                      ],
                    ),

                    // Personal y acompañantes
                    _buildSection(
                      title: 'Personal y Acompañantes',
                      icon: Icons.people,
                      children: [
                        _buildInfoRow('Familiar/Acompañante:', referencia.familiarAcompanante),
                        _buildInfoRow('Personal Acompañante:', referencia.personalAcompanante),
                        _buildInfoRow('Profesional que Refiere:', referencia.profesionalRefiere),
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
}