import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Referencia.model.dart';
import 'package:casa_grande_app/Services/Referencia.service.dart';
import 'package:casa_grande_app/Pages/admin/screen/ReferenciaDetalleScreen.dart';

class FichaPacienteListScreen extends StatefulWidget {
  final String idPaciente; // Cambié cedulaPaciente por idPaciente
  final String id;
  const FichaPacienteListScreen({Key? key, required this.idPaciente, required this.id }) : super(key: key);

  @override
  _FichaPacienteListScreenState createState() => _FichaPacienteListScreenState();
}

class _FichaPacienteListScreenState extends State<FichaPacienteListScreen> {
  final ReferenciaService referenciaService = ReferenciaService();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Fichas del Paciente'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Referencia>>(
            future: referenciaService.getReferenciasByPacienteId(widget.idPaciente), // Usa la función correcta
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay fichas registradas para este paciente'));
              } else {
                final referencias = snapshot.data!;
                return ListView.builder(
                  itemCount: referencias.length,
                  itemBuilder: (context, index) {
                    final referencia = referencias[index];
                    return Material(
                      child: ListTile(
                        title: Text('Institución: ${referencia.nombreInstitucion}'),
                        subtitle: Text('Ciudad: ${referencia.ciudad}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ReferenciaDetalleScreen(
                                idPaciente: widget.idPaciente, id: widget.id
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
