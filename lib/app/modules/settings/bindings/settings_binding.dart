import 'package:get/get.dart';
import 'package:taskmanager/app/modules/settings/controllers/settings_controller.dart';

/// Binding class for the Settings screen.
///
/// Sets up the [SettingsController] when the Settings route is accessed.
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Lazily initializes and registers SettingsController.
    Get.lazyPut<SettingsController>(
      () => SettingsController(),
    );
  }
}
