import 'package:casa_grande_app/Pages/admin/form/actaCompromiso.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/ActaCompromiso.model.dart';
import 'package:casa_grande_app/Services/ActaCompromiso.service.dart';

import '../../../Widgets/ActaCompromisoCard.dart';

class ActaCompromisoListScreen extends StatefulWidget {
  const ActaCompromisoListScreen({Key? key}) : super(key: key);

  @override
  _ActaCompromisoListScreenState createState() => _ActaCompromisoListScreenState();
}

class _ActaCompromisoListScreenState extends State<ActaCompromisoListScreen> {
  final ActaCompromisoService actaCompromisoService = ActaCompromisoService();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Lista de Actas de Compromiso'),
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
              child: StreamBuilder<List<ActaCompromiso>>(
                stream: actaCompromisoService.getActasCompromiso(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay actas de compromiso registradas'));
                  } else {
                    final actas = snapshot.data!;
                    return ListView.builder(
                      itemCount: actas.length,
                      itemBuilder: (context, index) {
                        final acta = actas[index];
                        return ActaCompromisoCard(acta: acta); // Usa el widget reutilizable
                      },
                    );
                  }
                },
              ),
            ),
            // Botón flotante para agregar nueva acta de compromiso
            Positioned(
              bottom: 20, // Distancia desde la parte inferior
              right: 20, // Distancia desde la derecha
              child: CupertinoButton(
                padding: const EdgeInsets.all(16.0),
                color: CupertinoColors.activeBlue, // Color del botón
                borderRadius: BorderRadius.circular(30), // Bordes redondeados
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const ActaCompromisoForm(),
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