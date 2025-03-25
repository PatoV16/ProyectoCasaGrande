import 'package:casa_grande_app/Services/Auth.Service.dart';
import 'package:casa_grande_app/Widgets/AvisosListWidget.dart';
import 'package:flutter/cupertino.dart';
import '../../../Widgets/action_button.dart';
import '../../../Widgets/stats_card.dart';

class AdminDashboard extends StatelessWidget {
   AdminDashboard({Key? key}) : super(key: key);
  final authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Panel Administrativo'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bienvenido, Administrador',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemBlue,
                ),
              ),
              const SizedBox(height: 20),

              // Acciones Rápidas
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionButton(
                      label: 'Registrar\nEmpleado',
                      icon: CupertinoIcons.person_add,
                      onPressed: () => Navigator.pushNamed(context, '/registrarEmpleado'),
                    ),
                    ActionButton(
                      label: 'Listar\nEmpleados',
                      icon: CupertinoIcons.list_bullet,
                      onPressed: () => Navigator.pushNamed(context, '/empleadosList'),
                    ),
                    ActionButton(
                      label: 'Avisos',
                      icon: CupertinoIcons.bell,
                      onPressed: () => Navigator.pushNamed(context, '/listaAvisos'),
                    ),
                    ActionButton(
                      label: 'Acta',
                      icon: CupertinoIcons.doc_text,
                      onPressed: () => Navigator.pushNamed(context, '/listaActasCompromiso'),
                    ),
                    ActionButton(
                      label: 'Registrar\nPaciente',
                      icon: CupertinoIcons.person_add,
                      onPressed: () => Navigator.pushNamed(context, '/registrarPaciente'),
                    ),
                    ActionButton(
                      label: 'Referencia',
                      icon: CupertinoIcons.arrow_right_arrow_left,
                      onPressed: () => Navigator.pushNamed(context, '/referenciaLista'),
                    ),
                    ActionButton(
  label: 'Cerrar sesión',
  icon: CupertinoIcons.power,  // Ícono de logout
  onPressed: () => authService.signOutAndNavigateToLogin(context) ,
),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Resumen de Empleados
              Row(
                children: [
                  Expanded(
                    child: AvisosListWidget(),
                  ),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
