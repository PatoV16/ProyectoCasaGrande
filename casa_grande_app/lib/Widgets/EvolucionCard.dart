import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'FormularioEvolucion.dart'; // Importar el formulario de evolución
import '../Models/Paciente.model.dart'; // Importar el modelo de Paciente

class EvolucionScreen extends StatefulWidget {
  @override
  _ListaPacientesScreenState createState() => _ListaPacientesScreenState();
}

class _ListaPacientesScreenState extends State<EvolucionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Paciente> _pacientes = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarPacientes();
  }

  Future<void> _cargarPacientes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Obtener la colección de pacientes desde Firestore
      QuerySnapshot pacientesSnapshot = await _firestore.collection('pacientes').get();
      
      setState(() {
        _pacientes = pacientesSnapshot.docs
            .map((doc) {
              // Convertir los datos del documento a un Map
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              // Añadir el ID del documento a los datos
              data['id'] = doc.id;
              // Crear instancia de Paciente
              return Paciente.fromJson(data);
            })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar pacientes: $e';
        _isLoading = false;
      });
    }
  }

  void _navegarAFormularioEvolucion(String idPaciente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioEvolucion(idPaciente: idPaciente),
      ),
    ).then((_) {
      // Recargar la lista después de regresar del formulario
      _cargarPacientes();
    });
  }

  String _calcularEdad(DateTime fechaNacimiento) {
    DateTime ahora = DateTime.now();
    int edad = ahora.year - fechaNacimiento.year;
    if (ahora.month < fechaNacimiento.month || 
        (ahora.month == fechaNacimiento.month && ahora.day < fechaNacimiento.day)) {
      edad--;
    }
    return '$edad años';
  }

  String _formatearFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Pacientes'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarPacientes,
          ),
        ],
      ),
      body: _buildBody(),
      
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarPacientes,
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_pacientes.isEmpty) {
      return Center(child: Text('No hay pacientes registrados'));
    }

    return ListView.builder(
      itemCount: _pacientes.length,
      itemBuilder: (context, index) {
        final paciente = _pacientes[index];
        
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                paciente.nombre.isNotEmpty 
                    ? paciente.nombre.substring(0, 1).toUpperCase() 
                    : 'P',
              ),
            ),
            title: Text('${paciente.nombre} ${paciente.apellido}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CI: ${paciente.cedula}'),
                Text('Edad: ${_calcularEdad(paciente.fechaNacimiento)}'),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.note_add, color: Colors.blue),
              onPressed: () => _navegarAFormularioEvolucion(paciente.id.toString()),
              tooltip: 'Agregar Evolución',
            ),
            onTap: () {
              // Navegar a detalles del paciente
              _mostrarDetallesPaciente(paciente);
            },
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _mostrarDetallesPaciente(Paciente paciente) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${paciente.nombre} ${paciente.apellido}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Divider(),
              SizedBox(height: 8),
              _buildInfoRow('Cédula', paciente.cedula),
              _buildInfoRow('Fecha de Nacimiento', _formatearFecha(paciente.fechaNacimiento)),
              _buildInfoRow('Edad', _calcularEdad(paciente.fechaNacimiento)),
              _buildInfoRow('Estado Civil', paciente.estadoCivil),
              _buildInfoRow('Nivel de Instrucción', paciente.nivelInstruccion),
              _buildInfoRow('Profesión/Ocupación', paciente.profesionOcupacion),
              _buildInfoRow('Teléfono', paciente.telefono),
              _buildInfoRow('Dirección', paciente.direccion),
              _buildInfoRow('Fecha de Ingreso', _formatearFecha(paciente.fechaIngreso)),
              Divider(),
              SizedBox(height: 8),
              Text(
                'Últimas Evoluciones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Expanded(
                child: _buildEvolucionesPaciente(paciente.id.toString()),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navegarAFormularioEvolucion(paciente.id.toString()),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text('Agregar Evolución'),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolucionesPaciente(String idPaciente) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('evoluciones')
          .where('idPaciente', isEqualTo: idPaciente)
          .orderBy('fechaHora', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar evoluciones: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay evoluciones registradas'));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final evolucion = snapshot.data!.docs[index];
            final fechaHora = (evolucion['fechaHora'] as Timestamp).toDate();
            
            return Card(
              color: Colors.grey[100],
              margin: EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${evolucion['areaServicio']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${DateFormat('dd/MM/yyyy HH:mm').format(fechaHora)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${evolucion['evolucion']}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Aquí puedes implementar la lógica para ver el detalle completo
                            _mostrarDetalleEvolucion(evolucion);
                          },
                          child: Text('Ver detalle'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarDetalleEvolucion(DocumentSnapshot evolucion) {
    final data = evolucion.data() as Map<String, dynamic>;
    final fechaHora = (data['fechaHora'] as Timestamp).toDate();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalle de Evolución'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Fecha', DateFormat('dd/MM/yyyy').format(fechaHora)),
              _buildInfoRow('Hora', DateFormat('HH:mm').format(fechaHora)),
              _buildInfoRow('Área de Servicio', data['areaServicio']),
              _buildInfoRow('Tipo de Ficha', data['tipoFicha']),
              Divider(),
              SizedBox(height: 8),
              Text('Actividades:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              ...List<String>.from(data['actividades']).map(
                (actividad) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text('• $actividad'),
                ),
              ),
              SizedBox(height: 8),
              Text('Evolución:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(data['evolucion']),
              SizedBox(height: 8),
              Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(data['observaciones']),
              SizedBox(height: 8),
              Text('Recomendaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(data['recomendaciones']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}