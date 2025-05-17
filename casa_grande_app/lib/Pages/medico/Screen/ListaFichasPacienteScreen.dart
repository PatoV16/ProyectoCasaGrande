import 'package:casa_grande_app/Models/FichaMedica.model.dart';
import 'package:casa_grande_app/Pages/medico/Screen/fichaMedicaScreen.dart';
import 'package:casa_grande_app/Services/FichaMedica.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class ListaFichasPacienteScreen extends StatefulWidget {
  final String cedulaPaciente;

  const ListaFichasPacienteScreen({Key? key, required this.cedulaPaciente}) : super(key: key);

  @override
  _ListaFichasPacienteScreenState createState() => _ListaFichasPacienteScreenState();
}

class _ListaFichasPacienteScreenState extends State<ListaFichasPacienteScreen> {
  final fichaService = FichaMedicaService();
  late Future<List<FichaMedica>> fichas;

  @override
  void initState() {
    super.initState();
    fichas = fichaService.getFichaMedicaByPacienteCedula(widget.cedulaPaciente).then((ficha) {
      if (ficha == null) {
        return <FichaMedica>[];
      } else {
        return <FichaMedica>[ficha];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Fichas del Paciente'),
      ),
      child: SafeArea(
        child: FutureBuilder<List<FichaMedica>>(
          future: fichas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay fichas registradas.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final ficha = snapshot.data![index];
                return CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                     Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => FichaMedicaDetalleScreen(idPaciente: ficha.idPaciente)),
  );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ficha #${ficha.idFichaMedica}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 6),
                         
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
