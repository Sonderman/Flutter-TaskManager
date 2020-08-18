import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taskmanager/Services/HiveDb.dart';
import 'package:taskmanager/locator.dart';
import 'package:uuid/uuid.dart';

class CreateTask extends StatefulWidget {
  CreateTask({Key key}) : super(key: key);

  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  TextEditingController nameCon = TextEditingController();
  TextEditingController dateCon = TextEditingController();
  TextEditingController timeCon = TextEditingController();
  String myChoice = "Daily";
  DateTime tempDate;
  TimeOfDay tempTime;
  MaterialLocalizations localizations;
  HiveDb database = locator<HiveDb>();

  List<DropdownMenuItem<String>> dropdownList = [
    DropdownMenuItem(
      child: Text("Daily"),
      value: "Daily",
    ),
    DropdownMenuItem(
      child: Text("Weekly"),
      value: "Weekly",
    ),
    DropdownMenuItem(
      child: Text("Monthly"),
      value: "Monthly",
    ),
  ];

  Future<bool> saveTask() async {
    Map<String, dynamic> data = {
      "ID": Uuid().v4(),
      "Name": nameCon.text,
      "Period": myChoice,
      "RawTime": DateTime.now().millisecondsSinceEpoch
    };
    if (myChoice == "Daily") data["Time"] = timeCon.text;
    return await database.addTask(data);
  }

  @override
  Widget build(BuildContext context) {
    localizations = MaterialLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey[700],
        appBar: AppBar(
          title: Text("Create Task"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            onPressed: () async {
              await saveTask().then((value) {
                if (value) {
                  print("Successful");
                  Fluttertoast.showToast(
                      msg: "Task Created",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  Navigator.pop(context, true);
                }
              });
            },
            child: Icon(
              Icons.done,
              size: 36,
            )),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              periodSelection(),
              SizedBox(
                height: 25,
              ),
              taskNameTextField(),
              SizedBox(
                height: 25,
              ),
              timePicker(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget periodSelection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      color: Colors.blue[300],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
            dropdownColor: Colors.blue[300],
            hint: Text("Choice Time Period"),
            value: myChoice,
            style: TextStyle(color: Colors.white, fontSize: 20),
            underline: Container(),
            items: dropdownList,
            icon: Icon(
              Icons.date_range,
              color: Colors.white,
            ),
            onChanged: (choice) {
              setState(() {
                myChoice = choice;
              });
            }),
      ),
    );
  }

  Widget timePicker(BuildContext context) {
    return Visibility(
      visible: myChoice == "Daily" ? true : false,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () async {
            await showTimePicker(
              context: context,
              initialTime: tempTime ?? TimeOfDay(hour: 12, minute: 00),
            ).then((timePick) {
              if (timePick != null) {
                tempTime = timePick;
                setState(() {
                  timeCon.text = localizations.formatTimeOfDay(timePick);
                });
              }
            });
          },
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                trailing: Icon(Icons.watch_later),
                title: TextField(
                  controller: timeCon,
                  enabled: false,
                  decoration: InputDecoration(
                      labelStyle: TextStyle(fontSize: 20),
                      hintText: 'Select Time (Optional)'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding taskNameTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListTile(
            title: TextField(
              controller: nameCon,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2)),
                  labelText: 'Task Name',
                  labelStyle: TextStyle(fontSize: 20),
                  hintText: 'Enter a task name'),
            ),
          ),
        ),
      ),
    );
  }
}
