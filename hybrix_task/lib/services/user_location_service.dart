import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserLocationService extends ChangeNotifier {
  final userLocationCollection =
      FirebaseFirestore.instance.collection('user_report');

  Future<QuerySnapshot> read(String uid) async {
    return userLocationCollection
        .where('uid', isEqualTo: uid)
        .orderBy("timestamp", descending: true)
        .get()
        .catchError((error) => print(error));
  }

  Future<QuerySnapshot> readWithDate(String uid, DateTime date) async {
    DateTime _now = date;
    DateTime _start = DateTime(_now.year, _now.month, _now.day, 0, 0);
    DateTime _end = DateTime(_now.year, _now.month, _now.day, 23, 59, 59);
    return userLocationCollection
        .where('uid', isEqualTo: uid)
        .where('timestamp', isGreaterThanOrEqualTo: _start)
        .where('timestamp', isLessThanOrEqualTo: _end)
        .orderBy("timestamp", descending: true)
        .get()
        .catchError((error) => print(error));
  }

  void create(String uid, Timestamp timestamp, double latitude,
      double longitude) async {
    await userLocationCollection.add(
      {
        'uid': uid,
        'timestamp': timestamp,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    notifyListeners();
  }
}
