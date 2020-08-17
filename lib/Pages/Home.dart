import 'package:flutter/material.dart';
import 'package:taskmanager/Pages/CreateTask.dart';
import 'package:taskmanager/Pages/FinishedTaskList.dart';
import 'package:taskmanager/Pages/TaskList.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Widget> pages = [TaskList(), FinishedTaskList()];
  List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(icon: Icon(Icons.list), title: Text("MyList")),
    BottomNavigationBarItem(icon: Icon(Icons.done_all), title: Text("Finished"))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => CreateTask()));
          }),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => setState(() {
          _currentIndex = index;
        }),
        items: bottomNavItems,
        currentIndex: _currentIndex,
      ),
    );
  }
}
