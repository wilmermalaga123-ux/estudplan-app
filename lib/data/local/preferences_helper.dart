import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _keySonido = 'sonido_notificacion';
static const String _keyVibracion = 'vibracion_notificacion';

static Future<void> saveSonido(bool activar) async {
  final prefs = await _prefs;
  await prefs.setBool(_keySonido, activar);
}

static Future<bool> getSonido() async {
  final prefs = await _prefs;
  return prefs.getBool(_keySonido) ?? true;
}

static Future<void> saveVibracion(bool activar) async {
  final prefs = await _prefs;
  await prefs.setBool(_keyVibracion, activar);
}

static Future<bool> getVibracion() async {
  final prefs = await _prefs;
  return prefs.getBool(_keyVibracion) ?? true;
}
  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<void> saveNombre(String nombre) async {
    final prefs = await _prefs;
    await prefs.setString('nombre', nombre);
  }

  static Future<String> getNombre() async {
    final prefs = await _prefs;
    return prefs.getString('nombre') ?? 'Wilmer Málaga Mamani';
  }

  static Future<void> saveVelocidad(int velocidad) async {
    final prefs = await _prefs;
    await prefs.setInt('velocidad', velocidad);
  }

  static Future<int> getVelocidad() async {
    final prefs = await _prefs;
    return prefs.getInt('velocidad') ?? 10;
  }

  static Future<void> saveHoraDormir(int hora, int minuto) async {
    final prefs = await _prefs;
    await prefs.setInt('hora_dormir_h', hora);
    await prefs.setInt('hora_dormir_m', minuto);
  }

  static Future<(int, int)> getHoraDormir() async {
    final prefs = await _prefs;
    return (prefs.getInt('hora_dormir_h') ?? 23, prefs.getInt('hora_dormir_m') ?? 0);
  }

  static Future<void> saveHoraDespertar(int hora, int minuto) async {
    final prefs = await _prefs;
    await prefs.setInt('hora_despertar_h', hora);
    await prefs.setInt('hora_despertar_m', minuto);
  }

  static Future<(int, int)> getHoraDespertar() async {
    final prefs = await _prefs;
    return (prefs.getInt('hora_despertar_h') ?? 7, prefs.getInt('hora_despertar_m') ?? 0);
  }

  static Future<void> saveTemaOscuro(bool isDark) async {
    final prefs = await _prefs;
    await prefs.setBool('tema_oscuro', isDark);
  }

  static Future<bool> getTemaOscuro() async {
    final prefs = await _prefs;
    return prefs.getBool('tema_oscuro') ?? false;
  }
}