import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taskmanager/app/modules/settings/controllers/settings_controller.dart';

/// View for the Settings screen.
///
/// Allows the user to change the application's theme (System, Light, Dark).
/// Uses [GetView] to access the [SettingsController].
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Padding(
        // Responsive padding around the content.
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title for theme settings.
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h), // Responsive spacing
            Text(
              'Choose your preferred theme mode.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
            ),
            SizedBox(height: 20.h), // Responsive spacing
            // Obx widget to make the theme selection UI reactive.
            // It rebuilds whenever controller.selectedThemeMode changes.
            Obx(
              () => Column(
                children: [
                  // Radio button for System theme.
                  _buildThemeOptionRadio(
                    title: 'System Default',
                    value: ThemeMode.system,
                    groupValue: controller.currentTheme,
                    onChanged: controller.changeTheme,
                    icon: Icons.brightness_auto_outlined,
                    context: context,
                  ),
                  // Radio button for Light theme.
                  _buildThemeOptionRadio(
                    title: 'Light Mode',
                    value: ThemeMode.light,
                    groupValue: controller.currentTheme,
                    onChanged: controller.changeTheme,
                    icon: Icons.wb_sunny_outlined,
                    context: context,
                  ),
                  // Radio button for Dark theme.
                  _buildThemeOptionRadio(
                    title: 'Dark Mode',
                    value: ThemeMode.dark,
                    groupValue: controller.currentTheme,
                    onChanged: controller.changeTheme,
                    icon: Icons.nightlight_outlined,
                    context: context,
                  ),
                ],
              ),
            ),
            // Notification settings section
            Divider(height: 40.h),
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Enable or disable task notifications',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
            ),
            SizedBox(height: 20.h),
            Obx(
              () => SwitchListTile(
                title: Text('Enable Notifications'),
                value: controller.notificationsEnabled.value,
                onChanged: controller.toggleNotifications,
                secondary: Icon(Icons.notifications_active_outlined),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build a styled RadioListTile for theme selection.
  ///
  /// [title]: The text label for the radio option.
  /// [value]: The [ThemeMode] represented by this radio button.
  /// [groupValue]: The currently selected [ThemeMode] from the controller.
  /// [onChanged]: The callback function to execute when this option is selected.
  /// [icon]: The leading icon for the radio option.
  Widget _buildThemeOptionRadio({
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
    required IconData icon,
    required BuildContext context,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(unselectedWidgetColor: Theme.of(context).hintColor),
      child: RadioListTile<ThemeMode>(
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        secondary: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        activeColor: Theme.of(context).colorScheme.primary,
        contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}
