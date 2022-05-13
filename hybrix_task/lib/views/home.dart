import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hybrix_task/views/location.dart';
import 'package:hybrix_task/views/map.dart';
import 'package:hybrix_task/views/user_report.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(CupertinoIcons.list_dash),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserReport()),
                );
              },
            ),
            title: Text("Leehakjoo"),
            actions: [
              IconButton(
                icon: Icon(CupertinoIcons.person_crop_square),
                onPressed: () {},
              )
            ]),
        body: MapSample(),
      ),
    );
  }
}
