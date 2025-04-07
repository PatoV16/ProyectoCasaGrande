import 'package:casa_grande_app/Services/Kardex.service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:casa_grande_app/Models/Kardex.model.dart';

class KardexGerontologicoForm extends StatefulWidget {
  final String idPaciente;

  const KardexGerontologicoForm({Key? key, required this.idPaciente}) : super(key: key);

  @override
  _KardexGerontologicoFormState createState() => _KardexGerontologicoFormState();
}

class _KardexGerontologicoFormState extends State<KardexGerontologicoForm> {
  final _formKey = GlobalKey<FormState>();
  final _medicamentoNombreController = TextEditingController();
  final _dosisController = TextEditingController();
  final _viaController = TextEditingController();
  final _frecuenciaController = TextEditingController();
  final _responsableController = TextEditingController();
  final _descripcionAlergiaController = TextEditingController();
  final _kardexService = KardexGerontologicoService();

  bool _isLoading = false;

  // Datos del formulario
  int _edad = 0;
  String _numeroHistoriaClinica = '';
  String _numeroArchivo = '';
  bool _tieneAlergia = false;
  DateTime _fechaMedicamento = DateTime.now();
  TimeOfDay _horaAdministracion = TimeOfDay.now();

  // Listas para almacenar datos
  List<Map<String, dynamic>> _medicamentos = [];
  List<Map<String, dynamic>> _administraciones = [];

  @override
  void dispose() {
    _medicamentoNombreController.dispose();
    _dosisController.dispose();
    _viaController.dispose();
    _frecuenciaController.dispose();
    _responsableController.dispose();
    _descripcionAlergiaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaMedicamento,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _fechaMedicamento) {
      setState(() => _fechaMedicamento = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaAdministracion,
    );

    if (picked != null && picked != _horaAdministracion) {
      setState(() => _horaAdministracion = picked);
    }
  }

  void _agregarAdministracion() {
    if (_responsableController.text.isEmpty) return;

    setState(() {
      _administraciones.add({
        'hora': _horaAdministracion.format(context),
        'responsable': _responsableController.text,
        'fechaRegistro': DateTime.now().millisecondsSinceEpoch,
      });
      _responsableController.clear();
    });
  }

  void _agregarMedicamento() {
    if (_medicamentoNombreController.text.isEmpty ||
        _dosisController.text.isEmpty ||
        _viaController.text.isEmpty ||
        _frecuenciaController.text.isEmpty) return;

    setState(() {
      _medicamentos.add({
        'nombre': _medicamentoNombreController.text,
        'fecha': DateFormat('yyyy-MM-dd').format(_fechaMedicamento),
        'dosis': _dosisController.text,
        'via': _viaController.text,
        'frecuencia': _frecuenciaController.text,
        'administraciones': List.from(_administraciones),
        'fechaRegistro': DateTime.now().millisecondsSinceEpoch,
      });

      // Limpiar campos
      _medicamentoNombreController.clear();
      _dosisController.clear();
      _viaController.clear();
      _frecuenciaController.clear();
      _administraciones.clear();
    });
  }

  void _eliminarMedicamento(int index) {
    setState(() {
      _medicamentos.removeAt(index);
    });
  }

  void _eliminarAdministracion(int index) {
    setState(() {
      _administraciones.removeAt(index);
    });
  }

  Future<void> _guardarKardex() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // Crear objeto KardexGerontologico
        final medicamentos = _medicamentos.map((med) => 
          Medicamento(
            nombre: med['nombre'],
            fecha: med['fecha'],
            dosis: med['dosis'],
            via: med['via'],
            frecuencia: med['frecuencia'],
            administraciones: (med['administraciones'] as List).map((admin) => 
              Administracion(
                hora: admin['hora'],
                responsable: admin['responsable'],
              )
            ).toList(),
          )
        ).toList();
        
        final kardex = KardexGerontologico(
          idPaciente: widget.idPaciente,
          edad: _edad,
          numeroHistoriaClinica: _numeroHistoriaClinica,
          numeroArchivo: _numeroArchivo,
          tieneAlergiaMedicamentos: _tieneAlergia,
          descripcionAlergia: _tieneAlergia ? _descripcionAlergiaController.text : null,
          medicamentos: medicamentos,
          fechaCreacion: DateTime.now(), id: '',
        );
        
        // Guardar usando el servicio
        final kardexId = await _kardexService.createKardex(kardex);
        
