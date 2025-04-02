import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:intl/intl.dart'; // For DateFormat
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:taskmanager/app/modules/settings/controllers/settings_controller.dart';

/// Service class for managing local notifications in the app.
///
/// Handles initialization, showing, scheduling and canceling notifications.
/// Uses task ID's hashcode as the notification ID for scheduling/canceling.
class NotificationService {
  late final FlutterLocalNotificationsPlugin _notificationsPlugin;

  NotificationService() {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  /// Initializes the notification service with platform-specific settings.
  /// Also initializes timezone database for scheduled notifications.
  Future<void> initialize() async {
    // Initialize timezone database
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Create notification channel (required for Android 8.0+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_task_channel', // id
      'Daily Task Reminders', // name
      description: 'Daily reminders for scheduled tasks', // description
      importance: Importance.max,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        Get.log('Notification tapped: ${details.payload}');
      },
    );
  }

  /// Helper function to convert a String task ID into a unique integer notification ID.
  /// Uses the String's hashCode. Publicly accessible.
  int getNotificationId(String taskId) {
    // Using hashCode provides a simple way to get a consistent integer ID from the string ID.
    // Be aware of potential (though unlikely for typical UUIDs) hash collisions.
    return taskId.hashCode;
  }

  /// Shows a simple notification immediately.
  ///
  /// [title]: The title of the notification
  /// [body]: The body text of the notification
  /// [payload]: Optional data to pass when notification is tapped
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!Get.isRegistered<SettingsController>()) {
      Get.log('SettingsController not found - skipping notification');
      return;
    }
    final SettingsController settingsController = Get.find<SettingsController>();
    if (!settingsController.notificationsEnabled.value) {
      Get.log('Notifications are disabled - not showing notification');
      return;
    }
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Cancels a previously scheduled notification.
  ///
  /// [id]: The integer ID of the notification to cancel (derived from task ID's hashcode).
  Future<void> cancelNotification(int id) async {
    Get.log('Canceling notification with ID: $id');
    await _notificationsPlugin.cancel(id);
  }

  /// Cancels all previously scheduled notifications.
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Schedules a notification to appear at a specific time.
  ///
  /// [title]: The title of the notification
  /// [body]: The body text of the notification
  /// [scheduledTime]: The time when notification should appear
  /// [payload]: Optional data to pass when notification is tapped
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!Get.isRegistered<SettingsController>()) {
      Get.log('SettingsController not found - skipping notification');
      return;
    }
    final SettingsController settingsController = Get.find<SettingsController>();
    if (!settingsController.notificationsEnabled.value) {
      Get.log('Notifications are disabled - not scheduling notification');
      return;
    }
    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      0, // Notification ID
      title,
      body,
      scheduledTZ,
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedules a daily repeating notification for a specific time.
  ///
  /// [id]: The unique integer ID for the notification (derived from task ID's hashcode).
  /// [title]: The title of the notification.
  /// [body]: The body text of the notification.
  /// [time]: The time of day (HH:mm) to show the notification.
  /// [payload]: Optional data to pass when notification is tapped.
  Future<void> scheduleDailyNotification({
    required String taskId, // Use task ID string for clarity
    required String title,
    required String body,
    required String time, // Expecting "HH:mm" format
    String? payload,
  }) async {
    if (!Get.isRegistered<SettingsController>()) {
      Get.log('SettingsController not found - skipping notification');
      return;
    }
    final SettingsController settingsController = Get.find<SettingsController>();
    if (!settingsController.notificationsEnabled.value) {
      Get.log('Notifications are disabled - not scheduling daily notification');
      return;
    }
    final int notificationId = getNotificationId(taskId); // Use public method
    Get.log('Scheduling daily notification for task $taskId (ID: $notificationId) at $time');

    // Parse time string in either 24-hour (HH:mm) or 12-hour (h:mm AM/PM) format
    int hour = 0;
    int minute = 0;

    try {
      DateTime parsedTime;
      if (time.toLowerCase().contains('am') || time.toLowerCase().contains('pm')) {
        // Handle 12-hour format
        parsedTime = DateFormat('h:mm a').parse(time);
      } else {
        // Handle 24-hour format
        parsedTime = DateFormat('HH:mm').parse(time);
      }

      hour = parsedTime.hour;
      minute = parsedTime.minute;

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        Get.log('Error: Invalid time range in "$time" - must be between 00:00-23:59');
        return;
      }

      Get.log('Successfully parsed time: $hour:$minute from input: $time');
    } catch (e) {
      Get.log('Error: Could not parse time "$time" - ${e.toString()}');
      Get.log('Expected formats: "HH:mm" (24-hour) or "h:mm a" (12-hour)');
      return;
    }

    // Calculate the next occurrence of the scheduled time
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'daily_task_channel', // Use a different channel ID for daily tasks if needed
      'Daily Task Reminders',
      channelDescription: 'Daily reminders for scheduled tasks',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      notificationId, // Use the generated integer ID
      title,
      body,
      scheduledDate,
      notificationDetails,
      payload: payload ?? taskId, // Use taskId as payload if none provided
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation is iOS-specific, not needed here
      matchDateTimeComponents: DateTimeComponents.time, // Match only the time for daily repetition
    );
    Get.log('Successfully scheduled daily notification ID: $notificationId at $scheduledDate');

    // Debug logging
    if (kDebugMode) {
      print('Notification scheduled for:');
      print('- Task ID: $taskId');
      print('- Notification ID: $notificationId');
      print('- Time: $time ($hour:$minute)');
      print('- Next occurrence: $scheduledDate');
      print('- Current time: ${tz.TZDateTime.now(tz.local)}');
      print('- Time until notification: ${scheduledDate.difference(tz.TZDateTime.now(tz.local))}');
    }
  }

  /// Calculates the next instance of a specific time (HH:mm) from now.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
