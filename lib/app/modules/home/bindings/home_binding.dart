import 'package:get/get.dart';
import 'package:taskmanager/app/modules/home/controllers/home_controller.dart';

/// Binding class for the Home screen.
///
/// This class sets up the necessary dependencies, specifically the [HomeController],
/// when the Home route is accessed. Using bindings ensures that controllers are
/// created only when needed and disposed of properly when the route is removed
/// from the navigation stack (unless marked as permanent).
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Lazily initializes and registers HomeController.
    // 'lazyPut' means the controller instance is created only when it's first accessed
    // via Get.find<HomeController>(). This is efficient for resources.
    // If the controller needs to be available immediately upon route loading,
    // use Get.put(HomeController()) instead.
    Get.lazyPut<HomeController>(() => HomeController());

    // If the HomeController depended on other services specific to this module,
    // they could be initialized here as well.
    // Example: Get.lazyPut<SomeHomeService>(() => SomeHomeService());
  }
}
