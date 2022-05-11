// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.camera, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.paperplane, color: Colors.black))
        ],
        title: Image.asset(
          'assets/logo.png',
          height: 32,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Center(
            child: Image.network(
              "https://cdn2.thecatapi.com/images/kat_7kqBi.png",
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(CupertinoIcons.heart, color: Colors.black)),
              IconButton(
                  icon: Icon(CupertinoIcons.chat_bubble), onPressed: () {}),
              Spacer(),
              IconButton(
                icon: Icon(CupertinoIcons.bookmark, color: Colors.black),
                onPressed: () {},
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text("2 Likes", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text("My cat is docile even when bathed. I put a duck on his"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "FEBURARY 6",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
