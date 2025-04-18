import 'package:flutter/foundation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart'; // Import RxInt
import 'package:get_storage/get_storage.dart';
import 'package:taskmanager/app/data/models/task_model.dart';
import 'package:taskmanager/app_config.dart';

/// Service class for managing task data persistence using GetStorage.
///
/// Provides methods to initialize storage, add, retrieve, update, and delete tasks.
class StorageService {
  /// The GetStorage container instance used for storing tasks.
  late final GetStorage box;

  /// Reactive counter to notify listeners of data changes.
  final RxInt taskChangeCounter = 0.obs;

  StorageService() {
    box = GetStorage();
  }

  /// Retrieves all tasks currently stored.
  ///
  /// Returns a list of [Task] objects. If no tasks are stored, returns an empty list.
  List<Task> getTasks() {
    // Read the raw data from storage using the _tasksKey.
    // It's expected to be a List<dynamic>, where each element is a Map<String, dynamic>.
    final List<dynamic>? tasksData = box.read<List<dynamic>>(tasksKey);

    if (tasksData != null) {
      try {
        // Convert the list of maps into a list of Task objects.
        return tasksData
            .map((taskJson) => Task.fromJson(taskJson as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // Handle potential errors during JSON deserialization (e.g., corrupted data).

        // Optionally clear corrupted data: box.remove(_tasksKey);
        return [];
      }
    } else {
      // If no data exists for the key, return an empty list.
      return [];
    }
  }

  /// Saves the entire list of tasks to storage.
  ///
  /// This method overwrites any existing task list.
  /// It's typically called after adding, updating, or deleting a task.
  /// [tasks]: The list of [Task] objects to save.
  Future<void> saveTasks(List<Task> tasks) async {
    // Convert the list of Task objects into a list of JSON maps.
    final List<Map<String, dynamic>> tasksData = tasks.map((task) => task.toJson()).toList();
    // Write the list of maps to storage under the _tasksKey.
    await box.write(tasksKey, tasksData);
  }

  /// Adds a new task to the storage.
  ///
  /// [task]: The [Task] object to add.
  Future<void> addTask(Task task) async {
    // Retrieve the current list of tasks.
    final List<Task> tasks = getTasks();
    // Add the new task to the list.
    tasks.add(task);
    // Save the updated list back to storage.
    await saveTasks(tasks);
    // Notify listeners
    taskChangeCounter.value++;
  }

  /// Updates an existing task in the storage.
  ///
  /// Finds the task by its ID and replaces it with the updated [task] object.
  /// [task]: The updated [Task] object.
  Future<void> updateTask(Task task) async {
    // Retrieve the current list of tasks.
    final List<Task> tasks = getTasks();
    // Find the index of the task with the matching ID.
    final int index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      // If found, replace the task at that index.
      tasks[index] = task;
      // Save the updated list back to storage.
      await saveTasks(tasks);
      // Notify listeners
      taskChangeCounter.value++;
      if (kDebugMode) {
        print('Task updated: ${task.id}');
      }
    } else {
      if (kDebugMode) {
        print('Task update failed: ID ${task.id} not found.');
      }
    }
  }

  /// Deletes a task from storage based on its ID.
  ///
  /// [taskId]: The unique ID of the task to delete.
  Future<void> deleteTask(String taskId) async {
    // Retrieve the current list of tasks.
    final List<Task> tasks = getTasks();
    // Remove the task with the matching ID from the list.
    tasks.removeWhere((t) => t.id == taskId);
    // Save the updated list back to storage.
    await saveTasks(tasks);
    // Notify listeners
    taskChangeCounter.value++;
    if (kDebugMode) {
      print('Task deleted: $taskId');
    }
  }

  /// Clears all tasks from storage.
  ///
  /// Use with caution as this permanently removes all task data.
  Future<void> clearAllTasks() async {
    await box.remove(tasksKey);
    // Notify listeners
    taskChangeCounter.value++;
    if (kDebugMode) {
      print('All tasks cleared.');
    }
  }
}
