import 'package:casa_grande_app/Services/Auth.Service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Models/Empleado.model.dart';
import '../../../Models/UserModel.dart';
import '../../../Services/Empleado.service.dart';
import '../../../Services/Usuario.server.dart';
import '../../../Widgets/input_field.dart';
import '../../../Widgets/date_picker.dart';
import '../../../Widgets/submit_button.dart';

class EmpleadoForm extends StatefulWidget {
  const EmpleadoForm({Key? key}) : super(key: key);

  @override
  _EmpleadoFormState createState() => _EmpleadoFormState();
}

class _EmpleadoFormState extends State<EmpleadoForm> {
  final EmpleadoService empleadoService = EmpleadoService();
  final UserService userService = UserService();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmarContrasenaController = TextEditingController();
  final AuthService authService = AuthService();

  DateTime fechaContratacion = DateTime.now();
  String _cargo = 'Seleccionar cargo';
  String _estado = 'Activo';

  final List<String> cargos = [
    'Médico', 'Psicólogo', 'Trabajador Social', 'Enfermera', 
    'Administrador', 'Cocinero', 'Terapista', 'Cuidador',
    'Auxiliar de lavandería', 'Servicios Generales', 'Nutricionista'
  ];

  final List<String> estados = ['Activo', 'Inactivo'];

  void mostrarMensaje(String mensaje) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Información"),
        content: Text(mensaje),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  bool validarCampos() {
    String nombre = nombreController.text.trim();
    String apellido = apellidoController.text.trim();
    String cedula = cedulaController.text.trim();
    String telefono = telefonoController.text.trim();
    String correo = correoController.text.trim();
    String contrasena = contrasenaController.text;
    String confirmarContrasena = confirmarContrasenaController.text;

    RegExp regexLetras = RegExp(r'^[a-zA-Z\s]+$');
    RegExp regexCedula = RegExp(r'^\d{10}$');
    RegExp regexTelefono = RegExp(r'^\d{7,10}$');
    RegExp regexCorreo = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (nombre.isEmpty || !regexLetras.hasMatch(nombre)) {
      mostrarMensaje('Ingrese un nombre válido (solo letras).');
      return false;
    }
    if (apellido.isEmpty || !regexLetras.hasMatch(apellido)) {
      mostrarMensaje('Ingrese un apellido válido (solo letras).');
      return false;
    }
    if (!regexCedula.hasMatch(cedula)) {
      mostrarMensaje('La cédula debe tener exactamente 10 dígitos numéricos.');
      return false;
    }
    if (!regexTelefono.hasMatch(telefono)) {
      mostrarMensaje('El teléfono debe tener entre 7 y 10 dígitos numéricos.');
      return false;
    }
    if (!regexCorreo.hasMatch(correo)) {
      mostrarMensaje('Ingrese un correo electrónico válido.');
      return false;
    }
    if (_cargo == 'Seleccionar cargo') {
      mostrarMensaje('Seleccione un cargo válido.');
      return false;
    }
    if (contrasena.isEmpty || contrasena.length < 6) {
      mostrarMensaje('La contraseña debe tener al menos 6 caracteres.');
      return false;
    }
    if (contrasena != confirmarContrasena) {
      mostrarMensaje('Las contraseñas no coinciden.');
      return false;
    }

    return true;
  }

