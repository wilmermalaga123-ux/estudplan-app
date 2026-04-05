import '../../domain/models/tarea_clinica.dart';
import '../../domain/repositories/tarea_clinica_repository.dart';
import '../local/database_helper.dart';

class TareaClinicaRepositoryImpl implements TareaClinicaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<List<TareaClinica>> getTareasPendientes() async {
    return await _dbHelper.getTareasClinicas(pendientes: true);
  }

  @override
  Future<List<TareaClinica>> getTareasCompletadas() async {
    return await _dbHelper.getTareasClinicas(pendientes: false);
  }

  @override
  Future<int> addTarea(TareaClinica tarea) async {
    return await _dbHelper.insertTareaClinica(tarea);   // ← retorna el id
  }

  @override
  Future<void> updateTarea(TareaClinica tarea) async {
    await _dbHelper.updateTareaClinica(tarea);
  }

  @override
  Future<void> deleteTarea(int id) async {
    await _dbHelper.deleteTareaClinica(id);
  }
}