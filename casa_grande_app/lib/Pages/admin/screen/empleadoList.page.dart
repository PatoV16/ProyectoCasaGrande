import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Models/Empleado.model.dart';
import '../../../Services/Empleado.service.dart';
import '../../../Widgets/empleado_card.dart'; // Suponiendo que tienes un widget reutilizable para mostrar un empleado

class EmpleadoListScreen extends StatefulWidget {
  const EmpleadoListScreen({Key? key}) : super(key: key);

  @override
  _EmpleadoListScreenState createState() => _EmpleadoListScreenState();
}

class _EmpleadoListScreenState extends State<EmpleadoListScreen> {
  final EmpleadoService empleadoService = EmpleadoService();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Lista de Empleados'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<List<Empleado>>(
            stream: empleadoService.getEmpleados(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay empleados registrados'));
              } else {
                // Lista de empleados
                final empleados = snapshot.data!;
                return ListView.builder(
                  itemCount: empleados.length,
                  itemBuilder: (context, index) {
                    final empleado = empleados[index];
                    return EmpleadoCard(empleado: empleado); // Este es el widget reutilizable
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
