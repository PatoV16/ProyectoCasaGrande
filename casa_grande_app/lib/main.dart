import 'package:casa_grande_app/Models/Barthel.model.dart';
import 'package:casa_grande_app/Models/Empleado.model.dart';
import 'package:casa_grande_app/Models/Paciente.model.dart';
import 'package:casa_grande_app/Models/UserModel.dart';
import 'package:casa_grande_app/Pages/admin/form/avisosForm.dart';
import 'package:casa_grande_app/Pages/admin/screen/ReferenciaDetalleScreen.dart';
import 'package:casa_grande_app/Pages/admin/form/actaCompromiso.page.dart';
import 'package:casa_grande_app/Pages/admin/screen/adminDashboard.page.dart';
import 'package:casa_grande_app/Pages/admin/screen/asistencia.page.dart';
import 'package:casa_grande_app/Pages/admin/screen/avisosLista.page.dart';
import 'package:casa_grande_app/Pages/admin/screen/edithEmpleado.dart';
import 'package:casa_grande_app/Pages/admin/screen/empleadoList.page.dart';
import 'package:casa_grande_app/Pages/admin/form/empleado_form.dart';
import 'package:casa_grande_app/Pages/admin/screen/listReferencia.dart';
import 'package:casa_grande_app/Pages/admin/screen/listaActas.dart';
import 'package:casa_grande_app/Pages/admin/form/paciente_form.dart';
import 'package:casa_grande_app/Pages/admin/screen/verActaCompromiso.dart';
import 'package:casa_grande_app/Pages/medico/Form/fichaMedica.form.dart';
import 'package:casa_grande_app/Pages/medico/Screen/ListaPacientes.dart';
import 'package:casa_grande_app/Pages/medico/Screen/fichaMedicaScreen.dart';
import 'package:casa_grande_app/Pages/psicologo/form/barthleform.dart';
import 'package:casa_grande_app/Pages/psicologo/form/informePsicologoform.dart';
import 'package:casa_grande_app/Pages/psicologo/form/lawton.form.dart';
import 'package:casa_grande_app/Pages/psicologo/form/yesavageform.dart';
import 'package:casa_grande_app/Pages/psicologo/screen/barthelList.dart';
import 'package:casa_grande_app/Pages/psicologo/screen/barthelScreen.dart';
import 'package:casa_grande_app/Pages/psicologo/screen/informePsicologoScreen.dart';
import 'package:casa_grande_app/Pages/psicologo/screen/lawtonScreen.dart';
import 'package:casa_grande_app/Pages/psicologo/screen/psicologoDashboard.dart';
import 'package:casa_grande_app/Pages/psicologo/screen/yesavageScreen.dart';
import 'package:casa_grande_app/Pages/trabajadorSocial/form/fichaSocialform.dart';
import 'package:casa_grande_app/Pages/trabajadorSocial/screen/dashboardTrabajadorSocial.dart';
import 'package:casa_grande_app/Pages/trabajadorSocial/screen/fichaSocialList.dart';
import 'package:casa_grande_app/Pages/trabajadorSocial/screen/fichaSocialScreen.dart';
import 'package:casa_grande_app/Widgets/EvolucionCard.dart';
import 'package:casa_grande_app/Widgets/Login_Screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Pages/admin/screen/actasCompromisoScreen.dart';
import 'Pages/medico/Screen/MedicDashboard.screen.dart';
import 'Pages/psicologo/form/minimentalform.dart';
import 'Pages/psicologo/screen/minimentalScreen.dart';
import 'firebase_options.dart'; // Asegúrate de importar el archivo generado
import 'package:provider/provider.dart';
import 'package:casa_grande_app/Services/ActaCompromiso.service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase con los options generados en firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ActaCompromisoService>(
          create: (_) => ActaCompromisoService(),
        ),
        // Otros providers que necesites
      ],
      child: MaterialApp(
        title: 'Casa Grande',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // Definimos las rutas de la aplicación
        initialRoute: '/login', // Ruta inicial
        routes: {
          '/login': (context) => LoginScreen(), // Pantalla de login
          //****/Administrador/ */
          '/admin': (context) => AdminDashboard(),
          '/registrarPaciente': (context) => const PacienteForm(),
          '/registrarEmpleado': (context) => const EmpleadoForm(),
          '/registrarActaCompromiso': (context) => const ActaCompromisoForm(),
          '/empleadosList': (context) => const EmpleadoListScreen(),
          '/registrarAsistenciaPaciente': (context) => const AsistenciaListScreen(),
          '/referenciaLista': (context) => const ReferenciaListScreen(),
          '/listaActasCompromiso': (context) => const ActaCompromisoListScreen(),
          '/listaAvisos': (context) =>  AgregarAvisoScreen(),
          '/cartaCompomiso': (context) =>  CartaCompromisoScreen(),
          '/verActaCompromiso': (context) {
                                      final args = ModalRoute.of(context)!.settings.arguments as String;
                                      return ActaCompromisoDisplay(idPaciente: args);
                                    },
          '/EditarEmpleado': (context) {
                                      final args = ModalRoute.of(context)!.settings.arguments as String;
                                      return EditarEmpleadoScreen(idEmpleado: args);
                                    },
          '/detalleRefeencia': (context){
                                      final args = ModalRoute.of(context)!.settings.arguments as String;
                                      return ReferenciaDetalleScreen(idPaciente: args);
                                    },
          //*****/Médico/******** */
          '/Evolucion': (context) => EvolucionScreen(),
          '/MedicDashboard': (context){
                                      final args = ModalRoute.of(context)!.settings.arguments as UserModel;
                                      return MedicDashboard(user: args);
          
          },
          '/PacienteLista': (context) => PacientesList(),
          // Aquí puedes agregar más rutas para otros dashboards
          '/agregarFichaMedica': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
            return FichaMedicaForm(idPaciente: args['idPaciente']!, idEmpleado: args['idEmpleado']!);
          },
          '/verFichaMedica': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
            return FichaMedicaDetalleScreen (idPaciente: args['idPaciente']!);
          },
          //************************/Psicologo/********************* */ */
          '/PsicologoDashboard': (context){
                                        final args = ModalRoute.of(context)!.settings.arguments as UserModel;
                                        return PsicologoDashboard (user: args);
            
          },
          '/listaBarthel': (context) => PacientesBarthelList(),
          '/VerBarthel': (context){
            // Modificado para aceptar tanto String como Map
            final args = ModalRoute.of(context)!.settings.arguments;
            String idPaciente;
            
            if (args is Map<String, String>) {
              idPaciente = args['idPaciente'] ?? '';
            } else if (args is String) {
              idPaciente = args;
            } else {
              idPaciente = '';
            }
            
            return BarthelDetalleScreen(idPaciente: idPaciente);
          },
          '/FormBarthel': (context){
            // Modificado para aceptar tanto String como Map
            final args = ModalRoute.of(context)!.settings.arguments;
            String idPaciente;
            
            if (args is Map<String, String>) {
              idPaciente = args['idPaciente'] ?? '';
            } else if (args is String) {
              idPaciente = args;
            } else {
              idPaciente = '';
            }
            
            return BarthelForm(idPaciente: idPaciente);
          },
          '/VerLawton': (context){
            // Modificado para aceptar tanto String como Map
            final args = ModalRoute.of(context)!.settings.arguments;
            String idPaciente;
            
            if (args is Map<String, String>) {
              idPaciente = args['idPaciente'] ?? '';
            } else if (args is String) {
              idPaciente = args;
            } else {
              idPaciente = '';
            }
            
            return LawtonDetalleScreen(idPaciente: idPaciente);
          },
          '/FormLawton': (context){
            // Modificado para aceptar tanto String como Map
            final args = ModalRoute.of(context)!.settings.arguments;
            String idPaciente;
            
            if (args is Map<String, String>) {
              idPaciente = args['idPaciente'] ?? '';
            } else if (args is String) {
              idPaciente = args;
            } else {
              idPaciente = '';
            }
            
            return LawtonBrodyForm(idPaciente: idPaciente);
          },
          '/FormMiniExamen': (context){
            // Modificado para aceptar tanto String como Map
            final args = ModalRoute.of(context)!.settings.arguments;
            String idPaciente;
            
            if (args is Map<String, String>) {
              idPaciente = args['idPaciente'] ?? '';
            } else if (args is String) {
              idPaciente = args;
            } else {
              idPaciente = '';
            }
            
            return MiniExamenForm(idPaciente: idPaciente);
          },
          '/VerMiniExamen': (context){
            // Modificado para aceptar tanto String como Map
            final args = ModalRoute.of(context)!.settings.arguments;
            String idPaciente;
            
            if (args is Map<String, String>) {
              idPaciente = args['idPaciente'] ?? '';
            } else if (args is String) {
              idPaciente = args;
            } else {
              idPaciente = '';
            }
            
            return MiniExamenDetalleScreen(idPaciente: idPaciente);
          },
          ///FormYesavage
          ///
          '/VerYesavage': (context){
            // Modificado para aceptar tanto String como Map
            final args = ModalRoute.of(context)!.settings.arguments;
            String idPaciente;
            
            if (args is Map<String, String>) {
              idPaciente = args['idPaciente'] ?? '';
            } else if (args is String) {
              idPaciente = args;
            } else {
              idPaciente = '';
            }
            
            return YesavageDetalleScreen(idPaciente: idPaciente);
          },
          '/FormYesavage': (context){
            // Modificado para aceptar tanto String como Map
            final args = ModalRoute.of(context)!.settings.arguments;
            String idPaciente;
            
            if (args is Map<String, String>) {
              idPaciente = args['idPaciente'] ?? '';
            } else if (args is String) {
              idPaciente = args;
            } else {
              idPaciente = '';
            }
            
            return YesavageForm(idPaciente: idPaciente);
          },
          '/FormInforme': (context){
            // Modificado para aceptar tanto String como Map
            final args = ModalRoute.of(context)!.settings.arguments;
            String idPaciente;
            
            if (args is Map<String, String>) {
              idPaciente = args['idPaciente'] ?? '';
            } else if (args is String) {
              idPaciente = args;
            } else {
              idPaciente = '';
            }
            
            return EvaluacionPsicologicaForm(idPaciente: idPaciente);
          },
          '/VerInforme': (context){
            // Modificado para aceptar tanto String como Map
            final args = ModalRoute.of(context)!.settings.arguments;
            String idPaciente;
            
            if (args is Map<String, String>) {
              idPaciente = args['idPaciente'] ?? '';
            } else if (args is String) {
              idPaciente = args;
            } else {
              idPaciente = '';
            }
            
            return EvaluacionPsicologicaDetalleScreen(idPaciente: idPaciente);
          },
          //******************/Trabajador Social/******************** */
          '/TrabajadorSocialDashboard': (context){
                                        final args = ModalRoute.of(context)!.settings.arguments as UserModel;
                                        return TrabajadorSocialDashboard (user: args);
            
          },
          '/listaFichaSocial': (context) => PacientesFichaSocialList(),
          '/VerFichaSocial': (context){
            // Modificado para aceptar tanto String como Map
            final args = ModalRoute.of(context)!.settings.arguments;
            String idPaciente;
            
            if (args is Map<String, String>) {
              idPaciente = args['idPaciente'] ?? '';
            } else if (args is String) {
              idPaciente = args;
            } else {
              idPaciente = '';
            }
            
            return FichaSocialScreen(idPaciente: idPaciente);
          },
          '/FormFichaSocial': (context){
            // Modificado para aceptar tanto String como Map
            final args = ModalRoute.of(context)!.settings.arguments;
            String idPaciente;
            
            if (args is Map<String, String>) {
              idPaciente = args['idPaciente'] ?? '';
            } else if (args is String) {
              idPaciente = args;
            } else {
              idPaciente = '';
            }
            
            return FichaSocialForm(idPaciente: idPaciente);
          },

        },
      ),
    );
  }
}