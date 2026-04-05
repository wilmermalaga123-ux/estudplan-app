import '../../domain/models/evento_horario.dart';
import '../../domain/repositories/evento_repository.dart';
import '../local/database_helper.dart';

class EventoRepositoryImpl implements EventoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<List<EventoHorario>> getEventos() async {
    final db = await _dbHelper.database;
    final maps = await db.query('eventos', orderBy: 'horaInicio ASC');
    return maps.map((m) => EventoHorario.fromMap(m)).toList();
  }

  @override
  Future<List<EventoHorario>> getEventosPorDia(int diaSemana) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'eventos',
      where: 'diasSemana LIKE ? AND activo = 1',
      whereArgs: ['%$diaSemana%'],
      orderBy: 'horaInicio ASC',
    );
    return maps.map((m) => EventoHorario.fromMap(m)).toList();
  }

  @override
  Future<void> addEvento(EventoHorario evento) async {
    final db = await _dbHelper.database;
    await db.insert('eventos', evento.toMap());
  }

  @override
  Future<void> updateEvento(EventoHorario evento) async {
    final db = await _dbHelper.database;
    await db.update('eventos', evento.toMap(), where: 'id = ?', whereArgs: [evento.id]);
  }

  @override
  Future<void> deleteEvento(int id) async {
    final db = await _dbHelper.database;
    await db.delete('eventos', where: 'id = ?', whereArgs: [id]);
  }
}