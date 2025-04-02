import 'package:get/get.dart';
import 'package:taskmanager/app/modules/create_task/bindings/create_task_binding.dart';
import 'package:taskmanager/app/modules/create_task/views/create_task_view.dart';
import 'package:taskmanager/app/modules/home/bindings/home_binding.dart';
import 'package:taskmanager/app/modules/home/views/home_view.dart';
import 'package:taskmanager/app/modules/settings/views/settings_view.dart';
import 'app_routes.dart'; // Import the route names

/// Defines the application's pages (routes) and their bindings.
///
/// This list is used by GetMaterialApp to configure the navigation system.
class AppPages {
  // Private constructor to prevent instantiation.
  AppPages._();

  static const initial = AppRoutes.home;

  /// List of all pages/routes defined in the application.
  /// Each GetPage entry maps a route name to its view and binding.
  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(), // The widget builder for the home screen
      binding: HomeBinding(), // The binding that initializes HomeController
      // transition: Transition.fadeIn, // Optional: Define page transition animation
    ),
    GetPage(
      name: AppRoutes.createTask,
      page: () => const CreateTaskView(), // Widget builder for create task screen
      binding: CreateTaskBinding(), // Binding for CreateTaskController
      // transition: Transition.rightToLeftWithFade, // Optional transition
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(), // Widget builder for settings screen
      // transition: Transition.rightToLeft, // Optional transition
    ),
    // Add more GetPage entries here for other routes as the app grows.
  ];
}
