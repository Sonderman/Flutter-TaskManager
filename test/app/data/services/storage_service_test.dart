import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskmanager/app/data/models/task_model.dart';
import 'package:taskmanager/app/data/services/storage_service.dart';

class MockGetStorage extends Mock implements GetStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('StorageService', () {
    late StorageService storageService;
    late MockGetStorage box;

    setUp(() {
      box = MockGetStorage();
      storageService = StorageService();
      storageService.box = box; // Inject the mock
    });

    test('saveTasks saves tasks to local storage', () async {
      final tasks = [
        Task(id: '1', name: 'Test Task 1', period: 'Daily', rawTime: 1200, isDone: false),
        Task(id: '2', name: 'Test Task 2', period: 'Weekly', rawTime: 1300, isDone: true),
      ];

      when(() => box.write('tasks', any())).thenAnswer((_) async => {});

      await storageService.saveTasks(tasks);

      verify(() => box.write('tasks', any())).called(1);
    });

    test('getTasks retrieves tasks from local storage', () {
      final tasks = [
        Task(id: '1', name: 'Test Task 1', period: 'Daily', rawTime: 1200, isDone: false),
        Task(id: '2', name: 'Test Task 2', period: 'Weekly', rawTime: 1300, isDone: true),
      ];
      when(
        () => box.read<List<dynamic>>('tasks'),
      ).thenReturn(tasks.map((e) => e.toJson()).toList());

      final retrievedTasks = storageService.getTasks();
      expect(retrievedTasks, isNotNull);
      expect(retrievedTasks.length, equals(2));
      expect(retrievedTasks[0].id, equals('1'));
      expect(retrievedTasks[1].name, equals('Test Task 2'));
    });
  });
}
