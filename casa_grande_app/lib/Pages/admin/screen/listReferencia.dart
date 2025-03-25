import 'package:casa_grande_app/Pages/admin/form/agregarReferenciaScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Referencia.model.dart';
import 'package:casa_grande_app/Services/Referencia.service.dart';

class ReferenciaListScreen extends StatefulWidget {
  const ReferenciaListScreen({Key? key}) : super(key: key);

  @override
  _ReferenciaListScreenState createState() => _ReferenciaListScreenState();
}

class _ReferenciaListScreenState extends State<ReferenciaListScreen> {
  final ReferenciaService referenciaService = ReferenciaService();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Lista de Referencias'),
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
              child: StreamBuilder<List<Referencia>>(
  stream: referenciaService.getReferencias(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CupertinoActivityIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
      return const Center(child: Text('No hay referencias registradas'));
    } else {
      final referencias = snapshot.data!;
      return ListView.builder(
        itemCount: referencias.length,
        itemBuilder: (context, index) {
          final referencia = referencias[index];
          return Material(
            child: ListTile(
              title: Text('Paciente: ${referencia.idPaciente.nombre } ${referencia.idPaciente.apellido }'),
              subtitle: Text('Institución: ${referencia.nombreInstitucion}'),
              onTap: () {
                            Navigator.pushNamed(
                context,
                '/detalleRefeencia',
                arguments: referencia.idPaciente.cedula, // Pasar el idPaciente
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
            // Botón flotante personalizado
            Positioned(
              bottom: 20, // Distancia desde la parte inferior
              right: 20, // Distancia desde la derecha
              child: CupertinoButton(
                padding: const EdgeInsets.all(16.0),
                color: CupertinoColors.activeBlue, // Color del botón
                borderRadius: BorderRadius.circular(30), // Bordes redondeados
                onPressed: () {
                  // Navegar a la pantalla de agregar referencia
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const AgregarReferenciaScreen(),
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
