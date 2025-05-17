import 'package:casa_grande_app/Models/UserModel.dart';
import 'package:casa_grande_app/Pages/enfermera/screen/signos_list.page.dart';
import 'package:casa_grande_app/Services/Auth.Service.dart';
import 'package:casa_grande_app/Widgets/AvisosListWidget.dart';
import 'package:casa_grande_app/Widgets/avisosUser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircleAvatar, MaterialPageRoute;
import '../../../Widgets/action_button.dart';

class NurseDashboard extends StatelessWidget {
  final UserModel user;
  final AuthService authService = AuthService();

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
              // User Information Header
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
                          'Welcome, ${user.nombre}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.systemGreen,
                          ),
                        ),
                        Text(
                          'Role: ${user.cargo}',
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

              // Quick Actions for Nursing
              const Text(
                'Quick Actions',
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
                      label: 'Register\nAttendance',
                      icon: CupertinoIcons.checkmark_circle,
                      onPressed: () => Navigator.pushNamed(
                          context, '/RegistrarAsistenciaUsuario',
                          arguments: user),
                    ),
                    ActionButton(
                      label: 'Register\nPatient Attendance',
                      icon: CupertinoIcons.checkmark_circle,
                      onPressed: () => Navigator.pushNamed(
                          context, '/registrarAsistenciaPaciente'),
                    ),
                    ActionButton(
                      label: 'Register\nSigns',
                      icon: CupertinoIcons.heart,
                      onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ListaPacientesScreen()),
  );
},

                    ),
                    ActionButton(
                      label: 'Medication\nControl',
                      icon: CupertinoIcons.capsule,
                      onPressed: () => Navigator.pushNamed(
                          context, '/ListaControlMedicacion'),
                    ),
                    ActionButton(
                      label: 'Logout',
                      icon: CupertinoIcons.power,
                      onPressed: () =>
                          authService.signOutAndNavigateToLogin(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Activity Summary
              const Text(
                'Activity Summary',
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