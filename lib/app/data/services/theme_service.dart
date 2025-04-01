import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Service class for managing the application's theme.
///
/// Handles saving and loading the preferred theme mode (System, Light, Dark)
/// using GetStorage and provides reactive access to the current theme mode.
class ThemeService extends GetxService {
  /// GetStorage instance specifically for theme settings.
  late final GetStorage _box;

  /// Key used to store the theme preference in GetStorage.
  final _key = 'theme_mode';

  /// Reactive variable holding the current theme mode.
  ///
  /// UI elements can listen to this variable to automatically update
  /// when the theme changes. It's initialized by reading from storage.
  late final Rx<ThemeMode> themeMode;

  ThemeService() {
    _box = GetStorage();
    themeMode = _loadThemeFromBox().obs;
  }

  /// Loads the saved theme mode from GetStorage.
  ///
  /// Returns [ThemeMode.system] if no theme is saved yet.
  ThemeMode _loadThemeFromBox() {
    // Read the stored theme index (0: system, 1: light, 2: dark).
    int themeIndex = _box.read<int>(_key) ?? 0; // Default to 0 (System)
    // Ensure the index is valid.
    if (themeIndex < 0 || themeIndex >= ThemeMode.values.length) {
      themeIndex = 0; // Reset to system if invalid index found
    }
    return ThemeMode.values[themeIndex];
  }

  /// Saves the selected theme mode to GetStorage.
  ///
  /// [mode]: The [ThemeMode] to save.
  Future<void> _saveThemeToBox(ThemeMode mode) async {
    // Write the index of the ThemeMode enum to storage.
    await _box.write(_key, mode.index);
    print('Theme mode saved: $mode');
  }

  /// Changes the application's theme mode.
  ///
  /// Updates the reactive [themeMode] variable and saves the new mode
  /// to GetStorage.
  /// [mode]: The new [ThemeMode] to apply.
  void changeThemeMode(ThemeMode mode) {
    if (themeMode.value != mode) {
      themeMode.value = mode; // Update reactive variable
      Get.changeThemeMode(mode); // Apply the theme change globally via GetX
      _saveThemeToBox(mode); // Persist the change
    }
  }

  /// Returns the currently active theme mode.
  ThemeMode get currentTheme => themeMode.value;
}
