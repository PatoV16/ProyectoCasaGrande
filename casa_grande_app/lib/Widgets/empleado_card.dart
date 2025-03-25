import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Models/Empleado.model.dart';

class EmpleadoCard extends StatelessWidget {
  final Empleado empleado;

  const EmpleadoCard({Key? key, required this.empleado}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${empleado.nombre} ${empleado.apellido}'),
        subtitle: Text('Cargo: ${empleado.cargo}\nEstado: ${empleado.estado}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            // Aquí puedes implementar la eliminación de empleados
            // empleadoService.deleteEmpleado(empleado.id);
          },
        ),
        onTap: () {
          Navigator.pushNamed(context, '/EditarEmpleado', arguments: empleado.cedula);
        },
      ),
    );
  }
}
