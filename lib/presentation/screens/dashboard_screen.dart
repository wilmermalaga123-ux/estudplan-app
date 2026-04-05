import 'package:flutter/material.dart';
import 'lecturas_screen.dart';
import 'horario_screen.dart';
import 'clinica_screen.dart';
import 'ajustes_screen.dart';
import '../widgets/estadisticas_widget.dart';
import '../widgets/calendario_widget.dart';
import '../../data/local/preferences_helper.dart';
import '../../data/repositories/evento_repository_impl.dart';
import '../../domain/models/evento_horario.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const InicioScreen(),
    const LecturasScreen(),
    const HorarioScreen(),
    const ClinicaScreen(),
    const AjustesScreen(),
    const EstadisticasWidget(),      // nueva pestaña (índice 5)
    const CalendarioWidget(),        // nueva pestaña (índice 6)
  ];

  void _navegar(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // cierra el drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('EstudPlan'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('EstudPlan', style: TextStyle(fontSize: 24))),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Inicio'),
              onTap: () => _navegar(0),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Lecturas'),
              onTap: () => _navegar(1),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Horario'),
              onTap: () => _navegar(2),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Clínica'),
              onTap: () => _navegar(3),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes'),
              onTap: () => _navegar(4),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Estadísticas'),
              onTap: () => _navegar(5),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Calendario'),
              onTap: () => _navegar(6),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Lecturas'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Horario'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Clínica'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Ajustes'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendario'),
        ],
      ),
    );
  }
}

// ==================== PANTALLA INICIO (sin cambios, solo la movemos aquí) ====================
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  List<EventoHorario> _eventosHoy = [];
  bool _cargandoEventos = true;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    final eventos = await EventoRepositoryImpl().getEventosPorDia(DateTime.now().weekday);
    setState(() {
      _eventosHoy = eventos;
      _cargandoEventos = false;
    });
  }

  IconData _iconoPorTipo(TipoEvento tipo) {
    switch (tipo) {
      case TipoEvento.clase: return Icons.school;
      case TipoEvento.estudio: return Icons.menu_book;
      case TipoEvento.descanso: return Icons.free_breakfast;
      case TipoEvento.trabajo: return Icons.work;
      case TipoEvento.otro: return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _cargarEventos,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            FutureBuilder(
              future: PreferencesHelper.getNombre(),
              builder: (context, snapshot) {
                final nombre = snapshot.data ?? 'Usuario';
                return Text(
                  'Hola, $nombre',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Aquí tienes tu plan de estudio para hoy.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📚 Sesiones de Estudio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(Icons.free_breakfast, size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'No hay sesiones de estudio programadas para este día.',
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text('¡Disfruta tu tiempo libre!', style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⏰ Horario Fijo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    FutureBuilder(
                      future: Future.wait([PreferencesHelper.getHoraDormir(), PreferencesHelper.getHoraDespertar()]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final dormir = snapshot.data![0];
                        final despertar = snapshot.data![1];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              const Icon(Icons.nightlight_round, color: Colors.blue),
                              const SizedBox(width: 12),
                              Text(
                                'Descanso: ${dormir.$1.toString().padLeft(2, '0')}:${dormir.$2.toString().padLeft(2, '0')} '
                                'a ${despertar.$1.toString().padLeft(2, '0')}:${despertar.$2.toString().padLeft(2, '0')}',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_cargandoEventos)
                      const Center(child: SizedBox(height: 40, child: CircularProgressIndicator()))
                    else if (_eventosHoy.isEmpty)
                      const Text('Sin eventos fijos hoy.', style: TextStyle(color: Colors.grey))
                    else
                      Column(
                        children: _eventosHoy.map((evento) => ListTile(
                          dense: true,
                          leading: Icon(_iconoPorTipo(evento.tipo), size: 20, color: Colors.teal),
                          title: Text(evento.titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            '${evento.rangoHorario}${evento.ubicacion != null ? ' · ${evento.ubicacion}' : ''}',
                          ),
                        )).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}