import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'Pages/Home.dart';
import 'Services/HiveDb.dart';
import 'locator.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //get path of your database
  Directory document = await getApplicationDocumentsDirectory();

  //assing path to hive
  Hive.init(document.path);
  //sets get_it package
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(color: Colors.green[400]),
          textTheme: GoogleFonts.poppinsTextTheme()),
      home: FutureBuilder(
          future: locator<HiveDb>().initializeDb(),
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.done) {
              return const HomePage();
            } else {
              return Container(
                  color: Colors.white,
                  child: const Center(child: CircularProgressIndicator()));
            }
          }),
    );
  }
}
