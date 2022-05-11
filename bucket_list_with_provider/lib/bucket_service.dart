import 'package:flutter/material.dart';
import 'main.dart';

class BucketService extends ChangeNotifier {
  List<Bucket> bucketList = [
    Bucket('잠자기', false),
  ];

  void createBucket(String job) {
    bucketList.add(Bucket(job, false));
    notifyListeners();
  }

  void updateBucket(Bucket bucket, int index) {
    bucketList[index] = bucket;
    notifyListeners();
  }

  void deleteBucket(int index) {
    bucketList.removeAt(index);
    notifyListeners();
  }
}
