import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanager/app/data/models/task_model.dart';

void main() {
  group('Task', () {
    test('Task can be created', () {
      final task = Task(id: '1', name: 'Test Task', period: 'Daily', rawTime: 1200, isDone: false);
      expect(task, isNotNull);
      expect(task.id, equals('1'));
      expect(task.name, equals('Test Task'));
      expect(task.period, equals('Daily'));
      expect(task.rawTime, equals(1200));
      expect(task.isDone, equals(false));
    });

    test('Task can be converted to and from JSON', () {
      final task = Task(id: '1', name: 'Test Task', period: 'Daily', rawTime: 1200, isDone: false);
      final json = task.toJson();
      final newTask = Task.fromJson(json);
      expect(newTask, isNotNull);
      expect(newTask.id, equals('1'));
      expect(newTask.name, equals('Test Task'));
      expect(newTask.period, equals('Daily'));
      expect(newTask.rawTime, equals(1200));
      expect(newTask.isDone, equals(false));
    });
  });
}
