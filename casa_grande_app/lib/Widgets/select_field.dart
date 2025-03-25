import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Models/Paciente.model.dart';
import '../Services/Paciente.service.dart';
class SelectField extends StatefulWidget {
  final ValueChanged<String?> onChanged;

  const SelectField({
    Key? key,
    required this.onChanged, required String label, required List<String> items,
  }) : super(key: key);

  @override
  _SelectFieldState createState() => _SelectFieldState();
}

class _SelectFieldState extends State<SelectField> {
  final PacienteService _pacienteService = PacienteService();
  String? _selectedCedula;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Paciente>>(
      // Usamos el Stream<List<Paciente>> directamente
      stream: _pacienteService.getPacientes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final pacientes = snapshot.data ?? [];

        return Material(
  child: DropdownButtonFormField<String>(
    value: _selectedCedula,
    onChanged: (String? newValue) {
      setState(() {
        _selectedCedula = newValue;
      });
      widget.onChanged(newValue);
    },
    items: pacientes.map<DropdownMenuItem<String>>((Paciente paciente) {
      return DropdownMenuItem<String>(
        value: paciente.cedula,
        child: Text(paciente.nombre),
      );
    }).toList(),
    decoration: InputDecoration(
      labelText: 'Seleccione un paciente',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
);

      },
    );
  }
}