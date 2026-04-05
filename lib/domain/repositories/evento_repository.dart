import '../models/evento_horario.dart';

abstract class EventoRepository {
  Future<List<EventoHorario>> getEventos();
  Future<List<EventoHorario>> getEventosPorDia(int diaSemana);
  Future<void> addEvento(EventoHorario evento);
  Future<void> updateEvento(EventoHorario evento);
  Future<void> deleteEvento(int id);
}