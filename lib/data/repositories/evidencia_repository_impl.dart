import '../../domain/models/evidencia.dart';
import '../../domain/repositories/evidencia_repository.dart';
import '../local/database_helper.dart';

class EvidenciaRepositoryImpl implements EvidenciaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<List<Evidencia>> getEvidencias() async {
    return await _dbHelper.getEvidencias();
  }

  @override
  Future<void> addEvidencia(Evidencia evidencia) async {
    await _dbHelper.insertEvidencia(evidencia);
  }

  @override
  Future<void> deleteEvidencia(int id) async {
    await _dbHelper.deleteEvidencia(id);
  }
}