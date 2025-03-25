import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/ActaCompromiso.model.dart';

class ActaCompromisoCard extends StatelessWidget {
  final ActaCompromiso acta;

  const ActaCompromisoCard({Key? key, required this.acta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text('Acta: ${acta.idPaciente}'),
        subtitle: Text('Fecha: ${acta.fechaCreacion}'),
        trailing: PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'ver') {
              Navigator.pushNamed(
                context,
                '/verActaCompromiso',
                arguments: acta.idPaciente, // Pasar el idPaciente
              );
            } else if (value == 'editar') {
              Navigator.pushNamed(context, '/cartaCompomiso');
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'ver',
              child: Text('Ver Acta'),
            ),
            const PopupMenuItem<String>(
              value: 'editar',
              child: Text('Editar Acta'),
            ),
          ],
        ),
      ),
    );
  }
}
