import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hybrix_task/services/auth_service.dart';
import 'package:hybrix_task/services/user_location_service.dart';
import 'package:provider/provider.dart';

Timer? timer;

class MapSample extends StatefulWidget {
  late final String title;

  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> with ChangeNotifier {
  AuthService? authService;
  UserLocationService? userLocationService;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //위젯트리 외부에서 Provider를 전달받을 수 없다.
    //수명주기를 통해 Provider와 Service들을 접근할 수 있도록 한다. init
    super.didChangeDependencies();
    authService = Provider.of<AuthService>(context);
    userLocationService = Provider.of<UserLocationService>(context);
  }

  var sec = 0;
  var min = 0;
  var hour = 0;
  var isPlaying = false;

  double? Latitude = 37.497952;
  double? Longitude = 127.027619;

  // 애플리케이션에서 지도를 이동하기 위한 컨트롤러
  late GoogleMapController _controller;

  // 지도가 시작될 때 첫 번째 위치 (강남으로 설정)
  // app이 로드되자마자 위치 추적을 시작하는 것이 아닌, Float button 클릭시 시작
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
          setState(() {
            isPlaying = !isPlaying;
          });
          if (isPlaying == true) {
            getLocation();
            start();
          }
        },
        child: Icon(
          Icons.my_location,
          color: isPlaying ? Colors.green : Colors.black,
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
      _controller
          .animateCamera(CameraUpdate.newLatLng(LatLng(Latitude!, Longitude!)));
    });
  }

  void start() {
    getLocation();

    timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (isPlaying == true) {
        setState(() {
          sec++;
          if (sec == 60) {
            sec = 0;
            getLocation();
            min++;

            if (min == 60) {
              min = 0;
              hour++;
            }

            if (hour == 24) {
              hour = 0;
            }
          }
          if (sec == 0) {
            userLocationService!.create(authService!.currentUser()!.uid,
                Timestamp.now(), Latitude!, Longitude!);
            print('send API');
          }
        });
      } else {
        timer.cancel();
      }
    });
  }
}
