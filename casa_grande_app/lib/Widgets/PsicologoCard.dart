import 'package:casa_grande_app/Models/Barthel.model.dart';
import 'package:casa_grande_app/Services/Auth.Service.dart';
import 'package:casa_grande_app/Services/Barthel.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Paciente.model.dart';
import '../Services/FichaMedica.service.dart';

class PsicologoCard extends StatelessWidget {
  final Paciente paciente;

  PsicologoCard({
    Key? key,
    required this.paciente,
  }) : super(key: key);

  final authService = AuthService();
  final fichaMedicaService = FichaMedicaService();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${paciente.nombre} ${paciente.apellido}',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cédula: ${paciente.cedula}',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Estado Civil: ${paciente.estadoCivil}',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 16),
            ),
            Text(
              'Profesión: ${paciente.profesionOcupacion}',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                onSelected: (String value) {
                  _navegarAFicha(context, value);
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'Barthel',
                    child: const Text('Barthel'),
                    onTap: ()=> _navegarAFicha(context, 'Barthel'),
                  ),
                  PopupMenuItem(
                    value: 'Minimental',
                    child: Text('Minimental'),
                  ),
                   PopupMenuItem(
                    value: 'Lawton',
                    child: Text('Lawton'),
                  ),
                   PopupMenuItem(
                    value: 'Yessavage',
                    child: Text('Yessavage'),
                  ),
                  PopupMenuItem(
                    value: 'Informe',
                    child: Text('Informe'),
                  ),
                ],
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.menu),
                  label: const Text('Opciones'),
                  onPressed: null, // El botón solo activa el menú desplegable
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
   void _navegarAFicha(BuildContext context, String tipoFicha) {
    // Aquí puedes definir las rutas correspondientes según el tipo de ficha
    String ruta;
    switch (tipoFicha) {
      case 'Barthel':
        ruta = '/VerBarthel';
        break;
      case 'Minimental':
        ruta = '/VerMiniExamen';
        break;
      case 'Lawton':
        ruta = '/VerLawton';
        break;
      case 'Yessavage':
        ruta = '/VerYesavage';
        break;
      case 'Informe':
        ruta = '/VerInforme';
        break;
      default:
        ruta = '/';
    }

    Navigator.pushNamed(context, ruta, arguments: paciente.cedula);
  }
}
