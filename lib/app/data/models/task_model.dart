/// Represents a single task item in the application.
class Task {
  /// Unique identifier for the task.
  final String id;

  /// Name or title of the task.
  final String name;

  /// The period category for the task (e.g., "Daily", "Weekly", "Monthly").
  final String period;

  /// Optional time associated with the task, typically used for "Daily" tasks.
  /// Stored as a formatted string (e.g., "HH:mm").
  final String? time;

  /// Timestamp indicating when the task was created, used for sorting.
  final int rawTime;

  /// Flag indicating whether the task is completed.
  bool isDone;

  /// Creates a new Task instance.
  ///
  /// Requires [id], [name], [period], and [rawTime].
  /// [time] is optional. [isDone] defaults to false.
  Task({
    required this.id,
    required this.name,
    required this.period,
    this.time,
    required this.rawTime,
    this.isDone = false,
  });

  /// Creates a Task instance from a JSON map (typically from storage).
  ///
  /// Assumes the map contains keys matching the Task properties.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['ID'] as String,
      name: json['Name'] as String,
      period: json['Period'] as String,
      time: json['Time'] as String?,
      rawTime: json['RawTime'] as int,
      isDone: json['Done'] as bool? ?? false, // Handle potential null from older data
    );
  }

  /// Converts the Task instance into a JSON map for storage.
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Name': name,
      'Period': period,
      'Time': time,
      'RawTime': rawTime,
      'Done': isDone,
    };
  }
}
