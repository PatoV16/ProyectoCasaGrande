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
    _loadKardexData();
  }

  void _loadKardexData() {
    _kardexFuture = _kardexService.getKardexByPaciente(widget.idPaciente);
  }

  void _navegarANuevaFicha() {
    Navigator.pushNamed(
      context,
      '/NuevaFichaKardex',
      arguments: widget.idPaciente,
    ).then((_) {
      // Recargar los datos cuando regrese de la pantalla de nueva ficha
      setState(() {
        _loadKardexData();
      });
    });
  }

  void _navegarADetalleFicha(KardexGerontologico kardex) {
    Navigator.pushNamed(
      context,
      '/DetalleFichaKardex',
      arguments: kardex,
    ).then((_) {
      // Recargar los datos cuando regrese del detalle
      setState(() {
        _loadKardexData();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fichas de Medicación'),
        elevation: 2,
      ),
      body: FutureBuilder<List<KardexGerontologico>>(
        future: _kardexFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar las fichas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _loadKardexData();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final kardexList = snapshot.data ?? [];

          if (kardexList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_information_outlined, 
                       size: 70, 
                       color: Theme.of(context).primaryColor.withOpacity(0.7)),
                  const SizedBox(height: 16),
                  Text(
                    'No hay fichas registradas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _navegarANuevaFicha,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear nueva ficha'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: kardexList.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final kardex = kardexList[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.medical_information, color: Colors.white),
                  ),
                  title: Text(
                    'Ficha #${kardex.idPaciente}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: kardex.fechaCreacion != null 
                      ? Text('Creada: ${_formatDate(kardex.fechaCreacion!)}')
                      : null,
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _navegarADetalleFicha(kardex),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 4),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarANuevaFicha,
        child: const Icon(Icons.add),
        tooltip: 'Agregar nueva ficha',
        elevation: 4,
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}