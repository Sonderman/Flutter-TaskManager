import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskmanager/app/data/services/theme_service.dart';

/// Controller for the Settings screen.
///
/// Manages the application's theme settings by interacting with the [ThemeService].
class SettingsController extends GetxController {
  /// Access to the theme service, retrieved via Get.find().
  final ThemeService _themeService = Get.find<ThemeService>();

  /// Reactive variable holding the currently selected theme mode.
  /// Initialized with the current theme from the ThemeService.
  /// Using Rx<ThemeMode> allows the UI to reactively update when the theme changes.
  late Rx<ThemeMode> selectedThemeMode;

  @override
  void onInit() {
    super.onInit();
    // Initialize the reactive variable with the current theme from the service.
    selectedThemeMode = _themeService.currentTheme.obs;
  }

  /// Changes the application's theme mode.
  ///
  /// Called when the user selects a new theme option in the UI.
  /// It updates the [selectedThemeMode] and calls the [ThemeService]
  /// to apply and persist the change.
  ///
  /// [mode]: The new [ThemeMode] selected by the user. Can be null if
  ///         using widgets like SegmentedButton where deselection is possible,
  ///         though in this case, we ensure a mode is always selected.
  void changeTheme(ThemeMode? mode) {
    // Ensure a valid theme mode is provided.
    if (mode != null && mode != selectedThemeMode.value) {
      // Update the reactive variable for UI changes.
      selectedThemeMode.value = mode;
      // Call the ThemeService to apply the change globally and save it.
      _themeService.changeThemeMode(mode);
      print('Theme changed to: $mode');
    }
  }

  /// Returns the currently selected theme mode.
  /// Useful for initializing UI elements like Radio buttons or SegmentedButton.
  ThemeMode get currentTheme => selectedThemeMode.value;
}
