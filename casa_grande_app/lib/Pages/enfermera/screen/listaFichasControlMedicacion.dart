import 'package:casa_grande_app/Services/Kardex.service.dart';
import 'package:flutter/material.dart';
import 'package:casa_grande_app/Models/Kardex.model.dart';

class ListaFichasKardex extends StatefulWidget {
  final String idPaciente;

  const ListaFichasKardex({Key? key, required this.idPaciente}) : super(key: key);

  @override
  State<ListaFichasKardex> createState() => _ListaFichasKardexState();
}

class _ListaFichasKardexState extends State<ListaFichasKardex> {
  final KardexGerontologicoService _kardexService = KardexGerontologicoService();
  late Future<List<KardexGerontologico>> _kardexFuture;

  @override
  void initState() {
    super.initState();
    _kardexFuture = _kardexService.getKardexByPaciente(widget.idPaciente);
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fichas de Medicación'),
      ),
      body: FutureBuilder<List<KardexGerontologico>>(
        future: _kardexFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar las fichas.'));
          }

          final kardexList = snapshot.data ?? [];

          if (kardexList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No hay fichas registradas.'),
                  const SizedBox(height: 20),
                  
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: kardexList.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final kardex = kardexList[index];
              return ListTile(
                title: Text('Ficha #${kardex.idPaciente}'),
                
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/DetalleFichaKardex',
                    arguments: kardex,
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const Divider(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:()=>{
             Navigator.pushNamed(
      context,
      '/NuevaFichaKardex',
      arguments: widget.idPaciente,
    )
        },
        child: const Icon(Icons.add),
        tooltip: 'Agregar nueva ficha',
      ),
    );
  }
}
