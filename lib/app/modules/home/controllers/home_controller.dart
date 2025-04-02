import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskmanager/app/data/models/task_model.dart';
import 'package:taskmanager/app/data/services/notification_service.dart'; // Import NotificationService
import 'package:taskmanager/app/data/services/storage_service.dart';
import 'package:taskmanager/app/routes/app_routes.dart';

/// Controller for the Home screen (including Task List functionality).
///
/// Manages the state for displaying tasks, handling user interactions like
/// switching between active/finished tasks, changing periods (Daily, Weekly, Monthly),
/// marking tasks as done, deleting tasks, and navigating to other screens.
/// Also handles canceling/rescheduling notifications when task status changes or task is deleted.
class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  /// Access to the storage service for task persistence.
  /// Declared as 'late final' and initialized in 'onInit' to ensure the service is ready.
  late final StorageService _storageService;

  /// Access to the notification service.
  late final NotificationService _notificationService;

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
    // Initialize services.
    _storageService = Get.find<StorageService>();
    _notificationService = Get.find<NotificationService>(); // Initialize NotificationService

    // Initialize the TabController with 3 tabs.
    // vsync: this links the TabController's animation to this controller's lifecycle.
    tabController = TabController(length: periods.length, vsync: this);
    // Load initial tasks from storage.
    _loadTasks();
    // Add a listener to the TabController to update filtered tasks when the tab changes.
    tabController.addListener(_filterTasks);
    // Add a listener to the list of all tasks. If the underlying data changes
    // (e.g., after adding/deleting a task), refilter the list.
    // _allTasks.listen((_) => _filterTasks()); // This listener might be redundant now

    // Add a listener to the bottom navigation index to refilter when switching
    // between active and finished tasks.
    currentBottomNavIndex.listen((_) => _filterTasks());

    // --- NEW: Listen to changes in StorageService ---
    _storageService.taskChangeCounter.listen((_) {
      _loadTasks();
    });
    // --- END NEW ---
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
    List<Task> currentlyFiltered =
        _allTasks.where((task) {
          return task.isDone == isFinished && task.period == selectedPeriod;
        }).toList();

    // Sort daily tasks by time
    if (selectedPeriod == "Daily") {
      currentlyFiltered.sort((a, b) {
        if (a.time != null && b.time != null) {
          return a.time!.compareTo(b.time!);
        } else if (a.time != null) {
          return -1; // a comes first
        } else if (b.time != null) {
          return 1; // b comes first
        } else {
          return 0; // no sorting needed
        }
      });
    }

    filteredTasks.assignAll(currentlyFiltered);
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
  /// Updates the task's status in the storage, refreshes the task list,
  /// and cancels or reschedules notifications if applicable.
  /// [task]: The [Task] to update.
  /// [isDone]: The new completion status.
  Future<void> markTaskAsDone(Task task, {required bool isDone}) async {
    task.isDone = isDone; // Update the task object locally first
    await _storageService.updateTask(task); // Persist the change

    // --- Handle Notifications ---
    // Check if it's a daily task with a scheduled time
    if (task.period == "Daily" && task.time != null) {
      final int notificationId = _notificationService.getNotificationId(
        task.id,
      ); // Use public method
      if (isDone) {
        // If task is marked as done, cancel the notification
        await _notificationService.cancelNotification(notificationId);
        if (kDebugMode) {
          print('Cancelled notification for task: ${task.id} (ID: $notificationId)');
        }
      } else {
        // If task is marked as active again, reschedule the notification
        await _notificationService.scheduleDailyNotification(
          taskId: task.id,
          title: task.name,
          body: 'Reminder for your daily task!',
          time: task.time!,
        );
        if (kDebugMode) {
          print(
            'Rescheduled notification for task: ${task.id} (ID: $notificationId) at ${task.time}',
          );
        }
      }
    }
    // --- End Handle Notifications ---

    // Update the local _allTasks list to trigger UI refresh via listeners.
    final index = _allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _allTasks[index] = task;
      _allTasks.refresh();
    } else {
      _loadTasks();
    }
    _filterTasks();
    Get.snackbar(
      'Success',
      '"${task.name}" marked as ${isDone ? "finished" : "active"}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isDone ? Colors.green : Colors.blue,
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
      buttonColor: Colors.red,
      onConfirm: () async {
        // Find the task before deleting to check for notification
        final taskToDelete = _allTasks.firstWhereOrNull((t) => t.id == taskId);

        try {
          Get.back(); // Close the dialog first

          // --- Cancel Notification if needed ---
          if (taskToDelete != null && taskToDelete.period == "Daily" && taskToDelete.time != null) {
            final int notificationId = _notificationService.getNotificationId(
              taskToDelete.id,
            ); // Use public method
            await _notificationService.cancelNotification(notificationId);
            if (kDebugMode) {
              print(
                'Cancelled notification for deleted task: ${taskToDelete.id} (ID: $notificationId)',
              );
            }
          }
          // --- End Cancel Notification ---

          // Proceed with deletion from storage
          await _storageService.deleteTask(taskId);
          // Remove the task from the local list to update UI
          _allTasks.removeWhere((t) => t.id == taskId);
          // _filterTasks(); // Filter is triggered by _allTasks listener now

          Get.snackbar(
            'Deleted',
            '"$taskName" has been deleted.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } catch (e) {
          // Handle any errors that occur during deletion
          Get.snackbar(
            'Error',
            'An error occurred while deleting "$taskName": ${e.toString()}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } finally {
          // Ensure the dialog is always closed
          Get.back();
        }
      },
    );
  }

  /// Navigates to the Create Task screen.
  ///
  /// Uses GetX navigation.
  /// Task list refresh is now handled reactively by listening to StorageService.
  void goToCreateTask() {
    Get.toNamed(AppRoutes.createTask);
  }

  /// Navigates to the Settings screen.
  void goToSettings() {
    Get.toNamed(AppRoutes.settings);
  }
}
