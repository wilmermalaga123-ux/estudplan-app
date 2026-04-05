import 'package:flutter/material.dart';

enum TipoEvento { clase, estudio, descanso, trabajo, otro }

class EventoHorario {
  int? id;
  String titulo;
  TipoEvento tipo;
  TimeOfDay horaInicio;
  TimeOfDay horaFin;
  List<int> diasSemana; // 1=lunes, 2=martes, ..., 7=domingo
  String? ubicacion;
  bool activo;

  EventoHorario({
    this.id,
    required this.titulo,
    required this.tipo,
    required this.horaInicio,
    required this.horaFin,
    required this.diasSemana,
    this.ubicacion,
    this.activo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'tipo': tipo.index,
      'horaInicio': horaInicio.hour * 60 + horaInicio.minute,
      'horaFin': horaFin.hour * 60 + horaFin.minute,
      'diasSemana': diasSemana.join(','),
      'ubicacion': ubicacion,
      'activo': activo ? 1 : 0,
    };
  }

  factory EventoHorario.fromMap(Map<String, dynamic> map) {
    final dias = (map['diasSemana'] as String).split(',').map(int.parse).toList();
    return EventoHorario(
      id: map['id'],
      titulo: map['titulo'],
      tipo: TipoEvento.values[map['tipo']],
      horaInicio: TimeOfDay.fromDateTime(DateTime(2000, 1, 1, map['horaInicio'] ~/ 60, map['horaInicio'] % 60)),
      horaFin: TimeOfDay.fromDateTime(DateTime(2000, 1, 1, map['horaFin'] ~/ 60, map['horaFin'] % 60)),
      diasSemana: dias,
      ubicacion: map['ubicacion'],
      activo: map['activo'] == 1,
    );
  }

  String get rangoHorario => '${_formatTime(horaInicio)} - ${_formatTime(horaFin)}';
  
  String get diasTexto {
    const nombres = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return diasSemana.map((d) => nombres[d-1]).join(', ');
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}