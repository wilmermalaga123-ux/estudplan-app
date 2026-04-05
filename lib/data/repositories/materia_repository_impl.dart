import '../../domain/models/materia.dart';
import '../../domain/repositories/materia_repository.dart';
import '../local/database_helper.dart';

class MateriaRepositoryImpl implements MateriaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<List<Materia>> getMaterias() => _dbHelper.getMaterias();

  @override
  Future<void> addMateria(Materia materia) => _dbHelper.insertMateria(materia);

  @override
  Future<void> updateMateria(Materia materia) => _dbHelper.updateMateria(materia);

  @override
  Future<void> deleteMateria(int id) => _dbHelper.deleteMateria(id);
}