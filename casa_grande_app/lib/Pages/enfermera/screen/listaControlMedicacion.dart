import 'package:casa_grande_app/Services/Paciente.service.dart';
import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Paciente.model.dart';

class ListaControlMedicacion extends StatelessWidget {
  final PacienteService _pacienteService = PacienteService();

  ListaControlMedicacion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Medicación'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: StreamBuilder<List<Paciente>>(
          stream: _pacienteService.getPacientes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error al cargar pacientes'));
            }

            final pacientes = snapshot.data ?? [];

            if (pacientes.isEmpty) {
              return const Center(child: Text('No hay pacientes registrados'));
            }

            return ListView.separated(
              itemCount: pacientes.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final paciente = pacientes[index];
                return ListTile(
                  leading: const Icon(Icons.person, size: 36, color: Colors.blueAccent),
                  title: Text(
                    paciente.nombre ?? 'Sin nombre',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(paciente.cedula ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.pushNamed(context, '/FichasMedicacion', arguments: paciente.cedula);
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Colors.grey[100],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
            );
          },
        ),
      ),
    );
  }
}
