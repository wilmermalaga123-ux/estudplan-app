import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import '../../domain/models/materia.dart';
import '../../domain/models/evento_horario.dart';
import '../../domain/models/evidencia.dart';
import '../../domain/models/tarea_clinica.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static void init() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), 'estudplan.db');
    
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE materias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        paginasTotales INTEGER NOT NULL,
        paginasLeidas INTEGER NOT NULL DEFAULT 0,
        velocidadPaginasPorHora INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE eventos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        tipo INTEGER NOT NULL,
        horaInicio INTEGER NOT NULL,
        horaFin INTEGER NOT NULL,
        diasSemana TEXT NOT NULL,
        ubicacion TEXT,
        activo INTEGER DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE evidencias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        rutaImagen TEXT NOT NULL,
        fechaCreacion TEXT NOT NULL,
        materiaId TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE tareas_clinicas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        fechaHoraLimite TEXT NOT NULL,
        tipoAdjunto INTEGER NOT NULL,
        rutaFoto TEXT,
        rutaAudio TEXT,
        textoExtra TEXT,
        completada INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS eventos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT NOT NULL,
          tipo INTEGER NOT NULL,
          horaInicio INTEGER NOT NULL,
          horaFin INTEGER NOT NULL,
          diasSemana TEXT NOT NULL,
          ubicacion TEXT,
          activo INTEGER DEFAULT 1
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS evidencias(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT NOT NULL,
          rutaImagen TEXT NOT NULL,
          fechaCreacion TEXT NOT NULL,
          materiaId TEXT
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tareas_clinicas(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT NOT NULL,
          descripcion TEXT,
          fechaHoraLimite TEXT NOT NULL,
          tipoAdjunto INTEGER NOT NULL,
          rutaFoto TEXT,
          rutaAudio TEXT,
          textoExtra TEXT,
          completada INTEGER DEFAULT 0
        )
      ''');
    }
  }

  // ==================== MATERIAS ====================
  Future<int> insertMateria(Materia materia) async {
    final db = await database;
    return await db.insert('materias', materia.toMap());
  }

  Future<List<Materia>> getMaterias() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('materias');
    return List.generate(maps.length, (i) => Materia.fromMap(maps[i]));
  }

  Future<int> updateMateria(Materia materia) async {
    final db = await database;
    return await db.update(
      'materias',
      materia.toMap(),
      where: 'id = ?',
      whereArgs: [materia.id],
    );
  }

  Future<int> deleteMateria(int id) async {
    final db = await database;
    return await db.delete('materias', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== EVENTOS ====================
  Future<int> insertEvento(EventoHorario evento) async {
    final db = await database;
    return await db.insert('eventos', evento.toMap());
  }

  Future<List<EventoHorario>> getEventos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('eventos', orderBy: 'horaInicio ASC');
    return List.generate(maps.length, (i) => EventoHorario.fromMap(maps[i]));
  }

  Future<List<EventoHorario>> getEventosPorDia(int diaSemana) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'eventos',
      where: 'diasSemana LIKE ? AND activo = 1',
      whereArgs: ['%$diaSemana%'],
      orderBy: 'horaInicio ASC',
    );
    return List.generate(maps.length, (i) => EventoHorario.fromMap(maps[i]));
  }

  Future<int> updateEvento(EventoHorario evento) async {
    final db = await database;
    return await db.update(
      'eventos',
      evento.toMap(),
      where: 'id = ?',
      whereArgs: [evento.id],
    );
  }

  Future<int> deleteEvento(int id) async {
    final db = await database;
    return await db.delete('eventos', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== EVIDENCIAS ====================
  Future<int> insertEvidencia(Evidencia evidencia) async {
    final db = await database;
    return await db.insert('evidencias', evidencia.toMap());
  }

  Future<List<Evidencia>> getEvidencias() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('evidencias', orderBy: 'fechaCreacion DESC');
    return List.generate(maps.length, (i) => Evidencia.fromMap(maps[i]));
  }

  Future<int> deleteEvidencia(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'evidencias',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final ruta = maps.first['rutaImagen'] as String;
      final archivo = File(ruta);
      if (await archivo.exists()) {
        await archivo.delete();
      }
    }
    return await db.delete('evidencias', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== TAREAS CLÍNICAS ====================
  Future<int> insertTareaClinica(TareaClinica tarea) async {
    final db = await database;
    return await db.insert('tareas_clinicas', tarea.toMap());
  }

  Future<List<TareaClinica>> getTareasClinicas({bool pendientes = true}) async {
    final db = await database;
    final String? where = pendientes ? 'completada = 0' : 'completada = 1';
    final List<Map<String, dynamic>> maps = await db.query(
      'tareas_clinicas',
      where: where,
      orderBy: 'fechaHoraLimite ASC',
    );
    return List.generate(maps.length, (i) => TareaClinica.fromMap(maps[i]));
  }

  Future<int> updateTareaClinica(TareaClinica tarea) async {
    final db = await database;
    return await db.update(
      'tareas_clinicas',
      tarea.toMap(),
      where: 'id = ?',
      whereArgs: [tarea.id],
    );
  }

  Future<int> deleteTareaClinica(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tareas_clinicas',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final tarea = TareaClinica.fromMap(maps.first);
      if (tarea.rutaFoto != null) {
        final foto = File(tarea.rutaFoto!);
        if (await foto.exists()) await foto.delete();
      }
      if (tarea.rutaAudio != null) {
        final audio = File(tarea.rutaAudio!);
        if (await audio.exists()) await audio.delete();
      }
    }
    return await db.delete('tareas_clinicas', where: 'id = ?', whereArgs: [id]);
  }
}