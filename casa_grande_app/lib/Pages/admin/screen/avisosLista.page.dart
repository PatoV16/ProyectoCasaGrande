import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../Services/Avisos.service.dart';
class ListaAvisosScreen extends StatelessWidget {
  final AvisoService _avisoService = AvisoService();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            tooltip: 'Limpiar avisos expirados',
            onPressed: () async {
              try {
                await _avisoService.limpiarAvisosExpirados();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Avisos expirados eliminados'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Aviso>>(
        stream: _avisoService.getAvisosActivos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          
          final avisos = snapshot.data ?? [];
          
          if (avisos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.announcement_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay avisos activos',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: avisos.length,
            itemBuilder: (context, index) {
              final aviso = avisos[index];
              final esUrgente = aviso.esUrgente ?? false;
              final fechaExpiracion = aviso.fechaExpiracion != null
                  ? DateFormat('dd/MM/yyyy').format(aviso.fechaExpiracion!)
                  : 'Sin fecha';
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: esUrgente
                      ? const BorderSide(color: Colors.red, width: 2)
                      : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleAvisoScreen(aviso: aviso),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                aviso.titulo ?? 'Sin título',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: esUrgente ? Colors.red : Colors.black,
                                ),
                              ),
                            ),
                            if (esUrgente)
                              const Icon(Icons.priority_high, color: Colors.red),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          aviso.descripcion ?? 'Sin descripción',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Expira: $fechaExpiracion',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Autor: ${aviso.autor ?? 'Desconocido'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CrearAvisoScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Estas clases se necesitan para completar el código, pero no estaban en el original
// Deberás implementarlas según tu estructura de datos

class Aviso {
  final String? id;
  final String? titulo;
  final String? descripcion;
  final String? autor;
  final DateTime? fechaCreacion;
  final DateTime? fechaExpiracion;
  final bool? esUrgente;

  Aviso({
    this.id,
    this.titulo,
    this.descripcion,
    this.autor,
    this.fechaCreacion,
    this.fechaExpiracion,
    this.esUrgente,
  });
}

class AvisoService {
  Stream<List<Aviso>> getAvisosActivos() {
    // Implementar según tu base de datos
    throw UnimplementedError();
  }

  Future<void> limpiarAvisosExpirados() async {
    // Implementar según tu base de datos
    throw UnimplementedError();
  }
}

class DetalleAvisoScreen extends StatelessWidget {
  final Aviso aviso;

  const DetalleAvisoScreen({Key? key, required this.aviso}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementar pantalla de detalle
    return Scaffold(
      appBar: AppBar(
        title: Text(aviso.titulo ?? 'Detalle de aviso'),
      ),
      body: Center(
        child: Text('Implementar pantalla de detalle'),
      ),
    );
  }
}

class CrearAvisoScreen extends StatelessWidget {
  const CrearAvisoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementar pantalla de creación
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear aviso'),
      ),
      body: Center(
        child: Text('Implementar pantalla de creación'),
      ),
    );
  }
}