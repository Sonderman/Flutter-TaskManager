import 'package:flutter/material.dart';
import 'package:taskmanager/Services/HiveDb.dart';
import 'package:taskmanager/locator.dart';

class TaskList extends StatefulWidget {
  final bool isfinished;
  TaskList({Key key, @required this.isfinished}) : super(key: key);

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
            backgroundColor: Colors.grey,
            body: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                TabBar(
                  indicatorColor: Colors.red,
                  indicatorWeight: 5,
                  //Tab items defined here
                  tabs: [
                    tabItem("Daily"),
                    tabItem("Weekly"),
                    tabItem("Monthly")
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      color: Colors.orange,
                      //Tab pages defined here
                      child: TabBarView(
                        children: [
                          listView(
                              database.getTasks("Daily", widget.isfinished)),
                          listView(
                              database.getTasks("Weekly", widget.isfinished)),
                          listView(
                              database.getTasks("Monthly", widget.isfinished))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )));
  }

  Widget listItem(Map<String, dynamic> task) {
    return ListTile(
      leading: widget.isfinished ? null : Icon(Icons.done),
      title: widget.isfinished
          ? Text(task["Name"] + " (Finished)")
          : Text(task["Name"]),
      subtitle: task["Time"] != null ? Text(task["Time"]) : null,
      trailing: widget.isfinished ? null : Icon(Icons.delete),
    );
  }

  Widget listView(List<Map<String, dynamic>> tasks) {
    return tasks.length != 0
        ? ListView.separated(
            itemBuilder: (_, index) {
              return widget.isfinished
                  ? listItem(tasks[index])
                  : Dismissible(
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          final bool res = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Text(
                                      "Are you sure you want to delete \"${tasks[index]["Name"]}\"?"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          database
                                              .deleteTask(tasks[index]["ID"]);
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                          return res;
                        } else {
                          return await database
                              .addTask(tasks[index], isDone: true)
                              .then((value) => value);
                        }
                      },
                      secondaryBackground: Container(
                        child: Center(
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        color: Colors.red,
                      ),
                      background: Container(
                        child: Center(
                          child: Text(
                            'Move To Finished',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        color: Colors.green,
                      ),
                      child: listItem(tasks[index]),
                      key: UniqueKey(),
                    );
            },
            separatorBuilder: (_, index) => Divider(
                  height: 15,
                ),
            itemCount: tasks.length)
        : Center(
            child: Text("No Task Created Yet!"),
          );
  }

  Widget tabItem(String name) {
    return Text(
      name,
      style: TextStyle(fontSize: 32),
    );
  }
}
