import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:casa_grande_app/Models/Empleado.model.dart';
import 'package:casa_grande_app/Services/Empleado.service.dart';

class EditarEmpleadoScreen extends StatefulWidget {
  Empleado? empleado; // Cambiado a nullable
  final String idEmpleado;
  
  EditarEmpleadoScreen({Key? key, required this.idEmpleado}) : super(key: key);

  @override
  _EditarEmpleadoScreenState createState() => _EditarEmpleadoScreenState();
}

class _EditarEmpleadoScreenState extends State<EditarEmpleadoScreen> {
  final _formKey = GlobalKey<FormState>();
  final EmpleadoService _empleadoService = EmpleadoService();
  bool _isLoading = true;

  // Inicializar los controladores con valores vacíos
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  String _estado = 'Activo'; // Valor predeterminado
  DateTime? _fechaContratacion;

  @override
  void initState() {
    super.initState();
    _cargarEmpleado();
  }

  Future<void> _cargarEmpleado() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      Empleado? empleado = await _empleadoService.obtenerEmpleadoPorCedula(widget.idEmpleado);
      if (empleado != null) {
        setState(() {
          widget.empleado = empleado;
          // Actualizar los controladores con los datos del empleado
          _nombreController.text = empleado.nombre;
          _apellidoController.text = empleado.apellido;
          _telefonoController.text = empleado.telefono;
          _cedulaController.text = empleado.cedula;
          _cargoController.text = empleado.cargo;
          _correoController.text = empleado.correo;
          _estado = empleado.estado;
          _fechaContratacion = empleado.fechaContratacion;
          _isLoading = false;
        });
      } else {
        // Manejar el caso donde no se encuentra el empleado
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró información del empleado')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error al cargar empleado: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar información: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _cedulaController.dispose();
    _cargoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

 Future<void> _guardarCambios() async {
  if (_formKey.currentState!.validate() && widget.empleado != null) {
    try {
      setState(() {
        _isLoading = true; // Mostrar indicador de carga mientras se actualiza
      });
      
      // Crear un nuevo objeto Empleado con los valores editados
      Empleado empleadoActualizado = Empleado(
        id: widget.empleado!.id,
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        cedula: widget.empleado!.cedula, // Mantener cédula original
        cargo: widget.empleado!.cargo, // Mantener cargo original
        fechaContratacion: _fechaContratacion,
        telefono: _telefonoController.text,
        correo: widget.empleado!.correo, // Mantener correo original
        estado: _estado,
      );

      // Actualizar el empleado en Firestore
      await _empleadoService.updateEmpleado(empleadoActualizado);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Empleado actualizado correctamente')),
        );
        Navigator.pop(context, true); // Retornar true para indicar éxito
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
        print('Error en _guardarCambios: $e');
      }
    }
  }
}

  Future<void> _seleccionarFecha() async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaContratacion ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (fechaSeleccionada != null && fechaSeleccionada != _fechaContratacion) {
      setState(() {
        _fechaContratacion = fechaSeleccionada;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Empleado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _guardarCambios,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campos editables
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _apellidoController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el apellido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo de cédula (no editable)
                  TextFormField(
                    controller: _cedulaController,
                    decoration: const InputDecoration(
                      labelText: 'Cédula',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                    enabled: false, // Deshabilitado para edición
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo de cargo (no editable)
                  TextFormField(
                    controller: _cargoController,
                    decoration: const InputDecoration(
                      labelText: 'Cargo',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                    enabled: false, // Deshabilitado para edición
                  ),
                  const SizedBox(height: 16),
                  
                  // Selector de fecha
                  InkWell(
                    onTap: _seleccionarFecha,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Contratación',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _fechaContratacion != null
                                ? DateFormat('dd/MM/yyyy').format(_fechaContratacion!)
                                : 'Seleccionar fecha',
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el teléfono';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo de correo (no editable)
                  TextFormField(
                    controller: _correoController,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                    enabled: false, // Deshabilitado para edición
                  ),
                  const SizedBox(height: 16),
                  
                  // Selector de estado
                  DropdownButtonFormField<String>(
                    value: _estado,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                      DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                      DropdownMenuItem(value: 'Suspendido', child: Text('Suspendido')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _estado = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor seleccione un estado';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
      bottomNavigationBar: _isLoading
        ? null
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _guardarCambios,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('GUARDAR CAMBIOS'),
            ),
          ),
    );
  }
}