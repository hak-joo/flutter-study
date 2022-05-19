import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hybrix_task/services/auth_service.dart';
import 'package:hybrix_task/views/login.dart';
import 'package:hybrix_task/views/map.dart';
import 'package:hybrix_task/views/user_report.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    //로그인 여부를 확인하기 위한 Consumer.
    return Consumer<AuthService>(builder: (context, authService, child) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.green),
        home: Scaffold(
          appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthService>().signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
              title: Text("Leehakjoo"),
              actions: [
                IconButton(
                  icon: Icon(CupertinoIcons.list_dash),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserReport()),
                    );
                  },
                )
              ]),
          body: Map(),
        ),
      );
    });
  }
}
