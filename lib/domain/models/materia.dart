class Materia {
  int? id;
  String nombre;
  int paginasTotales;
  int paginasLeidas;
  int velocidadPaginasPorHora;

  Materia({
    this.id,
    required this.nombre,
    required this.paginasTotales,
    this.paginasLeidas = 0,
    required this.velocidadPaginasPorHora,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'paginasTotales': paginasTotales,
      'paginasLeidas': paginasLeidas,
      'velocidadPaginasPorHora': velocidadPaginasPorHora,
    };
  }

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      id: map['id'],
      nombre: map['nombre'],
      paginasTotales: map['paginasTotales'],
      paginasLeidas: map['paginasLeidas'],
      velocidadPaginasPorHora: map['velocidadPaginasPorHora'],
    );
  }

  double get progreso => paginasTotales > 0 ? paginasLeidas / paginasTotales : 0;
  double get horasRestantes => (paginasTotales - paginasLeidas) / velocidadPaginasPorHora;
}