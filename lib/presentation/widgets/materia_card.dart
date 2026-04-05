import 'package:flutter/material.dart';
import '../../domain/models/materia.dart';

class MateriaCard extends StatelessWidget {
  final Materia materia;
  final VoidCallback onEdit;
  final VoidCallback onLongPress;

  const MateriaCard({
    super.key,
    required this.materia,
    required this.onEdit,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      materia.nombre,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: materia.progreso,
                backgroundColor: Colors.grey.shade300,
                color: Colors.teal,
              ),
              const SizedBox(height: 8),
              Text(
                'Progreso: ${(materia.progreso * 100).toStringAsFixed(1)}% (${materia.paginasLeidas}/${materia.paginasTotales} páginas)',
              ),
              Text(
                'Velocidad: ${materia.velocidadPaginasPorHora} pág/h → ${materia.horasRestantes.toStringAsFixed(1)} horas restantes',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}