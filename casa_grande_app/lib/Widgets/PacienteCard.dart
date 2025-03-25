import 'package:casa_grande_app/Services/Auth.Service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Paciente.model.dart';

import '../Models/FichaMedica.model.dart';
import '../Services/FichaMedica.service.dart'; // Asegúrate de que esta importación esté correcta

class PacienteCard extends StatelessWidget {
  final Paciente paciente;

  PacienteCard({Key? key, required this.paciente}) : super(key: key);

  final authService = AuthService();
  final fichaMedicaService = FichaMedicaService(); // Servicio de ficha médica

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre y Apellido
            Text(
              '${paciente.nombre} ${paciente.apellido}',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 8),
            // Cédula
            Text(
              'Cédula: ${paciente.cedula}',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            // Estado Civil y Profesión
            Text(
              'Estado Civil: ${paciente.estadoCivil}',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 16),
            ),
            Text(
              'Profesión: ${paciente.profesionOcupacion}',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            // Botón para ver detalles o agregar ficha médica
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(30),
              onPressed: () async {
                try {
                  String idEmpleado = await authService.obtenerUIDUsuario(); // Obtener el UID del empleado
                  // Verifica si el paciente tiene una ficha médica
                  FichaMedica? ficha = await fichaMedicaService.getFichaMedicaByPacienteCedula(paciente.cedula);

                  if (ficha != null) {
                    // Si tiene ficha médica, navegar a la vista de ver detalles
                    Navigator.pushNamed(
                      context,
                      '/verFichaMedica',
                      arguments: {
                        'idPaciente': paciente.cedula,
                      },
                    );
                  } else {
                    // Si no tiene ficha médica, navegar a la vista para agregar ficha
                    Navigator.pushNamed(
                      context,
                      '/agregarFichaMedica',
                      arguments: {
                        'idPaciente': paciente.cedula,
                        'idEmpleado': idEmpleado,
                      },
                    );
                  }
                } catch (e) {
                  print("Error obteniendo el UID del usuario o ficha médica: $e");
                }
              },
              child: const Text(
                'Ver Detalles o Agregar Ficha',
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
