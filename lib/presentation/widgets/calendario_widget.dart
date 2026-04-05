import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/repositories/evento_repository_impl.dart';
import '../../data/repositories/tarea_clinica_repository_impl.dart';
import '../../domain/models/evento_horario.dart';
import '../../domain/models/tarea_clinica.dart';

class CalendarioWidget extends StatefulWidget {
  const CalendarioWidget({super.key});

  @override
  State<CalendarioWidget> createState() => _CalendarioWidgetState();
}

class _CalendarioWidgetState extends State<CalendarioWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _eventos = {};
  final EventoRepositoryImpl _eventoRepo = EventoRepositoryImpl();
  final TareaClinicaRepositoryImpl _tareaRepo = TareaClinicaRepositoryImpl();

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    final eventos = await _eventoRepo.getEventos();
    final tareas = await _tareaRepo.getTareasPendientes();
    final Map<DateTime, List<dynamic>> temp = {};
    for (var e in eventos) {
      // Los eventos recurrentes: para cada día de la semana, agregar evento.
      for (int dia = 1; dia <= 7; dia++) {
        if (e.diasSemana.contains(dia)) {
          // Fecha aproximada: usamos el focusedDay para obtener el mes/año.
          // Mejor: buscar todas las fechas del mes.
        }
      }
    }
    // Simplificación: solo eventos con fecha fija (tareas) y eventos recurrentes
    // Para evitar complejidad, implementamos solo tareas por ahora.
    for (var t in tareas) {
      final fecha = DateTime(t.fechaHoraLimite.year, t.fechaHoraLimite.month, t.fechaHoraLimite.day);
      temp[fecha] ??= [];
      temp[fecha]!.add(t);
    }
    setState(() {
      _eventos = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
        _mostrarEventosDelDia(selected);
      },
      eventLoader: (day) {
        return _eventos[day] ?? [];
      },
      calendarStyle: CalendarStyle(
        markersAlignment: Alignment.bottomCenter,
        markerSize: 4,
      ),
    );
  }

  void _mostrarEventosDelDia(DateTime day) {
    final eventos = _eventos[day] ?? [];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Eventos del ${day.day}/${day.month}/${day.year}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (eventos.isEmpty)
              const Text('No hay eventos')
            else
              ...eventos.map((e) => ListTile(
                title: Text(e.titulo),
                subtitle: Text(e is TareaClinica ? 'Tarea clínica' : 'Evento fijo'),
              )),
          ],
        ),
      ),
    );
  }
}