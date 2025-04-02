import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:taskmanager/app/core/theme/app_theme.dart';
import 'package:taskmanager/app/data/services/notification_service.dart';
import 'package:taskmanager/app/data/services/storage_service.dart';
import 'package:taskmanager/app/data/services/theme_service.dart';
import 'package:taskmanager/app/modules/settings/controllers/settings_controller.dart';
import 'package:taskmanager/app/routes/app_pages.dart';

/// The main entry point of the application.
Future<void> main() async {
  // Ensure Flutter bindings are initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  await setUpServices();
  // Run the application.
  runApp(const MyApp());
}

Future<void> setUpServices() async {
  await GetStorage.init();
  Get.put<ThemeService>(ThemeService(), permanent: true);
  Get.put<StorageService>(StorageService(), permanent: true);
  final notificationService = Get.put<NotificationService>(NotificationService(), permanent: true);
  await notificationService.initialize();
  Get.put<SettingsController>(SettingsController(), permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil. Provide the design size of your UI mockups.
    // This allows scaling UI elements based on screen size.
    // Common design sizes are like iPhone 8 (375x667) or iPhone X (375x812).
    // Adjust these values based on your design reference.
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Example design size (iPhone X)
      minTextAdapt: true, // Adapt text size based on screen constraints
      splitScreenMode: true, // Support split screen mode
      builder: (context, child) {
        final themeService = Get.find<ThemeService>();
        return GetMaterialApp(
          title: 'Task Manager',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.currentTheme,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
