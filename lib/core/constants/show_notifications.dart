import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hackathon_mobile/dependency_injection.dart';

void showNotification(String title, String body) async {
  var androidDetails = AndroidNotificationDetails(
    'budget_channel', // Channel ID
    'Budget Notifications', // Channel Name
    importance: Importance.high,
    priority: Priority.high,
  );

  var notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    title,
    body,
    notificationDetails,
  );
}
