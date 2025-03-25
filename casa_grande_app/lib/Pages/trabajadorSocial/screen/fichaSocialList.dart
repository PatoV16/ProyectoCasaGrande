import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Models/Paciente.model.dart';
import '../../../Services/FichaSocial.service.dart';
import '../../../Services/Paciente.service.dart';

class PacientesFichaSocialList extends StatelessWidget {
  final PacienteService pacienteService = PacienteService();
  final FichaSocialService fichaSocialService = FichaSocialService();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Fichas Sociales'),
        backgroundColor: Color(0xFF6750A4), // Color púrpura para mantener consistencia
      ),
      child: SafeArea(
        child: StreamBuilder<List<Paciente>>(
          stream: pacienteService.getPacientes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CupertinoActivityIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.exclamationmark_circle, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error al cargar pacientes: ${snapshot.error}'),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.person_2, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No hay pacientes registrados'),
                    SizedBox(height: 24),
                    
                  
                  ],
                ),
              );
            }

            final pacientes = snapshot.data!;

            return ListView.builder(
              itemCount: pacientes.length,
              padding: EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final paciente = pacientes[index];
                
                // Widget para la tarjeta del paciente con ficha social
                return FutureBuilder<bool>(
                  future: _tieneFichaSocial(paciente.cedula),
                  builder: (context, hasFileSnapshot) {
                    // Estado de carga
                    if (hasFileSnapshot.connectionState == ConnectionState.waiting) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text('${paciente.nombre} ${paciente.apellido}'),
                          subtitle: Text('Verificando ficha social...'),
                          trailing: CupertinoActivityIndicator(),
                        ),
                      );
                    }

                    // Indicador visual si tiene ficha social o no
                    final tieneFicha = hasFileSnapshot.data ?? false;
                    
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: tieneFicha ? Colors.green : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: tieneFicha ? Colors.green[100] : Colors.orange[100],
                          child: Icon(
                            tieneFicha ? CupertinoIcons.doc_checkmark : CupertinoIcons.doc_append,
                            color: tieneFicha ? Colors.green : Colors.orange,
                          ),
                        ),
                        title: Text(
                          '${paciente.nombre} ${paciente.apellido}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text('C.I.: ${paciente.cedula}'),
                            SizedBox(height: 2),
                            Text(
                              tieneFicha ? 'Ficha social registrada' : 'Sin ficha social',
                              style: TextStyle(
                                color: tieneFicha ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(CupertinoIcons.chevron_right),
                        onTap: () {
                          // Navegar a la pantalla de detalle de ficha social
                          Navigator.pushNamed(
                            context,
                            '/VerFichaSocial',
                            arguments: {'idPaciente': paciente.cedula},
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Método para verificar si un paciente tiene ficha social
  Future<bool> _tieneFichaSocial(String pacienteId) async {
    try {
      final fichaSocial = await fichaSocialService.getFichaSocialByPaciente(pacienteId);
      return fichaSocial != null;
    } catch (e) {
      print('Error al verificar ficha social: $e');
      return false;
    }
  }
}

// Este widget puede ser implementado en un archivo separado
class FichaSocialCard extends StatelessWidget {
  final Paciente paciente;
  final bool tieneFichaSocial;

  const FichaSocialCard({
    Key? key,
    required this.paciente,
    required this.tieneFichaSocial,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: tieneFichaSocial ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: tieneFichaSocial ? Colors.green[100] : Colors.orange[100],
          child: Icon(
            tieneFichaSocial ? CupertinoIcons.doc_checkmark : CupertinoIcons.doc_append,
            color: tieneFichaSocial ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          '${paciente.nombre} ${paciente.apellido}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('C.I.: ${paciente.cedula}'),
            SizedBox(height: 2),
            Text(
              tieneFichaSocial ? 'Ficha social registrada' : 'Sin ficha social',
              style: TextStyle(
                color: tieneFichaSocial ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Icon(CupertinoIcons.chevron_right),
        onTap: () {
          // Navegar a la pantalla de detalle de ficha social
          Navigator.pushNamed(
            context,
            '/fichaSocial',
            arguments: {'idPaciente': paciente.cedula},
          );
        },
      ),
    );
  }
}