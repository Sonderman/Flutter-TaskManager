import 'package:flutter/material.dart';
import 'package:taskmanager/Services/HiveDb.dart';
import 'package:taskmanager/locator.dart';

class TaskList extends StatefulWidget {
  TaskList({Key key}) : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  var database = locator<HiveDb>();
  Widget listItem() {
    return Card(
      margin: EdgeInsets.all(10),
      color: Colors.grey,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.07,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Task name"),
              Spacer(),
              Row(
                children: [Text("Tarih|"), Text("|Saat")],
              )
            ],
          ),
        ),
      ),
    );
  }

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
                      child: TabBarView(
                        children: [
                          listView(database.getTasks("Daily")),
                          listView(database.getTasks("Weekly")),
                          listView(database.getTasks("Monthly"))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ))
        /*
        ListView.builder(
            itemCount: 10,
            itemBuilder: (_, index) {
              return listItem();
            }),*/

        );
  }

  Widget listView(List<Map<String, dynamic>> tasks) {
    return ListView.separated(
        itemBuilder: (_, index) {
          return Dismissible(
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
                                database.deleteTask(tasks[index]["ID"]);
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
                return res;
              } else {
                return false;
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
            child: ListTile(
              leading: Icon(Icons.done),
              title: Text(tasks[index]["Name"]),
              subtitle: tasks[index]["Time"] != null
                  ? Text(tasks[index]["Time"])
                  : null,
              trailing: Icon(Icons.delete),
            ),
            key: UniqueKey(),
          );
        },
        separatorBuilder: (_, index) => Divider(
              height: 15,
            ),
        itemCount: tasks.length);
  }

  Widget tabItem(String name) {
    return Text(
      name,
      style: TextStyle(fontSize: 32),
    );
  }
}
