import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  late final String title;

  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  @override
  void initState() {
    super.initState();
    start();
  }

  var sec = 0;
  var min = 0;
  var hour = 0;
  var isPlaying = false;
  Timer? timer;
  double? Latitude;
  double? Longitude;

  // 애플리케이션에서 지도를 이동하기 위한 컨트롤러
  late GoogleMapController _controller;

  // 이 값은 지도가 시작될 때 첫 번째 위치입니다.
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(21.017901, -128.847953));

  // 지도 클릭 시 표시할 장소에 대한 마커 목록
  final List<Marker> markers = [];

  addMarker(cordinate) {
    int id = Random().nextInt(100);

    setState(() {
      markers
          .add(Marker(position: cordinate, markerId: MarkerId(id.toString())));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(
              Latitude!,
              Longitude!,
            ),
            zoom: 17),
        mapType: MapType.normal,
        myLocationEnabled: true,
        onMapCreated: (controller) {
          setState(() {
            _controller = controller;
          });
        },
        markers: markers.toSet(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getLocation();

          _controller.animateCamera(
              CameraUpdate.newLatLng(LatLng(Latitude!, Longitude!)));
        },
        child: Icon(
          Icons.my_location,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
      ),
    );

    // floatingActionButton 클릭시 줌 아웃
  }

  void getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      Latitude = position.latitude;
      Longitude = position.longitude;
      _initialPosition = CameraPosition(target: LatLng(Latitude!, Longitude!));
    });
    print(Latitude);
    print(Longitude);
  }

  void start() {
    getLocation();
    timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      print(sec);
      setState(() {
        sec++;
        if (sec == 10) {
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
}
