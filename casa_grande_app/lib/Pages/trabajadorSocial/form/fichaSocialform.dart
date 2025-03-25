import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Models/FichaSocial.model.dart';
import '../../../Services/FichaSocial.service.dart';

class FichaSocialForm extends StatefulWidget {
  final String idPaciente;

  const FichaSocialForm({Key? key, required this.idPaciente}) : super(key: key);

  @override
  _FichaSocialFormState createState() => _FichaSocialFormState();
}

class _FichaSocialFormState extends State<FichaSocialForm> {
  final _formKey = GlobalKey<FormState>();
  final FichaSocialService _fichaSocialService = FichaSocialService(); // Instancia del servicio

  bool ocupaTiempoLibre = false;
  String? actividadesTiempoLibre;
  bool perteneceAsociacion = false;
  String? nombreOrganizacion;
  String? frecuenciaAcudeAsociacion;
  String? actividadAsociacion;

  bool recibePension = false;
  String? tipoPension;
  bool tieneOtrosIngresos = false;
  double? montoOtrosIngresos;
  String? fuenteIngresos;
  String? quienCobraIngresos;
  String? destinoRecursos;

  String? tipoVivienda;
  String? accesoVivienda;

  bool seAlimentaBien = false;
  int? numeroComidasDiarias;
  String? especificarComidas;

  String? estadoSalud;
  bool enfermedadCatastrofica = false;
  String? especificarEnfermedad;
  bool discapacidad = false;
  bool tomaMedicamentoConstante = false;
  String? especificarMedicamento;
  bool utilizaAyudaTecnica = false;
  String? especificarAyudaTecnica;

  bool deseaServicioResidencial = false;
  bool deseaServicioDiurno = false;
  bool deseaEspaciosSocializacion = false;
  bool deseaAtencionDomiciliaria = false;

  Future<void> _guardarFichaSocial() async {
    if (_formKey.currentState!.validate()) {
      // Crear un objeto FichaSocial con los datos del formulario
      final fichaSocial = FichaSocial(
        idPaciente: widget.idPaciente,
        ocupaTiempoLibre: ocupaTiempoLibre,
        actividadesTiempoLibre: actividadesTiempoLibre,
        perteneceAsociacion: perteneceAsociacion,
        nombreOrganizacion: nombreOrganizacion,
        frecuenciaAcudeAsociacion: frecuenciaAcudeAsociacion,
        actividadAsociacion: actividadAsociacion,
        recibePension: recibePension,
        tipoPension: tipoPension,
        tieneOtrosIngresos: tieneOtrosIngresos,
        montoOtrosIngresos: montoOtrosIngresos,
        fuenteIngresos: fuenteIngresos,
        quienCobraIngresos: quienCobraIngresos,
        destinoRecursos: destinoRecursos,
        tipoVivienda: tipoVivienda,
        accesoVivienda: accesoVivienda,
        seAlimentaBien: seAlimentaBien,
        numeroComidasDiarias: numeroComidasDiarias,
        especificarComidas: especificarComidas,
        estadoSalud: estadoSalud,
        enfermedadCatastrofica: enfermedadCatastrofica,
        especificarEnfermedad: especificarEnfermedad,
        discapacidad: discapacidad,
        tomaMedicamentoConstante: tomaMedicamentoConstante,
        especificarMedicamento: especificarMedicamento,
        utilizaAyudaTecnica: utilizaAyudaTecnica,
        especificarAyudaTecnica: especificarAyudaTecnica,
        deseaServicioResidencial: deseaServicioResidencial,
        deseaServicioDiurno: deseaServicioDiurno,
        deseaEspaciosSocializacion: deseaEspaciosSocializacion,
        deseaAtencionDomiciliaria: deseaAtencionDomiciliaria,
      );

      try {
        // Guardar la ficha social en Firestore
        await _fichaSocialService.addFichaSocial(fichaSocial);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ficha Social guardada correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la Ficha Social: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ficha Social - Paciente ${widget.idPaciente}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CheckboxListTile(
                  title: const Text('Ocupa su tiempo libre en actividades?'),
                  value: ocupaTiempoLibre,
                  onChanged: (value) {
                    setState(() {
                      ocupaTiempoLibre = value!;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Actividades en tiempo libre'),
                  onChanged: (value) => actividadesTiempoLibre = value,
                ),
                CheckboxListTile(
                  title: const Text('Pertenece a una asociación?'),
                  value: perteneceAsociacion,
                  onChanged: (value) {
                    setState(() {
                      perteneceAsociacion = value!;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nombre de la organización'),
                  onChanged: (value) => nombreOrganizacion = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Frecuencia de asistencia'),
                  onChanged: (value) => frecuenciaAcudeAsociacion = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Actividad en la asociación'),
                  onChanged: (value) => actividadAsociacion = value,
                ),
                
                CheckboxListTile(
                  title: const Text('Recibe pensión?'),
                  value: recibePension,
                  onChanged: (value) {
                    setState(() {
                      recibePension = value!;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tipo de pensión'),
                  onChanged: (value) => tipoPension = value,
                ),
                CheckboxListTile(
                  title: const Text('Tiene otros ingresos?'),
                  value: tieneOtrosIngresos,
                  onChanged: (value) {
                    setState(() {
                      tieneOtrosIngresos = value!;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Monto de otros ingresos'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => montoOtrosIngresos = double.tryParse(value),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Fuente de ingresos'),
                  onChanged: (value) => fuenteIngresos = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quién cobra los ingresos?'),
                  onChanged: (value) => quienCobraIngresos = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Destino de los recursos'),
                  onChanged: (value) => destinoRecursos = value,
                ),
                
                ElevatedButton(
                  onPressed: _guardarFichaSocial, // Llamar al método aquí
                  child: const Text('Guardar Ficha Social'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}