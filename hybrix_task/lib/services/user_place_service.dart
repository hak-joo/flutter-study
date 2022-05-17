import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserPlaceService extends ChangeNotifier {
  final userPlaceCollection =
      FirebaseFirestore.instance.collection('user_place');

  Future<QuerySnapshot> read(String uid) async {
    return userPlaceCollection
        .where('uid', isEqualTo: uid)
        .orderBy("enddate", descending: true)
        .get()
        .catchError((error) => print(error));
  }

  void create(String uid, Timestamp startDate, Timestamp endDate,
      double latitude, double longitude) async {
    await userPlaceCollection.add(
      {
        'uid': uid,
        'startdate': startDate,
        'enddate': endDate,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    notifyListeners();
  }
}
