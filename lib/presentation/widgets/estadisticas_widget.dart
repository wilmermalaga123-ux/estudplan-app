import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/repositories/materia_repository_impl.dart';
import '../../data/repositories/tarea_clinica_repository_impl.dart';
import '../../domain/models/materia.dart';
import '../../domain/models/tarea_clinica.dart';

class EstadisticasWidget extends StatefulWidget {
  const EstadisticasWidget({super.key});

  @override
  State<EstadisticasWidget> createState() => _EstadisticasWidgetState();
}

class _EstadisticasWidgetState extends State<EstadisticasWidget> {
  final MateriaRepositoryImpl _materiaRepo = MateriaRepositoryImpl();
  final TareaClinicaRepositoryImpl _tareaRepo = TareaClinicaRepositoryImpl();
  List<Materia> _materias = [];
  List<TareaClinica> _tareasCompletadas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final materias = await _materiaRepo.getMaterias();
    final tareas = await _tareaRepo.getTareasCompletadas();
    setState(() {
      _materias = materias;
      _tareasCompletadas = tareas;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 Progreso de Lectura', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildProgresoMaterias(),
          const SizedBox(height: 32),
          const Text('✅ Productividad Diaria', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildProductividad(),
        ],
      ),
    );
  }

  Widget _buildProgresoMaterias() {
    if (_materias.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No hay materias registradas')));
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: _materias.asMap().entries.map((entry) {
            final index = entry.key;
            final materia = entry.value;
            final porcentaje = materia.progreso;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: porcentaje,
                  color: Colors.teal,
                  width: 20,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _materias.length) {
                    return Text(_materias[value.toInt()].nombre,
                        style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('${(value * 100).toInt()}%');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  Widget _buildProductividad() {
    if (_tareasCompletadas.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No hay tareas completadas aún')));
    }

    // Agrupar tareas por día (últimos 7 días)
    final now = DateTime.now();
    final Map<DateTime, int> tareasPorDia = {};
    for (int i = 6; i >= 0; i--) {
      final dia = DateTime(now.year, now.month, now.day - i);
      tareasPorDia[dia] = 0;
    }
    for (final tarea in _tareasCompletadas) {
      final dia = DateTime(tarea.fechaHoraLimite.year, tarea.fechaHoraLimite.month, tarea.fechaHoraLimite.day);
      if (tareasPorDia.containsKey(dia)) {
        tareasPorDia[dia] = tareasPorDia[dia]! + 1;
      }
    }

    final dias = tareasPorDia.keys.toList();
    final valores = tareasPorDia.values.toList();

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < dias.length) {
                    return Text('${dias[value.toInt()].day}/${dias[value.toInt()].month}');
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(valores.length, (i) => FlSpot(i.toDouble(), valores[i].toDouble())),
              isCurved: true,
              color: Colors.teal,
              barWidth: 4,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}