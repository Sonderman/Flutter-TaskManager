import 'package:flutter/material.dart';
import 'package:taskmanager/Pages/CreateTask.dart';
import 'package:taskmanager/Pages/TaskList.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<BottomNavigationBarItem> bottomNavItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.list), label: "Task List"),
    const BottomNavigationBarItem(
        icon: Icon(Icons.done_all), label: "Finished Tasks")
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: TaskList(
          key: UniqueKey(),
          isfinished: _currentIndex != 0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.add,
              size: MediaQuery.of(context).size.width / 15,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const CreateTask())).then((result) {
                if (result != null) {
                  setState(() {
                    print("Home ReRendered");
                  });
                }
              });
            }),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) => setState(() {
            _currentIndex = index;
          }),
          items: bottomNavItems,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.red,
          iconSize: MediaQuery.of(context).size.width / 15,
        ),
      ),
    );
  }
}
