import 'package:get/get.dart';
import 'package:taskmanager/app/modules/create_task/controllers/create_task_controller.dart';

/// Binding class for the Create Task screen.
///
/// Sets up the [CreateTaskController] when the Create Task route is accessed.
class CreateTaskBinding extends Bindings {
  @override
  void dependencies() {
    // Lazily initializes and registers CreateTaskController.
    Get.lazyPut<CreateTaskController>(
      () => CreateTaskController(),
    );
  }
}
