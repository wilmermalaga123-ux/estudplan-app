import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/camera_service.dart';
import '../../services/notification_service.dart';
import '../../data/repositories/tarea_clinica_repository_impl.dart';
import '../../domain/models/tarea_clinica.dart';

class NuevaTareaClinicaScreen extends StatefulWidget {
  const NuevaTareaClinicaScreen({super.key});

  @override
  State<NuevaTareaClinicaScreen> createState() => _NuevaTareaClinicaScreenState();
}

class _NuevaTareaClinicaScreenState extends State<NuevaTareaClinicaScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _textoExtraController = TextEditingController();
  DateTime _fechaHora = DateTime.now().add(const Duration(hours: 1));
  TipoAdjunto _tipoAdjunto = TipoAdjunto.soloTexto;
  String? _rutaFoto;
  final CameraService _camera = CameraService();
  final _repository = TareaClinicaRepositoryImpl();

  Future<void> _seleccionarFechaHora() async {
    final fecha = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (fecha != null) {
      final hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (hora != null) {
        setState(() {
          _fechaHora = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
        });
      }
    }
  }

  Future<void> _tomarFoto() async {
    final ruta = await _camera.tomarFotoYGuardar();
    if (ruta != null) {
      setState(() {
        _rutaFoto = ruta;
        _tipoAdjunto = TipoAdjunto.foto;
      });
    }
  }

  Future<void> _guardar() async {
    // Validar título
    if (_tituloController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
      return;
    }

    // Validar que la fecha no sea en el pasado
    if (_fechaHora.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha no puede ser en el pasado')),
      );
      return;
    }

    final tarea = TareaClinica(
      titulo: _tituloController.text,
      descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
      fechaHoraLimite: _fechaHora,
      tipoAdjunto: _tipoAdjunto,
      rutaFoto: _rutaFoto,
      textoExtra: _textoExtraController.text.isEmpty ? null : _textoExtraController.text,
    );

    final id = await _repository.addTarea(tarea);
    // Programar notificación
    await NotificationService.programarRecordatorio(
      id: id,
      titulo: tarea.titulo,
      fechaHora: tarea.fechaHoraLimite,
      descripcion: tarea.descripcion,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Tarea guardada y recordatorio programado')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Tarea Clínica')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text(DateFormat('dd/MM/yyyy HH:mm').format(_fechaHora)),
              leading: const Icon(Icons.calendar_today),
              onTap: _seleccionarFechaHora,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _tomarFoto,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_rutaFoto != null ? 'Foto tomada' : 'Tomar foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _rutaFoto != null ? Colors.green : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Audio en desarrollo')),
                      );
                    },
                    icon: const Icon(Icons.mic),
                    label: const Text('Audio'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textoExtraController,
              decoration: const InputDecoration(labelText: 'Nota adicional (texto)'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardar,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: const Text('GUARDAR TAREA'),
            ),
          ],
        ),
      ),
    );
  }
}