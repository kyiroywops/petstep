import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localNotificationsProvider = Provider<FlutterLocalNotificationsPlugin>((ref) {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Configurar para Android / iOS
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  // Para iOS, se usa DarwinInitializationSettings, etc.
  const iOSInit = DarwinInitializationSettings();
  
  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: iOSInit,
  );

  // Inicializar
  flutterLocalNotificationsPlugin.initialize(initSettings);
  
  return flutterLocalNotificationsPlugin;
});

Future<void> showLocalNotification({
  required FlutterLocalNotificationsPlugin plugin,
  required String title,
  required String body,
  int id = 0,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'upload_channel',  // channelId
    'Subida de Reportes', // channelName
    channelDescription: 'Notificaciones de subida de reportes',
    importance: Importance.high,
    priority: Priority.high,
  );

  const iOSDetails = DarwinNotificationDetails();

  const notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iOSDetails,
  );

  await plugin.show(
    id,       // id de la notificación
    title,    // título
    body,     // cuerpo
    notificationDetails,
  );
}
