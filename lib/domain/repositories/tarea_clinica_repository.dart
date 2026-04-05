import '../models/tarea_clinica.dart';

abstract class TareaClinicaRepository {
  Future<List<TareaClinica>> getTareasPendientes();
  Future<List<TareaClinica>> getTareasCompletadas();
  Future<int> addTarea(TareaClinica tarea);          // ← retorna int
  Future<void> updateTarea(TareaClinica tarea);
  Future<void> deleteTarea(int id);
}