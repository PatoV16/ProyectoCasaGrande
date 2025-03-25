import 'package:casa_grande_app/Widgets/PsicologoCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:casa_grande_app/Models/Paciente.model.dart';

import '../../../Services/Paciente.service.dart';
import '../../../Widgets/PacienteCard.dart';

class PacientesBarthelList extends StatelessWidget {
  final PacienteService pacienteService = PacienteService(); // Instancia del servicio

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Lista de Pacientes'),
      ),
      child: SafeArea(
        child: StreamBuilder<List<Paciente>>(
          stream: pacienteService.getPacientes(), // Escuchar el flujo de pacientes
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CupertinoActivityIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar pacientes'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay pacientes disponibles'));
            }

            // Los pacientes están disponibles, mostramos la lista
            final pacientes = snapshot.data!;

            return ListView.builder(
              itemCount: pacientes.length,
              itemBuilder: (context, index) {
                return PsicologoCard(paciente: pacientes[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
