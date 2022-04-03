import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskmanager/Services/HiveDb.dart';
import 'package:taskmanager/locator.dart';

class TaskList extends StatefulWidget {
  final bool isfinished;
  const TaskList({Key? key, required this.isfinished}) : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  // Database object defined from locator
  var database = locator<HiveDb>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              title: widget.isfinished
                  ? const Text("Finished Tasks")
                  : const Text("Active Tasks"),
              centerTitle: true,
              bottom: TabBar(
                //unselectedLabelColor: Colors.orangeAccent,
                //labelColor: Colors.brown,
                indicatorColor: Colors.green[900],
                indicatorWeight: 5,
                //Tab items defined here
                tabs: [tabItem("Daily"), tabItem("Weekly"), tabItem("Monthly")],
              ),
            ),
            backgroundColor: Colors.blueGrey[700],
            body: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TabBarView(
                      children: [
                        listView(database.getTasks("Daily", widget.isfinished)),
                        listView(
                            database.getTasks("Weekly", widget.isfinished)),
                        listView(
                            database.getTasks("Monthly", widget.isfinished))
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }

  Widget listItem(Map<String, dynamic> task) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.white,
      child: ListTile(
        leading: widget.isfinished
            ? null
            : Icon(
                Icons.done,
                size: MediaQuery.of(context).size.width / 15,
                color: Colors.blue[900],
              ),
        title: Text(
          task["Name"],
          style:
              TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold),
        ),
        subtitle: task["Time"] != null ? Text(task["Time"]) : null,
        trailing: const Icon(Icons.delete),
      ),
    );
  }

  Widget listView(List<Map<String, dynamic>> tasks) {
    return tasks.isNotEmpty
        ? ListView.separated(
            itemBuilder: (_, index) {
              return Dismissible(
                direction: widget.isfinished
                    ? DismissDirection.endToStart
                    : DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    final bool res = await confirmDialog(tasks[index]);
                    return res;
                  } else {
                    Fluttertoast.showToast(
                        msg: "Task Finished",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    return await database
                        .addTask(tasks[index], isDone: true)
                        .then((value) => value);
                  }
                },
                secondaryBackground: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: const Center(
                    child: Text(
                      'Delete',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  color: Colors.red,
                ),
                background: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: const Center(
                    child: Text(
                      'Move To Finished',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  color: Colors.green,
                ),
                child: listItem(tasks[index]),
                key: UniqueKey(),
              );
            },
            separatorBuilder: (_, index) => const Divider(
                  color: Colors.transparent,
                ),
            itemCount: tasks.length)
        : Center(
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("No Task Created Yet!"),
                )),
          );
  }

  Future confirmDialog(Map<String, dynamic> task) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content:
                Text("Are you sure you want to delete \"${task["Name"]}\"?"),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Fluttertoast.showToast(
                      msg: "Task Deleted",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  setState(() {
                    database.deleteTask(task["ID"]);
                  });
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
  }

  Widget tabItem(String name) {
    return Tab(
      child: Text(
        name,
        style: GoogleFonts.pangolin(
            fontSize: MediaQuery.of(context).size.width / 15),
        //style: TextStyle(fontSize: MediaQuery.of(context).size.width / 15),
      ),
    );
  }
}
