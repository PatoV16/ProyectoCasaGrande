import 'package:casa_grande_app/Models/UserModel.dart';
import 'package:casa_grande_app/Services/Auth.Service.dart';
import 'package:casa_grande_app/Widgets/avisosUser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircleAvatar, Divider, TextButton;
import '../../../../Widgets/action_button.dart';
import '../../../../Widgets/stats_card.dart';

class TrabajadorSocialDashboard extends StatelessWidget {
  final UserModel user; // Modelo de usuario con información como nombre y cargo
  final authService = AuthService();
  
  TrabajadorSocialDashboard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Panel Trabajador Social'),
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
                    backgroundColor: CupertinoColors.systemBlue,
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
                          'Bienvenido, ${user.nombre}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.systemBlue,
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

              // Acciones estándar para el trabajador social
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
                      label: 'Registrar\nAsistencia',
                      icon: CupertinoIcons.checkmark_circle,
                      onPressed: () => Navigator.pushNamed(context,'/RegistrarAsistenciaUsuario', arguments: user),

                    ),
                    ActionButton(
                      label: 'Evoución\nSocial',
                      icon: CupertinoIcons.chart_bar,
                      onPressed: () => Navigator.pushNamed(context, '/Evolucion'),
                    ),
                    ActionButton(
                      label: 'Nueva\nFicha',
                      icon: CupertinoIcons.doc_append,
                      onPressed: () => Navigator.pushNamed(context, '/listaFichaSocial'),
                    ),
                   
                    ActionButton(
                      label: 'Cerrar sesión',
                      icon: CupertinoIcons.power,  // Ícono de logout
                      onPressed: () => authService.signOutAndNavigateToLogin(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Resumen de actividad
              const Text(
                'Resumen de Actividad',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                 Expanded(
                    child: AvisosListUserWidget(),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              
            ],
          ),
        ),
      ),
    );
  }

}
