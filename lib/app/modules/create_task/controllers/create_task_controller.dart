import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskmanager/app/data/models/task_model.dart';
import 'package:taskmanager/app/data/services/notification_service.dart'; // Import NotificationService
import 'package:taskmanager/app/data/services/storage_service.dart';
import 'package:uuid/uuid.dart';

/// Controller for the Create Task screen.
///
/// Manages the state of the task creation form, including text input,
/// period selection, time picking, and saving the new task.
/// Also handles scheduling notifications for daily tasks with a specific time.
class CreateTaskController extends GetxController {
  /// Access to the storage service for saving tasks.
  final StorageService _storageService = Get.find<StorageService>();

  /// Access to the notification service for scheduling reminders.
  final NotificationService _notificationService = Get.find<NotificationService>();

  /// Text editing controller for the task name input field.
  final TextEditingController nameController = TextEditingController();

  /// Text editing controller for displaying the selected time (optional).
  final TextEditingController timeController = TextEditingController();

  /// Reactive variable holding the currently selected task period ("Daily", "Weekly", "Monthly").
  /// Initialized to "Daily".
  final RxString selectedPeriod = "Daily".obs;

  /// List of available period options for the dropdown.
  final List<String> periodOptions = ["Daily", "Weekly", "Monthly"];

  /// Stores the selected time of day, used by the time picker.
  TimeOfDay? selectedTime;

  /// UUID generator for creating unique task IDs.
  final Uuid _uuid = const Uuid();

  /// GlobalKey for the form, used for validation.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    // Dispose text controllers to prevent memory leaks when the controller is destroyed.
    nameController.dispose();
    timeController.dispose();
    super.onClose();
  }

  /// Changes the selected task period.
  /// [newPeriod]: The newly selected period string. Must be one of the [periodOptions].
  void changePeriod(String? newPeriod) {
    if (newPeriod != null && periodOptions.contains(newPeriod)) {
      selectedPeriod.value = newPeriod;
      // Clear time if the period is not "Daily".
      if (newPeriod != "Daily") {
        selectedTime = null;
        timeController.clear();
      }
    }
  }

  /// Shows the time picker dialog and updates the selected time.
  /// Only applicable when the selected period is "Daily".
  Future<void> pickTime(BuildContext context) async {
    // Get MaterialLocalizations for formatting the time.
    final localizations = MaterialLocalizations.of(context);
    // Show the time picker dialog.
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(), // Default to now or last selected time
    );

    // If a time was picked, update the state.
    if (pickedTime != null) {
      selectedTime = pickedTime;
      // Format the picked time (e.g., "14:30") and update the text controller.
      timeController.text = localizations.formatTimeOfDay(pickedTime);
    }
  }

  /// Validates the form and saves the new task if valid.
  Future<void> saveTask() async {
    // Validate the form using the GlobalKey.
    if (formKey.currentState!.validate()) {
      // Create a new Task object.
      final newTask = Task(
        id: _uuid.v4(), // Generate a unique ID
        name: nameController.text.trim(), // Get task name from controller
        period: selectedPeriod.value, // Get selected period
        // Include time only if the period is "Daily" and a time was selected.
        time:
            selectedPeriod.value == "Daily" && timeController.text.isNotEmpty
                ? timeController.text
                : null,
        rawTime: DateTime.now().millisecondsSinceEpoch, // Timestamp for sorting
        isDone: false, // New tasks are initially not done
      );

      try {
        // Add the task using the storage service.
        await _storageService.addTask(newTask);
        _storageService.taskChangeCounter.value++; // Notify listeners about the change

        // --- Schedule Notification ---
        // Check if it's a daily task and has a specific time set.
        if (newTask.period == "Daily" && newTask.time != null) {
          try {
            // Schedule a daily repeating notification.
            await _notificationService.scheduleDailyNotification(
              taskId: newTask.id,
              title: 'Reminder for your daily task!', // Use task name as title
              body: newTask.name,
              time: newTask.time!, // Pass the "HH:mm" time string
            );
            if (kDebugMode) {
              print('Scheduled notification for task: ${newTask.id} at ${newTask.time}');
            }
          } catch (notificationError) {
            if (kDebugMode) {
              print('Notification scheduling error: $notificationError');
            }
            // Continue even if notification fails
          }
        }
        // --- End Notification Scheduling ---

        Get.back(); // Close the create task screen
        Get.snackbar(
          'Success',
          'Task "${newTask.name}" created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        // Show error message if saving fails.
        Get.snackbar(
          'Error',
          'Failed to save task "${nameController.text}": ${e.toString().replaceAll('Exception:', '').trim()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        if (kDebugMode) {
          print('Error saving task: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('Form validation failed.');
      }
    }
  }

  /// Validator function for the task name input field.
  /// Returns an error message if the name is empty, otherwise returns null.
  String? validateTaskName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a task name';
    }
    if (value.trim().length > 50) {
      return 'Task name cannot exceed 50 characters';
    }
    return null;
  }
}
