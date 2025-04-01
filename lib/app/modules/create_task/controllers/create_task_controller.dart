import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskmanager/app/data/models/task_model.dart';
import 'package:taskmanager/app/data/services/storage_service.dart';
import 'package:uuid/uuid.dart';

/// Controller for the Create Task screen.
///
/// Manages the state of the task creation form, including text input,
/// period selection, time picking, and saving the new task.
class CreateTaskController extends GetxController {
  /// Access to the storage service for saving tasks.
  final StorageService _storageService = Get.find<StorageService>();

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
        time: selectedPeriod.value == "Daily" && timeController.text.isNotEmpty
            ? timeController.text
            : null,
        rawTime: DateTime.now().millisecondsSinceEpoch, // Timestamp for sorting
        isDone: false, // New tasks are initially not done
      );

      try {
        // Add the task using the storage service.
        await _storageService.addTask(newTask);
        // Show success message.
        Get.snackbar(
          'Success',
          'Task "${newTask.name}" created.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Navigate back to the previous screen, indicating success (result: true).
        Get.back(result: true);
      } catch (e) {
        // Show error message if saving fails.
        Get.snackbar(
          'Error',
          'Failed to save task: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('Error saving task: $e');
      }
    } else {
      print('Form validation failed.');
    }
  }

  /// Validator function for the task name input field.
  /// Returns an error message if the name is empty, otherwise returns null.
  String? validateTaskName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a task name';
    }
    return null;
  }
}