        // Mostrar mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kardex guardado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Mostrar diálogo de confirmación
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Kardex Guardado'),
              content: Text('El kardex se ha guardado correctamente con ID: $kardexId'),
              actions: [
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, kardexId); // Devolver ID a la pantalla anterior
                  },
                ),
              ],
            ),
          );
        }
      } catch (e) {
        // Mostrar mensaje de error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Kardex Gerontológico'),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.0,
                    ),
                  ),
                )
              : TextButton(
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                  onPressed: _guardarKardex,
                ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Sección A: Datos del paciente
              _buildSectionTitle('Datos del Paciente'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: widget.idPaciente,
                        decoration: const InputDecoration(
                          labelText: 'ID Paciente',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Edad',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _edad = int.tryParse(value) ?? 0,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingrese la edad';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'N° Historia Clínica',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => _numeroHistoriaClinica = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingrese el número';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'N° Archivo',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => _numeroArchivo = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingrese el número';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Alergias a medicamentos
              _buildSectionTitle('Alergia a Medicamentos'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('¿Tiene alergias a medicamentos?'),
                          const Spacer(),
                          Switch(
                            value: _tieneAlergia,
                            onChanged: (value) {
                              setState(() => _tieneAlergia = value);
                            },
                          ),
                        ],
                      ),
                      if (_tieneAlergia) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descripcionAlergiaController,
                          decoration: const InputDecoration(
                            labelText: 'Describa la alergia',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_tieneAlergia && (value == null || value.isEmpty)) {
                              return 'Describa la alergia';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Sección B: Medicamentos
              _buildSectionTitle('Administración de Medicamentos'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _medicamentoNombreController,
                        decoration: const InputDecoration(
                          labelText: 'Medicamento',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('dd/MM/yyyy').format(_fechaMedicamento)),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dosisController,
                        decoration: const InputDecoration(
                          labelText: 'Dosis',
                          hintText: 'Ej: 500mg',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _viaController,
                        decoration: const InputDecoration(
                          labelText: 'Vía',
                          hintText: 'Ej: Oral, Intravenosa',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _frecuenciaController,
                        decoration: const InputDecoration(
                          labelText: 'Frecuencia',
                          hintText: 'Ej: Cada 8 horas',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_box),
                        label: const Text('Agregar Administraciones'),
                        onPressed: _medicamentoNombreController.text.isEmpty
                            ? null
                            : () {
                                // Mostrar sección de administraciones
                                setState(() {});
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        child: const Text('Agregar Medicamento'),
                        onPressed: _agregarMedicamento,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Administraciones del medicamento actual
              if (_medicamentoNombreController.text.isNotEmpty)
                Card(
                  margin: const EdgeInsets.only(top: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Administraciones para ${_medicamentoNombreController.text}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => _selectTime(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Hora',
                              border: OutlineInputBorder(),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_horaAdministracion.format(context)),
                                const Icon(Icons.access_time),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _responsableController,
                          decoration: const InputDecoration(
                            labelText: 'Responsable',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Administración'),
                          onPressed: _agregarAdministracion,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        if (_administraciones.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const Text(
                            'Administraciones agregadas:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _administraciones.length,
                            itemBuilder: (context, index) {
                              final admin = _administraciones[index];
                              return ListTile(
                                title: Text(admin['hora']),
                                subtitle: Text(admin['responsable']),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _eliminarAdministracion(index),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              // Lista de medicamentos agregados
              if (_medicamentos.isNotEmpty) ...[
                _buildSectionTitle('Medicamentos Agregados'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _medicamentos.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final med = _medicamentos[index];
                            return ListTile(
                              title: Text(med['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fecha: ${med['fecha']}'),
                                  Text('${med['dosis']} - ${med['via']} - ${med['frecuencia']}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _eliminarMedicamento(index),
                              ),
                              isThreeLine: true,
                              onTap: () {
                                // Mostrar detalles del medicamento
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Container(
                                    padding: const EdgeInsets.all(16),
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Medicamento: ${med['nombre']}', 
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Divider(),
                                        Text('Fecha: ${med['fecha']}'),
                                        Text('Dosis: ${med['dosis']}'),
                                        Text('Vía: ${med['via']}'),
                                        Text('Frecuencia: ${med['frecuencia']}'),
                                        const SizedBox(height: 16),
                                        Text('Administraciones:', 
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if ((med['administraciones'] as List).isEmpty)
                                          const Text('No hay administraciones registradas')
                                        else
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: (med['administraciones'] as List).length,
                                            itemBuilder: (context, i) {
                                              final admin = (med['administraciones'] as List)[i];
                                              return Card(
                                                child: ListTile(
                                                  title: Text('${admin['hora']}'),
                                                  subtitle: Text('${admin['responsable']}'),
                                                ),
                                              );
                                            },
                                          ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            child: const Text('Cerrar'),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}