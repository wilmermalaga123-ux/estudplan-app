import '../models/evidencia.dart';

abstract class EvidenciaRepository {
  Future<List<Evidencia>> getEvidencias();
  Future<void> addEvidencia(Evidencia evidencia);
  Future<void> deleteEvidencia(int id);
}