import '../models/materia.dart';

abstract class MateriaRepository {
  Future<List<Materia>> getMaterias();
  Future<void> addMateria(Materia materia);
  Future<void> updateMateria(Materia materia);
  Future<void> deleteMateria(int id);
}