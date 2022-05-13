import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hybrix_task/services/auth_service.dart';
import 'package:hybrix_task/services/user_location_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class UserReport extends StatefulWidget {
  const UserReport({Key? key}) : super(key: key);

  @override
  State<UserReport> createState() => _UserReportState();
}

class _UserReportState extends State<UserReport> {
  List<dynamic> locationList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserLocationService>(
        builder: (context, userLocationService, child) {
      final authService = context.read<AuthService>();
      User user = authService.currentUser()!;
      return Scaffold(
        appBar: AppBar(
          title: Text("Location Logs"),
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: userLocationService.read(user.uid),
                builder: (context, snapshot) {
                  final items = snapshot.data?.docs ?? [];
                  if (items.isEmpty) {
                    return Center(child: Text("기록된 내용이 없습니다"));
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      Timestamp timestamp = item.get('timestamp');
                      double latitude = item.get('latitude');
                      double longitude = item.get('longitude');
                      return ListTile(title: Text(timestampToDate(timestamp)));
                      // return ListTile(title: Text(timestamp.toString()));
                    },
                  );
                },
              ),
            )
          ],
        ),
      );
    });
  }

  String timestampToDate(Timestamp timestamp) {
    final f = new DateFormat("yyyy년 MM월 dd일 hh시 mm분 ss초");
    var date = DateTime.parse(timestamp.toDate().toString());
    return f.format(date).toString();
  }
}
