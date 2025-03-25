import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Models/Barthel.model.dart';
import '../../../Services/Barthel.service.dart';
import '../../../Widgets/submit_button.dart';

class BarthelForm extends StatefulWidget {
  final String idPaciente;

  const BarthelForm({Key? key, required this.idPaciente}) : super(key: key);

  @override
  _BarthelFormState createState() => _BarthelFormState();
}

class _BarthelFormState extends State<BarthelForm> {
  final BarthelService barthelService = BarthelService();
  final TextEditingController _observacionesController = TextEditingController();
  bool _isLoading = false;
  
  // Datos de la escala con nombres más descriptivos
  final Map<String, Map<String, dynamic>> escalaItems = {
    'comer': {
      'title': 'Alimentación',
      'value': 10,
      'options': [
        {'value': 0, 'label': 'Dependiente. Necesita ser alimentado'},
        {'value': 5, 'label': 'Necesita ayuda para cortar, extender mantequilla, etc.'},
        {'value': 10, 'label': 'Independiente. Capaz de comer por sí solo'}
      ]
    },
    'traslado': {
      'title': 'Traslado sillón/cama',
      'value': 15,
      'options': [
        {'value': 0, 'label': 'Dependiente. No mantiene equilibrio sentado'},
        {'value': 5, 'label': 'Necesita ayuda importante (persona fuerte o entrenada)'},
        {'value': 10, 'label': 'Necesita algo de ayuda (física o verbal)'},
        {'value': 15, 'label': 'Independiente. No precisa ayuda'}
      ]
    },
    'aseo_personal': {
      'title': 'Aseo personal',
      'value': 5,
      'options': [
        {'value': 0, 'label': 'Dependiente. Necesita ayuda'},
        {'value': 5, 'label': 'Independiente. Se lava cara, manos, dientes, etc.'}
      ]
    },
    'uso_retrete': {
      'title': 'Uso del retrete',
      'value': 10,
      'options': [
        {'value': 0, 'label': 'Dependiente. Incapaz de acceder o utilizarlo sin ayuda'},
        {'value': 5, 'label': 'Necesita alguna ayuda (física o verbal)'},
        {'value': 10, 'label': 'Independiente. Entra, sale y se asea sin ayuda'}
      ]
    },
    'banarse': {
      'title': 'Baño/ducha',
      'value': 5,
      'options': [
        {'value': 0, 'label': 'Dependiente. Necesita alguna ayuda'},
        {'value': 5, 'label': 'Independiente. Entra y sale solo del baño'}
      ]
    },
    'desplazarse': {
      'title': 'Desplazarse',
      'value': 15,
      'options': [
        {'value': 0, 'label': 'Inmóvil. No puede desplazarse'},
        {'value': 5, 'label': 'Independiente en silla de ruedas (50 metros)'},
        {'value': 10, 'label': 'Camina con ayuda de una persona (50 metros)'},
        {'value': 15, 'label': 'Independiente al menos 50 metros, con o sin bastón'}
      ]
    },
    'subir_escaleras': {
      'title': 'Subir/bajar escaleras',
      'value': 10,
      'options': [
        {'value': 0, 'label': 'Incapaz de subir escaleras'},
        {'value': 5, 'label': 'Necesita ayuda física o verbal'},
        {'value': 10, 'label': 'Independiente para subir y bajar'}
      ]
    },
    'vestirse': {
      'title': 'Vestirse/desvestirse',
      'value': 10,
      'options': [
        {'value': 0, 'label': 'Dependiente. No puede vestirse solo'},
        {'value': 5, 'label': 'Necesita ayuda, pero puede hacer la mitad solo'},
        {'value': 10, 'label': 'Independiente. Capaz de ponerse y quitarse la ropa'}
      ]
    },
    'control_heces': {
      'title': 'Control de heces',
      'value': 10,
      'options': [
        {'value': 0, 'label': 'Incontinente o necesita enemas'},
        {'value': 5, 'label': 'Accidente excepcional (1 por semana)'},
        {'value': 10, 'label': 'Continente. Control total'}
      ]
    },
    'control_orina': {
      'title': 'Control de orina',
      'value': 10,
      'options': [
        {'value': 0, 'label': 'Incontinente o sonda incapaz de cambiarse bolsa'},
        {'value': 5, 'label': 'Accidente excepcional (1 por día)'},
        {'value': 10, 'label': 'Continente. Control completo'}
      ]
    },
  };
  
  bool usaSillaRuedas = false;
  DateTime fechaEvaluacion = DateTime.now();

  int calcularPuntajeTotal() {
    int total = escalaItems.values.fold(0, (prev, item) => prev + item['value'] as int);
    return usaSillaRuedas ? total.clamp(0, 90) : total;
  }

