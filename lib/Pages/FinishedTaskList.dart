import 'package:flutter/material.dart';

class FinishedTaskList extends StatefulWidget {
  FinishedTaskList({Key key}) : super(key: key);

  @override
  _FinishedTaskListState createState() => _FinishedTaskListState();
}

class _FinishedTaskListState extends State<FinishedTaskList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Text("Finished"),
    ));
  }
}
