import 'package:hive/hive.dart';

class HiveDb {
  //global database variable defined here
  Box? taskBox;

  Future<void> initializeDb() async {
    if (!Hive.isBoxOpen("Tasks")) {
      await Hive.openBox("Tasks").then((box) {
        taskBox = box;
      });
    }
  }

  Future<bool?> addTask(Map<String, dynamic> task,
      {bool isDone = false}) async {
    task["Done"] = isDone;
    try {
      return await taskBox?.put(task["ID"], task).then((value) => true);
    } catch (e) {
      print(e);
      return false;
    }
  }

  List<Map<String, dynamic>> getTasks(String period, bool isfinished) {
    try {
      //print(taskBox.values.toList());
      List<Map<String, dynamic>> taskData = [];
      taskBox?.values
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
          .forEach((map) {
        if (map.containsValue(period) && map["Done"] == isfinished) {
          taskData.add(map);
        }
      });
/*
      for (var i = 0; i < taskData.length; i++) {
        for (var j = 0; j < taskData.length; j++) {
          if(taskData[i]!=taskData[j])
          if (taskData[i]["RawTime"] < taskData[j]["RawTime"]) {
            var temp=taskData[j];
            
          }
        }
      }
*/
      return taskData;
    } catch (e) {
      print(e);
      return [];
    }
  }

  void deleteTask(String key) {
    try {
      //taskBox.deleteFromDisk();
      taskBox?.delete(key);
    } catch (e) {
      print(e);
    }
  }
}
