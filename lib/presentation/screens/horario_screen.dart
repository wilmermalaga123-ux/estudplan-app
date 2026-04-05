import 'package:flutter/material.dart';
import '../../data/repositories/evento_repository_impl.dart';
import '../../domain/models/evento_horario.dart';
import '../widgets/evento_card.dart';

class HorarioScreen extends StatefulWidget {
  const HorarioScreen({super.key});

  @override
  State<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {
  final EventoRepositoryImpl _repository = EventoRepositoryImpl();
  List<EventoHorario> _eventos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    final eventos = await _repository.getEventos();
    setState(() {
      _eventos = eventos;
      _cargando = false;
    });
  }

  Future<void> _agregarEvento() async {
    final nuevoEvento = await _mostrarFormularioEvento();
    if (nuevoEvento != null) {
      await _repository.addEvento(nuevoEvento);
      await _cargarEventos();
    }
  }

  Future<void> _editarEvento(EventoHorario evento) async {
    final eventoEditado = await _mostrarFormularioEvento(evento: evento);
    if (eventoEditado != null) {
      eventoEditado.id = evento.id;
      await _repository.updateEvento(eventoEditado);
      await _cargarEventos();
    }
  }

  Future<void> _eliminarEvento(EventoHorario evento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: Text('¿Eliminar "${evento.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _repository.deleteEvento(evento.id!);
      await _cargarEventos();
    }
  }

  Future<EventoHorario?> _mostrarFormularioEvento({EventoHorario? evento}) async {
    final tituloCtrl = TextEditingController(text: evento?.titulo ?? '');
    final ubicacionCtrl = TextEditingController(text: evento?.ubicacion ?? '');
    TipoEvento tipo = evento?.tipo ?? TipoEvento.clase;
    TimeOfDay horaInicio = evento?.horaInicio ?? const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay horaFin = evento?.horaFin ?? const TimeOfDay(hour: 10, minute: 0);
    List<int> diasSemana = evento?.diasSemana ?? [];

    return showDialog<EventoHorario>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setStateDialog) => AlertDialog(
          title: Text(evento == null ? 'Nuevo Evento' : 'Editar Evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Título')),
                const SizedBox(height: 8),
                DropdownButton<TipoEvento>(
                  value: tipo,
                  isExpanded: true,
                  items: TipoEvento.values.map((t) => DropdownMenuItem(value: t, child: Text(_nombreTipo(t)))).toList(),
                  onChanged: (t) => setStateDialog(() => tipo = t!),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final time = await showTimePicker(context: ctx2, initialTime: horaInicio);
                          if (time != null) setStateDialog(() => horaInicio = time);
                        },
                        child: Text('Inicio: ${horaInicio.format(ctx2)}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final time = await showTimePicker(context: ctx2, initialTime: horaFin);
                          if (time != null) setStateDialog(() => horaFin = time);
                        },
                        child: Text('Fin: ${horaFin.format(ctx2)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Días de la semana:', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 5,
                  children: [1,2,3,4,5,6,7].map((d) => FilterChip(
                    label: Text(['L','M','X','J','V','S','D'][d-1]),
                    selected: diasSemana.contains(d),
                    onSelected: (b) => setStateDialog(() {
                      if (b) diasSemana.add(d);
                      else diasSemana.remove(d);
                    }),
                  )).toList(),
                ),
                const SizedBox(height: 8),
                TextField(controller: ubicacionCtrl, decoration: const InputDecoration(labelText: 'Ubicación (opcional)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2, null), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                if (tituloCtrl.text.isEmpty) return;
                if (diasSemana.isEmpty) return;
                Navigator.pop(ctx2, EventoHorario(
                  titulo: tituloCtrl.text,
                  tipo: tipo,
                  horaInicio: horaInicio,
                  horaFin: horaFin,
                  diasSemana: diasSemana,
                  ubicacion: ubicacionCtrl.text.isEmpty ? null : ubicacionCtrl.text,
                ));
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  String _nombreTipo(TipoEvento tipo) {
    switch (tipo) {
      case TipoEvento.clase: return 'Clase';
      case TipoEvento.estudio: return 'Estudio';
      case TipoEvento.descanso: return 'Descanso';
      case TipoEvento.trabajo: return 'Trabajo';
      case TipoEvento.otro: return 'Otro';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: _eventos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No hay eventos fijos'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _agregarEvento,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Horario'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _eventos.length,
              itemBuilder: (context, index) {
                final evento = _eventos[index];
                return EventoCard(
                  evento: evento,
                  onEdit: () => _editarEvento(evento),
                  onDelete: () => _eliminarEvento(evento),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarEvento,
        child: const Icon(Icons.add),
      ),
    );
  }
}