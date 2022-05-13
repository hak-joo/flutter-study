import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import './map.dart';

bool? _serviceEnabled;

class UserLocation extends StatefulWidget {
  UserLocation({Key? key}) : super(key: key);

  @override
  State<UserLocation> createState() => _UserLocationState();
}

class _UserLocationState extends State<UserLocation> {
  var sec = 0;
  var min = 0;
  var hour = 0;
  var isPlaying = false;
  Timer? timer;
  double? Latitude;
  double? Longitude;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getTimer(),
              Container(
                padding: const EdgeInsets.only(left: 10),
                width: 50,
                height: 50,
                child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        isPlaying = !isPlaying;
                        if (isPlaying == true) {
                          start();
                        } else {
                          pause();
                        }
                      });
                    },
                    child: Icon(isPlaying ? Icons.pause : Icons.play_arrow)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void click() {
    if (isPlaying == true) {}
  }

  void pause() {
    timer?.cancel();
  }

  void start() {
    timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      setState(() {
        sec++;
        if (sec == 60) {
          sec = 0;
          getLocation();
          min++;
        }
        if (min == 60) {
          min = 0;
          hour++;
        }
        if (hour == 24) {
          hour = 0;
        }
      });
    });
  }

  Widget getTimer() {
    return (Row(
      children: [
        Text(
          hour < 10 ? '0$hour:' : '$hour:',
          style: TextStyle(fontSize: 40),
        ),
        Text(
          min < 10 ? '0$min:' : '$min:',
          style: TextStyle(fontSize: 40),
        ),
        Text(
          sec < 10 ? '0$sec' : '$sec',
          style: TextStyle(fontSize: 40),
        ),
      ],
    ));
  }

  void getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    Latitude = position.latitude;
    Longitude = position.longitude;
  }
}
