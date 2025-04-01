import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskmanager/app/data/models/task_model.dart';
import 'package:taskmanager/app/data/services/storage_service.dart';
import 'package:taskmanager/app/routes/app_routes.dart';

/// Controller for the Home screen (including Task List functionality).
///
/// Manages the state for displaying tasks, handling user interactions like
/// switching between active/finished tasks, changing periods (Daily, Weekly, Monthly),
/// marking tasks as done, deleting tasks, and navigating to other screens.
class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  /// Access to the storage service for task persistence.
  /// Declared as 'late final' and initialized in 'onInit' to ensure the service is ready.
  late final StorageService _storageService;

  /// TabController for managing the Daily, Weekly, Monthly tabs.
  late TabController tabController;

  /// Reactive list containing all tasks loaded from storage.
  final RxList<Task> _allTasks = <Task>[].obs;

  /// Reactive list containing tasks filtered for the currently selected view
  /// (based on completion status and period tab).
  final RxList<Task> filteredTasks = <Task>[].obs;

  /// Reactive index for the bottom navigation bar (0: Active Tasks, 1: Finished Tasks).
  final RxInt currentBottomNavIndex = 0.obs;

  /// List of periods corresponding to the tabs.
  final List<String> periods = ["Daily", "Weekly", "Monthly"];

  @override
  void onInit() {
    super.onInit();
    // Initialize the StorageService instance.
    // This ensures we get the service only after InitialBinding has completed its async setup.
    _storageService = Get.find<StorageService>();

    // Initialize the TabController with 3 tabs.
    // vsync: this links the TabController's animation to this controller's lifecycle.
    tabController = TabController(length: periods.length, vsync: this);
    // Load initial tasks from storage.
    _loadTasks();
    // Add a listener to the TabController to update filtered tasks when the tab changes.
    tabController.addListener(_filterTasks);
    // Add a listener to the list of all tasks. If the underlying data changes
    // (e.g., after adding/deleting a task), refilter the list.
    _allTasks.listen((_) => _filterTasks());
    // Add a listener to the bottom navigation index to refilter when switching
    // between active and finished tasks.
    currentBottomNavIndex.listen((_) => _filterTasks());
  }

  @override
  void onClose() {
    // Dispose the TabController when the HomeController is destroyed to prevent memory leaks.
    tabController.dispose();
    super.onClose();
  }

  /// Loads all tasks from the StorageService into the reactive [_allTasks] list.
  void _loadTasks() {
    _allTasks.assignAll(_storageService.getTasks());
    // Initial filtering after loading tasks.
    _filterTasks(); // Call filter initially
  }

  /// Filters the [_allTasks] list based on the current bottom navigation index
  /// (completion status) and the selected tab index (period).
  /// Updates the reactive [filteredTasks] list.
  void _filterTasks() {
    // Determine the completion status based on the bottom navigation index.
    final bool isFinished = currentBottomNavIndex.value == 1;
    // Get the currently selected period from the TabController's index.
    final String selectedPeriod = periods[tabController.index];

    // Filter the tasks and update the reactive list.
    filteredTasks.assignAll(_allTasks.where((task) {
      return task.isDone == isFinished && task.period == selectedPeriod;
    }).toList());
  }

  /// Changes the selected index of the bottom navigation bar.
  ///
  /// [index]: The new index (0 for Active, 1 for Finished).
  void changeBottomNavIndex(int index) {
    currentBottomNavIndex.value = index;
    // Filtering is handled by the listener attached in onInit.
  }

  /// Marks a task as finished.
  ///
  /// Updates the task's status in the storage and refreshes the task list.
  /// [task]: The [Task] to mark as finished.
  Future<void> markTaskAsDone(Task task) async {
    task.isDone = true;
    await _storageService.updateTask(task);
    // Update the _allTasks list to trigger the listener and refilter.
    // Find the task in the main list and update its status directly.
    final index = _allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _allTasks[index] = task; // Update the item in the list
      _allTasks.refresh(); // Notify listeners
    } else {
      _loadTasks(); // Fallback: reload all tasks if not found (shouldn't happen)
    }
    Get.snackbar(
      'Success',
      '"${task.name}" marked as finished.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Deletes a task permanently.
  ///
  /// Removes the task from storage and refreshes the task list.
  /// [taskId]: The ID of the task to delete.
  /// [taskName]: The name of the task (for the confirmation message).
  Future<void> deleteTask(String taskId, String taskName) async {
    // Optional: Show confirmation dialog before deleting
    await Get.defaultDialog(
      title: "Confirm Deletion",
      middleText: "Are you sure you want to delete \"$taskName\"?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // Close the dialog first
        await _storageService.deleteTask(taskId);
        // Remove the task from the _allTasks list to trigger the listener and refilter.
        _allTasks.removeWhere((t) => t.id == taskId);
        Get.snackbar(
          'Deleted',
          '"$taskName" has been deleted.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  /// Navigates to the Create Task screen.
  ///
  /// Uses GetX navigation. Refreshes the task list when returning
  /// if a new task might have been added.
  void goToCreateTask() async {
    // Navigate to the create task route.
    var result = await Get.toNamed(AppRoutes.createTask);
    // If the CreateTask screen indicates a task was added (e.g., returns true),
    // reload the tasks.
    if (result == true) {
      _loadTasks();
    }
  }

  /// Navigates to the Settings screen.
  void goToSettings() {
    Get.toNamed(AppRoutes.settings);
  }
}