 void guardarEmpleado() async {
  if (!validarCampos()) return;

  try {
    // Verificar si ya existe un usuario con ese correo
    UserModel? usuarioExistente = await userService.getUserByEmail(correoController.text);
    if (usuarioExistente != null) {
      mostrarMensaje('Ya existe un usuario con este correo electrónico.');
      return;
    }

    // Crear instancia de UserModel sin idEmpleado aún
    UserModel nuevoUsuario = UserModel(
      idEmpleado: "", // Se asignará después del registro en Firebase
      correo: correoController.text,
      contrasena: contrasenaController.text,
      nombre: nombreController.text,
      apellido: apellidoController.text,
      cargo: _cargo,
    );

    // Registrar usuario en Firebase Auth y obtener el UID
    UserCredential userCredential = await authService.registerWithEmailAndPassword(
      correoController.text,
      contrasenaController.text,
      nuevoUsuario,
    );

    String uid = userCredential.user!.uid; // UID generado por Firebase

    // Ahora que tenemos el UID, creamos el empleado
    Empleado nuevoEmpleado = Empleado(
      nombre: nombreController.text,
      apellido: apellidoController.text,
      cedula: cedulaController.text,
      cargo: _cargo,
      fechaContratacion: fechaContratacion,
      telefono: telefonoController.text,
      correo: correoController.text,
      estado: _estado,
    );

    // Guardar empleado en la base de datos y obtener ID (si es necesario)
    String empleadoId = await empleadoService.addEmpleado(nuevoEmpleado);

    // Actualizar el idEmpleado del usuario con el UID de Firebase
    nuevoUsuario = nuevoUsuario.copyWith(idEmpleado: uid);

    // Guardar el usuario con el UID en Firestore
    await userService.addUser(nuevoUsuario, uid);

    mostrarMensaje('Empleado y cuenta de usuario creados correctamente');

    // Limpiar campos después de guardar
    nombreController.clear();
    apellidoController.clear();
    cedulaController.clear();
    telefonoController.clear();
    correoController.clear();
    contrasenaController.clear();
    confirmarContrasenaController.clear();
    setState(() {
      fechaContratacion = DateTime.now();
      _cargo = 'Seleccionar cargo';
    });
  } catch (e) {
    mostrarMensaje('Error al guardar: ${e.toString()}');
  }
}


  void _seleccionarCargo(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text("Selecciona un Cargo"),
        actions: cargos.map((cargo) {
          return CupertinoActionSheetAction(
            child: Text(cargo),
            onPressed: () {
              setState(() => _cargo = cargo);
              Navigator.pop(context);
            },
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: const Text("Cancelar"),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _seleccionarEstado(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text("Selecciona un Estado"),
        actions: estados.map((estado) {
          return CupertinoActionSheetAction(
            child: Text(estado),
            onPressed: () {
              setState(() => _estado = estado);
              Navigator.pop(context);
            },
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: const Text("Cancelar"),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Registrar Empleado'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información de Empleado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
                const SizedBox(height: 16),
                InputField(placeholder: 'Nombre', controller: nombreController, label: '',),
                const SizedBox(height: 10),
                InputField(placeholder: 'Apellido', controller: apellidoController, label: '',),
                const SizedBox(height: 10),
                InputField(placeholder: 'Cédula', controller: cedulaController, label: '',),
                const SizedBox(height: 10),
                CupertinoButton(
                  color: CupertinoColors.systemGrey4,
                  child: Text(_cargo),
                  onPressed: () => _seleccionarCargo(context),
                ),
                const SizedBox(height: 10),
                DatePickerField(
                  label: 'Fecha de Contratación',
                  selectedDate: fechaContratacion,
                  onDateSelected: (date) => setState(() => fechaContratacion = date),
                ),
                const SizedBox(height: 10),
                InputField(placeholder: 'Teléfono', controller: telefonoController, keyboardType: TextInputType.phone, label: '',),
                const SizedBox(height: 10),
                InputField(placeholder: 'Correo Electrónico', controller: correoController, keyboardType: TextInputType.emailAddress, label: '',),
                const SizedBox(height: 10),
                CupertinoButton(
                  color: CupertinoColors.systemGrey4,
                  child: Text(_estado),
                  onPressed: () => _seleccionarEstado(context),
                ),
                
                const SizedBox(height: 24),
                const Text(
                  'Información de Acceso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
                const SizedBox(height: 16),
                InputField(
                  placeholder: 'Contraseña', 
                  controller: contrasenaController, 
                  obscureText: true,
                  label: '',
                ),
                const SizedBox(height: 10),
                InputField(
                  placeholder: 'Confirmar Contraseña', 
                  controller: confirmarContrasenaController, 
                  obscureText: true,
                  label: '',
                ),
                
                const SizedBox(height: 24),
                SubmitButton(text: 'Guardar Empleado y Crear Usuario', onPressed: guardarEmpleado),
              ],
            ),
          ),
        ),
      ),
    );
  }
}