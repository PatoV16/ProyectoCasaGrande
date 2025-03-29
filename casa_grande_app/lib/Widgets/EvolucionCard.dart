import 'package:casa_grande_app/Models/Evolucion.model.dart';
import 'package:casa_grande_app/Services/Usuario.server.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'FormularioEvolucion.dart'; // Importar el formulario de evolución
import '../Models/Paciente.model.dart'; // Importar el modelo de Paciente
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

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
              onPressed: () => _navegarAFormularioEvolucion(paciente.cedula),
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
                child: _buildEvolucionesPaciente(paciente),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navegarAFormularioEvolucion(paciente.cedula),
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

  Widget _buildEvolucionesPaciente(Paciente paciente)  {
    return FutureBuilder<String?>(
  future: UserService().getUserCargo(),
  builder: (context, cargoSnapshot) {
    if (cargoSnapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    if (cargoSnapshot.hasError || !cargoSnapshot.hasData || cargoSnapshot.data == null) {
      return Center(child: Text('Error al obtener el cargo del usuario'));
    }

    String cargo = cargoSnapshot.data!; // Cargo del usuario obtenido
    print(cargo);
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
        .collection('evoluciones')
        .where('idPaciente', isEqualTo: paciente.cedula)
        .where('tipoFicha', isEqualTo: cargo) 
      .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

       if (snapshot.hasError) {
        print("Error en StreamBuilder: ${snapshot.error}");
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
    final evolucionDoc = snapshot.data!.docs[index];
    final fechaHora = (evolucionDoc['fechaHora'] as Timestamp).toDate();
    
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
                  evolucionDoc['areaServicio'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(fechaHora),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              evolucionDoc['evolucion'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _mostrarDetalleEvolucion(evolucionDoc, paciente); // Pasa el paciente aquí
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
  },
);

  }

 void _mostrarDetalleEvolucion(DocumentSnapshot evolucionDoc, Paciente paciente) {
  final evolucion = Evolucion.fromFirestore(evolucionDoc);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Detalle de Evolución'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow('Fecha', DateFormat('dd/MM/yyyy').format(evolucion.fechaHora)),
            _buildInfoRow('Hora', DateFormat('HH:mm').format(evolucion.fechaHora)),
            _buildInfoRow('Área de Servicio', evolucion.areaServicio),
            _buildInfoRow('Tipo de Ficha', evolucion.tipoFicha),
            Divider(),
            SizedBox(height: 8),
            Text('Actividades:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            ...evolucion.actividades.map(
              (actividad) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text('• $actividad'),
              ),
            ),
            SizedBox(height: 8),
            Text('Evolución:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(evolucion.evolucion),
            SizedBox(height: 8),
            Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(evolucion.observaciones),
            SizedBox(height: 8),
            Text('Recomendaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(evolucion.recomendaciones),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cerrar'),
        ),
        TextButton(
          onPressed: () => _imprimirEvolucion(evolucion, paciente),
          child: Text('Imprimir'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
        ),
      ],
    ),
  );
}

Future<void> _imprimirEvolucion(Evolucion evolucion, Paciente paciente) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Informe de Evolución', 
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text('Fecha: ${_formatDate(DateTime.now())}', 
                  style: pw.TextStyle(fontSize: 12)),
            ],
          ),
          pw.Divider(thickness: 1),
        ],
      ),
      build: (context) => [
        _buildPdfSection(
          title: 'Información del Paciente',
          children: [
            _buildPdfInfoRow('Nombre:', '${paciente.nombre} ${paciente.apellido}'),
            _buildPdfInfoRow('Cédula:', paciente.cedula),
            _buildPdfInfoRow('Edad:', _calcularEdad(paciente.fechaNacimiento)),
          ],
        ),
        
        _buildPdfSection(
          title: 'Detalles de la Evolución',
          children: [
            _buildPdfInfoRow('Fecha:', _formatDate(evolucion.fechaHora)),
            _buildPdfInfoRow('Hora:', DateFormat('HH:mm').format(evolucion.fechaHora)),
            _buildPdfInfoRow('Área de Servicio:', evolucion.areaServicio),
            _buildPdfInfoRow('Tipo de Ficha:', evolucion.tipoFicha),
          ],
        ),
        
        _buildPdfSection(
          title: 'Actividades Realizadas',
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: evolucion.actividades.map((actividad) => 
                pw.Text('• $actividad')
              ).toList(),
            ),
          ],
        ),
        
        _buildPdfSection(
          title: 'Evolución',
          children: [
            pw.Text(evolucion.evolucion, textAlign: pw.TextAlign.justify),
          ],
        ),
        
        _buildPdfSection(
          title: 'Observaciones',
          children: [
            pw.Text(evolucion.observaciones, textAlign: pw.TextAlign.justify),
          ],
        ),
        
        _buildPdfSection(
          title: 'Recomendaciones',
          children: [
            pw.Text(evolucion.recomendaciones, textAlign: pw.TextAlign.justify),
          ],
        ),
      ],
      footer: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text('Casa Grande - Informe de Evolución'),
          pw.Text(' | '),
          pw.Text('Página ${context.pageNumber} de ${context.pagesCount}'),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
    name: 'Evolucion_${paciente.cedula}_${DateFormat('yyyyMMdd').format(evolucion.fechaHora)}',
  );
}

// Función auxiliar para secciones en PDF
pw.Widget _buildPdfSection({required String title, required List<pw.Widget> children}) {
  return pw.Container(
    margin: pw.EdgeInsets.only(bottom: 16),
    padding: pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.deepPurple),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16, 
            fontWeight: pw.FontWeight.bold, 
            color: PdfColors.deepPurple
          ),
        ),
        pw.SizedBox(height: 8),
        ...children,
      ],
    ),
  );
}

// Función auxiliar para filas de información en PDF
pw.Widget _buildPdfInfoRow(String label, String value) {
  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: 8.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          child: pw.Text(value),
        ),
      ],
    ),
  );
}

String _formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}
}