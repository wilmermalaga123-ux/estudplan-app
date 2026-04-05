class Evidencia {
  int? id;
  String titulo;
  String rutaImagen;
  DateTime fechaCreacion;
  String? materiaId;

  Evidencia({
    this.id,
    required this.titulo,
    required this.rutaImagen,
    required this.fechaCreacion,
    this.materiaId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'rutaImagen': rutaImagen,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'materiaId': materiaId,
    };
  }

  factory Evidencia.fromMap(Map<String, dynamic> map) {
    return Evidencia(
      id: map['id'],
      titulo: map['titulo'],
      rutaImagen: map['rutaImagen'],
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
      materiaId: map['materiaId'],
    );
  }
}