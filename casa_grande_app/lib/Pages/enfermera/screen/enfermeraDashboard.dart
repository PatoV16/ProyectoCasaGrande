import 'package:casa_grande_app/Models/UserModel.dart';
import 'package:casa_grande_app/Services/Auth.Service.dart';
import 'package:casa_grande_app/Widgets/AvisosListWidget.dart';
import 'package:casa_grande_app/Widgets/avisosUser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircleAvatar;

import '../../../Widgets/action_button.dart';

class NurseDashboard extends StatelessWidget {
  final UserModel user;
  final authService = AuthService();

  NurseDashboard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Panel de Enfermería'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con información del usuario
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: CupertinoColors.systemGreen,
                    child: Icon(
                      CupertinoIcons.person,
                      color: CupertinoColors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenida, ${user.nombre}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.systemGreen,
                          ),
                        ),
                        Text(
                          'Cargo: ${user.cargo}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Acciones Rápidas para Enfermería
              const Text(
                'Acciones Rápidas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    
                    ActionButton(
                      label: 'Registrar\nSignos',
                      icon: CupertinoIcons.heart,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/RegistrarSignos', arguments: user),
                    ),
                    ActionButton(
                      label: 'Control de\nMedicación',
                      icon: CupertinoIcons.capsule,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/ListaControlMedicacion'),
                    ),
                    ActionButton(
                      label: 'Cerrar sesión',
                      icon: CupertinoIcons.power,
                      onPressed: () =>
                          authService.signOutAndNavigateToLogin(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Resumen de Avisos
              const Text(
                'Resumen de Actividad',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              AvisosListUserWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
