import 'package:flutter/material.dart';

class TaskList extends StatefulWidget {
  TaskList({Key key}) : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Text("List"),
    ));
  }
}
