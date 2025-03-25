import 'package:casa_grande_app/Pages/admin/form/registrarAsistencia.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Asistencia.model.dart';
import 'package:casa_grande_app/Services/Asistencia.service.dart';
import '../../../Widgets/input_field.dart';
import '../../../Widgets/submit_button.dart';

class AsistenciaListScreen extends StatefulWidget {
  const AsistenciaListScreen({Key? key}) : super(key: key);

  @override
  _AsistenciaListScreenState createState() => _AsistenciaListScreenState();
}

class _AsistenciaListScreenState extends State<AsistenciaListScreen> {
  final AsistenciaService asistenciaService = AsistenciaService();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Lista de Asistencias'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<List<Asistencia>>(
                stream: asistenciaService.getAsistencias(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay asistencias registradas'));
                  } else {
                    final asistencias = snapshot.data!;
                    return ListView.builder(
                      itemCount: asistencias.length,
                      itemBuilder: (context, index) {
                        final asistencia = asistencias[index];
                        return Material(
                          child: ListTile(
                            title: Text('Centro: ${asistencia.nombreCentro}'),
                            subtitle: Text('Paciente ID: ${asistencia.idPaciente}'),
                            onTap: () {
                              
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            // Botón flotante personalizado
            Positioned(
              bottom: 20, // Distancia desde la parte inferior
              right: 20, // Distancia desde la derecha
              child: CupertinoButton(
                padding: const EdgeInsets.all(16.0),
                color: CupertinoColors.activeBlue, // Color del botón
                borderRadius: BorderRadius.circular(30), // Bordes redondeados
                onPressed: () {
                  // Navegar a la pantalla de agregar asistencias
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const AgregarAsistenciaScreen(),
                    ),
                  );
                },
                child: const Icon(
                  CupertinoIcons.add, // Icono de "+"
                  color: CupertinoColors.white, // Color del icono
                  size: 28, // Tamaño del icono
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
