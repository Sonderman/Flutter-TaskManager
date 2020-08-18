import 'package:flutter/material.dart';
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
    };
    if (myChoice == "Daily") data["Time"] = timeCon.text;
    return await locator<HiveDb>().addTask(data);
  }

  @override
  Widget build(BuildContext context) {
    localizations = MaterialLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.orange[300],
        appBar: AppBar(
          title: Text("Create Task"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await saveTask().then((value) {
                if (value) {
                  print("Successful");
                  Navigator.pop(context);
                }
              });
            },
            child: Icon(
              Icons.done,
              size: 36,
            )),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 25,
            ),
            DropdownButton<String>(
                hint: Text("Choice Time Period"),
                value: myChoice,
                items: dropdownList,
                onChanged: (choice) {
                  setState(() {
                    myChoice = choice;
                  });
                }),
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListTile(
                    title: TextField(
                      controller: nameCon,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Task Name',
                          labelStyle: TextStyle(fontSize: 20),
                          hintText: 'Enter a task name'),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
/*
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () async {
                  final datePick = await showDatePicker(
                      context: context,
                      initialDate: tempDate ?? DateTime.now(),
                      firstDate: DateTime(DateTime.now().year),
                      lastDate: DateTime(DateTime.now().year + 1),
                      selectableDayPredicate: (DateTime currentDate) {
                        if (currentDate.day >= DateTime.now().day &&
                            currentDate.month >= DateTime.now().month) {
                          return true;
                        } else
                          return false;
                      });
                  if (datePick != null) {
                    setState(() {
                      tempDate = datePick;
                      dateCon.text =
                          "${datePick.day}/${datePick.month}/${datePick.year}";
                    });
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListTile(
                      trailing: Icon(Icons.date_range),
                      title: TextField(
                        controller: dateCon,
                        enabled: false,
                        decoration: InputDecoration(
                            labelStyle: TextStyle(fontSize: 20),
                            hintText: 'Date not set'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
*/
            Visibility(
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
                          timeCon.text =
                              localizations.formatTimeOfDay(timePick);
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
                              hintText: 'Time not set'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
