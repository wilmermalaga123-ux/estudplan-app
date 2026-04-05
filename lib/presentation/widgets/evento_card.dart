import 'package:flutter/material.dart';
import '../../domain/models/evento_horario.dart';

class EventoCard extends StatelessWidget {
  final EventoHorario evento;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventoCard({
    super.key,
    required this.evento,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getColorPorTipo(TipoEvento tipo) {
    switch (tipo) {
      case TipoEvento.clase: return Colors.blue;
      case TipoEvento.estudio: return Colors.green;
      case TipoEvento.descanso: return Colors.orange;
      case TipoEvento.trabajo: return Colors.red;
      case TipoEvento.otro: return Colors.purple;
    }
  }

  IconData _getIconPorTipo(TipoEvento tipo) {
    switch (tipo) {
      case TipoEvento.clase: return Icons.school;
      case TipoEvento.estudio: return Icons.menu_book;
      case TipoEvento.descanso: return Icons.free_breakfast;
      case TipoEvento.trabajo: return Icons.work;
      case TipoEvento.otro: return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColorPorTipo(evento.tipo).withOpacity(0.2),
          child: Icon(_getIconPorTipo(evento.tipo), color: _getColorPorTipo(evento.tipo)),
        ),
        title: Text(evento.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${evento.rangoHorario} • ${evento.diasTexto}'),
            if (evento.ubicacion != null)
              Text(evento.ubicacion!, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}