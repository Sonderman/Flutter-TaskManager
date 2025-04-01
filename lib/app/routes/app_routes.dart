// Defines the route names used throughout the application.
// Using constants for route names helps prevent typos and makes refactoring easier.
abstract class AppRoutes {
  // Private constructor to prevent instantiation.
  AppRoutes._();

  // Route name for the main home screen (usually contains the bottom navigation).
  static const home = '/home';
  // Route name for the screen to create a new task.
  static const createTask = '/create-task';
  // Route name for the settings screen.
  static const settings = '/settings';

  // Potential future routes can be added here, e.g.:
  // static const TASK_DETAIL = '/task-detail';
  // static const PROFILE = '/profile';
}
