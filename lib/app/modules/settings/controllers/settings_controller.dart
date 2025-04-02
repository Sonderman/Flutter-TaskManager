import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskmanager/app/data/services/notification_service.dart';
import 'package:taskmanager/app/data/services/storage_service.dart';
import 'package:taskmanager/app/data/services/theme_service.dart';

/// Controller for the Settings screen.
///
/// Manages the application's theme and notification settings.
class SettingsController extends GetxController {
  /// Access to the theme service, retrieved via Get.find().
  final ThemeService _themeService = Get.find<ThemeService>();
  final NotificationService _notificationService = Get.find<NotificationService>();

  /// Reactive variable holding the currently selected theme mode.
  late Rx<ThemeMode> selectedThemeMode;

  /// Reactive variable for notification toggle state
  final RxBool notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    selectedThemeMode = _themeService.currentTheme.obs;
    // Initialize notification state from storage
    notificationsEnabled.value =
        Get.find<StorageService>().box.read('notificationsEnabled') ?? true;
  }

  /// Changes the application's theme mode.
  void changeTheme(ThemeMode? mode) {
    if (mode != null && mode != selectedThemeMode.value) {
      selectedThemeMode.value = mode;
      _themeService.changeThemeMode(mode);
      if (kDebugMode) {
        print('Theme changed to: $mode');
      }
    }
  }

  /// Toggles notification service on/off
  void toggleNotifications(bool enabled) {
    notificationsEnabled.value = enabled;
    Get.find<StorageService>().box.write('notificationsEnabled', enabled);
    if (!enabled) {
      _notificationService.cancelAllNotifications();
    }
    if (kDebugMode) {
      print('Notifications ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  /// Returns the currently selected theme mode.
  ThemeMode get currentTheme => selectedThemeMode.value;
}
