import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hybrix_task/views/location.dart';
import 'package:hybrix_task/views/map.dart';

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
        home: DefaultTabController(
            length: 1,
            child: Scaffold(
                appBar: AppBar(
                    title: Text("Leehakjoo"),
                    bottom: TabBar(
                      tabs: [
                        // Tab(icon: Icon(CupertinoIcons.location_circle_fill)),
                        // Tab(icon: Icon(CupertinoIcons.square_list_fill)),
                        Tab(icon: Icon(Icons.cloud)),
                      ],
                    )),
                body: TabBarView(
                  children: [
                    // UserLocation(),
                    MapSample(),
                    // Center(child: Text("Data")),
                  ],
                ))));
  }
}
