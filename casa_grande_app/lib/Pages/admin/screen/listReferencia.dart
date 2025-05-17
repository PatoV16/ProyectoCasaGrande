import 'package:casa_grande_app/Models/Paciente.model.dart';
import 'package:casa_grande_app/Pages/admin/form/agregarReferenciaScreen.dart';
import 'package:casa_grande_app/Services/Paciente.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Referencia.model.dart';
import 'package:casa_grande_app/Pages/admin/screen/listaReferenciaUsuarios.dart';

class ReferenciaListScreen extends StatefulWidget {
  const ReferenciaListScreen({Key? key}) : super(key: key);

  @override
  _ReferenciaListScreenState createState() => _ReferenciaListScreenState();
}

class _ReferenciaListScreenState extends State<ReferenciaListScreen> {
  final PacienteService _pacienteService = PacienteService();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Lista de Pacientes'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add, size: 28),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => AgregarReferenciaScreen(),
              ),
            );
            print('Agregar nueva ficha');
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<List<Paciente>>(
            stream: _pacienteService.getPacientes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay pacientes registrados'));
              } else {
                final pacientes = snapshot.data!;
                return ListView.builder(
                  itemCount: pacientes.length,
                  itemBuilder: (context, index) {
                    final paciente = pacientes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(paciente.nombre.substring(0, 1)),
                        ),
                        title: Text(
                          '${paciente.nombre} ${paciente.apellido}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cédula: ${paciente.cedula}'),
                            Text('Teléfono: ${paciente.telefono}'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => FichaPacienteListScreen(
                                idPaciente: paciente.cedula,
                                id: paciente.id.toString(),
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