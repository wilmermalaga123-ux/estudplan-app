enum TipoAdjunto { soloTexto, foto, audio, fotoYAudio }

class TareaClinica {
  int? id;
  String titulo;
  String? descripcion;
  DateTime fechaHoraLimite;
  TipoAdjunto tipoAdjunto;
  String? rutaFoto;
  String? rutaAudio;
  String? textoExtra;
  bool completada;

  TareaClinica({
    this.id,
    required this.titulo,
    this.descripcion,
    required this.fechaHoraLimite,
    this.tipoAdjunto = TipoAdjunto.soloTexto,
    this.rutaFoto,
    this.rutaAudio,
    this.textoExtra,
    this.completada = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaHoraLimite': fechaHoraLimite.toIso8601String(),
      'tipoAdjunto': tipoAdjunto.index,
      'rutaFoto': rutaFoto,
      'rutaAudio': rutaAudio,
      'textoExtra': textoExtra,
      'completada': completada ? 1 : 0,
    };
  }

  factory TareaClinica.fromMap(Map<String, dynamic> map) {
    return TareaClinica(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      fechaHoraLimite: DateTime.parse(map['fechaHoraLimite']),
      tipoAdjunto: TipoAdjunto.values[map['tipoAdjunto']],
      rutaFoto: map['rutaFoto'],
      rutaAudio: map['rutaAudio'],
      textoExtra: map['textoExtra'],
      completada: map['completada'] == 1,
    );
  }
}