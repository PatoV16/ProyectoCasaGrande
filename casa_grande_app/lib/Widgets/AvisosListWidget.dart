import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/Avisoos.model.dart';
import '../Services/Avisos.service.dart';

class AvisosListWidget extends StatelessWidget {
  final AvisoService _avisoService = AvisoService();
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  AvisosListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Avisos Activos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemBlue,
            ),
          ),
        ),
        Container(
          height: 400,
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.systemGrey4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FutureBuilder<List<Aviso>>(
            future: _avisoService. obtenerTodosLosAvisos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error al cargar avisos: ${snapshot.error}',
                    style: const TextStyle(color: CupertinoColors.systemRed),
                  ),
                );
              }

              final avisos = snapshot.data ?? [];

              if (avisos.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay avisos disponibles',
                    style: TextStyle(color: CupertinoColors.systemGrey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: avisos.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final aviso = avisos[index];
                  final ahora = DateTime.now();
                  final diasRestantes = aviso.fechaExpiracion.difference(ahora).inDays;
                  final bool estaProximoAVencer = diasRestantes <= 3;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: estaProximoAVencer
                          ? Border.all(color: CupertinoColors.systemOrange, width: 1.5)
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (aviso.imagenUrl != null)
                            Container(
                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(aviso.imagenUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(diasRestantes),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    diasRestantes <= 0
                                        ? 'Vence hoy'
                                        : '$diasRestantes días',
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        aviso.titulo,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: CupertinoColors.systemBlue,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (aviso.imagenUrl == null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(diasRestantes),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          diasRestantes <= 0
                                              ? 'Vence hoy'
                                              : '$diasRestantes días',
                                          style: const TextStyle(
                                            color: CupertinoColors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  aviso.descripcion,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Creado: ${dateFormat.format(aviso.fechaCreacion)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: CupertinoColors.systemGrey2,
                                      ),
                                    ),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      child: const Text('Ver detalles'),
                                      onPressed: () {
                                        _mostrarDetalleAviso(context, aviso);
                                      },
                                    ),
                                  ],
                                ),
                              ],
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
        ),
      ],
    );
  }

  Color _getStatusColor(int diasRestantes) {
    if (diasRestantes <= 0) {
      return CupertinoColors.systemRed;
    } else if (diasRestantes <= 3) {
      return CupertinoColors.systemOrange;
    } else {
      return CupertinoColors.systemGreen;
    }
  }

  void _mostrarDetalleAviso(BuildContext context, Aviso aviso) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(aviso.titulo),
        message: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (aviso.imagenUrl != null)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(aviso.imagenUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Text(
              aviso.descripcion,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Creado: ${dateFormat.format(aviso.fechaCreacion)}',
              style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
            ),
            Text(
              'Expira: ${dateFormat.format(aviso.fechaExpiracion)}',
              style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
            ),
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              // Confirmación para eliminar
              await _confirmarEliminarAviso(context, aviso);
            },
            isDestructiveAction: true,
            child: const Text('Eliminar aviso'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ),
    );
  }

  Future<void> _confirmarEliminarAviso(BuildContext context, Aviso aviso) async {
    final shouldDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Eliminar aviso'),
        content: const Text('¿Estás seguro que deseas eliminar este aviso? Esta acción no se puede deshacer.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, true),
            isDestructiveAction: true,
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _avisoService.eliminarAviso(aviso.id);
        // No necesitamos actualizar la UI manualmente porque estamos usando StreamBuilder
      } catch (e) {
        // Mostrar error
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('No se pudo eliminar el aviso: $e'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    }
  }
}