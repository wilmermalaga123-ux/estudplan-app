import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/repositories/tarea_clinica_repository_impl.dart';
import '../../domain/models/tarea_clinica.dart';
import 'nueva_tarea_clinica_screen.dart';


class ClinicaScreen extends StatefulWidget {
  const ClinicaScreen({super.key});

  @override
  State<ClinicaScreen> createState() => _ClinicaScreenState();
}

class _ClinicaScreenState extends State<ClinicaScreen> {
  final TareaClinicaRepositoryImpl _repository = TareaClinicaRepositoryImpl();
  List<TareaClinica> _tareas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  Future<void> _cargarTareas() async {
    final tareas = await _repository.getTareasPendientes();
    setState(() {
      _tareas = tareas;
      _cargando = false;
    });
  }

  Future<void> _marcarCompletada(TareaClinica tarea) async {
    tarea.completada = true;
    await _repository.updateTarea(tarea);
    await _cargarTareas();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Tarea completada')),
      );
    }
  }

  Future<void> _eliminarTarea(TareaClinica tarea) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar "${tarea.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _repository.deleteTarea(tarea.id!);
      await _cargarTareas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑️ Tarea eliminada')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: _tareas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No hay tareas clínicas pendientes'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NuevaTareaClinicaScreen()),
                      );
                      if (result == true) await _cargarTareas();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crear primera tarea'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tareas.length,
              itemBuilder: (context, index) {
                final tarea = _tareas[index];
                return Card(
                  child: ListTile(
                    leading: _getIconoTarea(tarea),
                    title: Text(tarea.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tarea.descripcion != null) Text(tarea.descripcion!),
                        Text('📅 ${_formatFecha(tarea.fechaHoraLimite)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => _marcarCompletada(tarea),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarTarea(tarea),
                        ),
                      ],
                    ),
                    onTap: () => _mostrarDetalle(tarea),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NuevaTareaClinicaScreen()),
          );
          if (result == true) await _cargarTareas();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Icon _getIconoTarea(TareaClinica tarea) {
    switch (tarea.tipoAdjunto) {
      case TipoAdjunto.foto:
        return const Icon(Icons.camera_alt, color: Colors.blue);
      case TipoAdjunto.audio:
        return const Icon(Icons.mic, color: Colors.orange);
      case TipoAdjunto.fotoYAudio:
        return const Icon(Icons.photo_camera, color: Colors.purple);
      default:
        return const Icon(Icons.note, color: Colors.grey);
    }
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  void _mostrarDetalle(TareaClinica tarea) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tarea.titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (tarea.descripcion != null) Text(tarea.descripcion!),
            const SizedBox(height: 8),
            Text('📅 ${_formatFecha(tarea.fechaHoraLimite)}'),
            if (tarea.textoExtra != null) ...[
              const SizedBox(height: 8),
              Text('📝 ${tarea.textoExtra}'),
            ],
            if (tarea.rutaFoto != null) ...[
              const SizedBox(height: 12),
              Image.file(File(tarea.rutaFoto!), height: 200),
            ],
          ],
        ),
      ),
    );
  }
}