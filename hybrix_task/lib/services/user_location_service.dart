import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserLocationService extends ChangeNotifier {
  final userLocationCollection =
      FirebaseFirestore.instance.collection('user_report');
}
