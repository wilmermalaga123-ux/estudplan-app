import 'package:flutter/material.dart';
import '../../data/local/preferences_helper.dart';
import 'dashboard_screen.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final TextEditingController _nombreController = TextEditingController();
  double _velocidad = 10;
  TimeOfDay _horaDormir = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _horaDespertar = const TimeOfDay(hour: 7, minute: 0);
  bool _temaOscuro = false;
  bool _cargando = true;
  bool _sonido = true;      // ← nueva variable
  bool _vibracion = true;   // ← nueva variable

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final nombre = await PreferencesHelper.getNombre();
    final velocidad = await PreferencesHelper.getVelocidad();
    final (hDormir, mDormir) = await PreferencesHelper.getHoraDormir();
    final (hDesp, mDesp) = await PreferencesHelper.getHoraDespertar();
    final temaOscuro = await PreferencesHelper.getTemaOscuro();
    final sonido = await PreferencesHelper.getSonido();
    final vibracion = await PreferencesHelper.getVibracion();
    setState(() {
      _nombreController.text = nombre;
      _velocidad = velocidad.toDouble();
      _horaDormir = TimeOfDay(hour: hDormir, minute: mDormir);
      _horaDespertar = TimeOfDay(hour: hDesp, minute: mDesp);
      _temaOscuro = temaOscuro;
      _sonido = sonido;
      _vibracion = vibracion;
      _cargando = false;
    });
  }

  Future<void> _guardarCambios() async {
    await PreferencesHelper.saveNombre(_nombreController.text);
    await PreferencesHelper.saveVelocidad(_velocidad.toInt());
    await PreferencesHelper.saveHoraDormir(_horaDormir.hour, _horaDormir.minute);
    await PreferencesHelper.saveHoraDespertar(_horaDespertar.hour, _horaDespertar.minute);
    await PreferencesHelper.saveTemaOscuro(_temaOscuro);
    await PreferencesHelper.saveSonido(_sonido);
    await PreferencesHelper.saveVibracion(_vibracion);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Cambios guardados')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    }
  }

  Future<void> _seleccionarHora({required bool esDormir}) async {
    final horaInicial = esDormir ? _horaDormir : _horaDespertar;
    final hora = await showTimePicker(context: context, initialTime: horaInicial);
    if (hora != null && mounted) {
      setState(() {
        if (esDormir) {
          _horaDormir = hora;
        } else {
          _horaDespertar = hora;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ajustes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Configura tu ritmo de lectura y horarios básicos.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nombre para mostrar', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Tu nombre'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tema', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _temaOscuro = false),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: !_temaOscuro ? Colors.teal.shade50 : null,
                            side: BorderSide(color: !_temaOscuro ? Colors.teal : Colors.grey),
                          ),
                          child: Text('Claro', style: TextStyle(color: !_temaOscuro ? Colors.teal : null)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _temaOscuro = true),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _temaOscuro ? Colors.teal.shade50 : null,
                            side: BorderSide(color: _temaOscuro ? Colors.teal : Colors.grey),
                          ),
                          child: Text('Oscuro', style: TextStyle(color: _temaOscuro ? Colors.teal : null)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Velocidad de Lectura (páginas/hora)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _velocidad,
                          min: 1,
                          max: 50,
                          divisions: 49,
                          onChanged: (value) => setState(() => _velocidad = value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(8)),
                        child: Text('${_velocidad.toInt()}', style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Usamos esto para calcular cuánto tiempo necesitas para cada lectura.', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                  const Text('Horario de Sueño', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hora de Dormir'),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () => _seleccionarHora(esDormir: true),
                              icon: const Icon(Icons.nightlight_round),
                              label: Text(_horaDormir.format(context)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hora de Despertar'),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () => _seleccionarHora(esDormir: false),
                              icon: const Icon(Icons.wb_sunny),
                              label: Text(_horaDespertar.format(context)),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  const Text('Notificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SwitchListTile(
                    title: const Text('Sonido en notificaciones'),
                    value: _sonido,
                    onChanged: (value) async {
                      setState(() => _sonido = value);
                      await PreferencesHelper.saveSonido(value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Vibración en notificaciones'),
                    value: _vibracion,
                    onChanged: (value) async {
                      setState(() => _vibracion = value);
                      await PreferencesHelper.saveVibracion(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _guardarCambios,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Cerrar Sesión'),
            ),
          ),
        ],
      ),
    );
  }
}