  String obtenerGradoDependencia() {
    int puntaje = calcularPuntajeTotal();
    if (puntaje < 21) return "Dependencia total";
    if (puntaje < 61) return "Dependencia severa";
    if (puntaje < 91) return "Dependencia moderada";
    if (puntaje < 100) return "Dependencia leve";
    return "Independencia";
  }

  Color obtenerColorDependencia() {
    int puntaje = calcularPuntajeTotal();
    if (puntaje < 21) return Colors.red;
    if (puntaje < 61) return Colors.orange;
    if (puntaje < 91) return Colors.amber;
    if (puntaje < 100) return Colors.lightGreen;
    return Colors.green;
  }

  void guardarBarthel() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Barthel nuevaBarthel = Barthel(
        idPaciente: widget.idPaciente,
        comer: escalaItems['comer']!['value'],
        traslado: escalaItems['traslado']!['value'],
        aseoPersonal: escalaItems['aseo_personal']!['value'],
        usoRetrete: escalaItems['uso_retrete']!['value'],
        banarse: escalaItems['banarse']!['value'],
        desplazarse: escalaItems['desplazarse']!['value'],
        subirEscaleras: escalaItems['subir_escaleras']!['value'],
        vestirse: escalaItems['vestirse']!['value'],
        controlHeces: escalaItems['control_heces']!['value'],
        controlOrina: escalaItems['control_orina']!['value'],
        puntajeTotal: calcularPuntajeTotal(),
        fechaEvaluacion: fechaEvaluacion,
        observaciones: _observacionesController.text,
      );

      await barthelService.addBarthel(nuevaBarthel);
      
      mostrarMensaje('Escala de Barthel guardada correctamente');
    } catch (e) {
      mostrarMensaje('Error al guardar: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void mostrarMensaje(String mensaje) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Información"),
        content: Text(mensaje),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              if (mensaje.contains('correctamente')) {
                Navigator.pop(context); // Volver a la pantalla anterior
              }
            },
          ),
        ],
      ),
    );
  }

  void seleccionarValor(String key) {
    final opciones = escalaItems[key]!['options'] as List;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              escalaItems[key]!['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: opciones.length,
                itemBuilder: (context, index) {
                  final opcion = opciones[index];
                  return ListTile(
                    title: Text("${opcion['value']} puntos"),
                    subtitle: Text(opcion['label']),
                    selected: escalaItems[key]!['value'] == opcion['value'],
                    selectedTileColor: Colors.blue.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        escalaItems[key]!['value'] = opcion['value'];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaEvaluacion,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != fechaEvaluacion) {
      setState(() {
        fechaEvaluacion = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final puntajeTotal = calcularPuntajeTotal();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Escala de Barthel'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Resumen puntaje
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: obtenerColorDependencia().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Resultado actual:",
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            "$puntajeTotal puntos",
                            style: const TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            obtenerGradoDependencia(),
                            style: TextStyle(
                              fontSize: 16,
                              color: obtenerColorDependencia(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Interpretación"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("• < 20: Dependencia total"),
                                  Text("• 21-60: Dependencia severa"),
                                  Text("• 61-90: Dependencia moderada"),
                                  Text("• 91-99: Dependencia leve"),
                                  Text("• 100: Independencia"),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: const Text("Cerrar"),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Lista de ítems
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Fecha de evaluación
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Fecha de evaluación:"),
                              Text(
                                "${fechaEvaluacion.day}/${fechaEvaluacion.month}/${fechaEvaluacion.year}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Silla de ruedas
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("¿Usa silla de ruedas?"),
                            Switch(
                              value: usaSillaRuedas,
                              activeColor: Colors.blue,
                              onChanged: (value) {
                                setState(() {
                                  usaSillaRuedas = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Ítems de la escala
                      ...escalaItems.entries.map((entry) {
                        final key = entry.key;
                        final item = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, 
                              vertical: 8
                            ),
                            title: Text(
                              item['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              (item['options'] as List).firstWhere(
                                (opt) => opt['value'] == item['value'], 
                                orElse: () => {'label': 'No seleccionado'}
                              )['label'],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, 
                                    vertical: 4
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${item['value']}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            onTap: () => seleccionarValor(key),
                          ),
                        );
                      }).toList(),
                      
                      const SizedBox(height: 16),
                      
                      // Observaciones
                      TextField(
                        controller: _observacionesController,
                        decoration: const InputDecoration(
                          labelText: 'Observaciones',
                          border: OutlineInputBorder(),
                          hintText: 'Ingrese observaciones adicionales',
                        ),
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : guardarBarthel,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'GUARDAR EVALUACIÓN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}