import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../data/local/preferences_helper.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
  }

  static Future<void> programarRecordatorio({
    required int id,
    required String titulo,
    required DateTime fechaHora,
    String? descripcion,
  }) async {
    if (fechaHora.isBefore(DateTime.now())) return;

    // Obtener preferencias del usuario
    final sonido = await PreferencesHelper.getSonido();
    final vibracion = await PreferencesHelper.getVibracion();

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'tareas_clinicas_channel',
      'Recordatorios Clínicos',
      importance: Importance.high,
      priority: Priority.high,
      playSound: sonido,
      enableVibration: vibracion,
    );
    // ⚠️ IMPORTANTE: No usar 'const' aquí porque androidDetails no es constante
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _notifications.zonedSchedule(
      id,
      titulo,
      descripcion ?? 'Tienes una tarea clínica pendiente',
      tz.TZDateTime.from(fechaHora, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelarRecordatorio(int id) async {
    await _notifications.cancel(id);
  }
}