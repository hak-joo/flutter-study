import 'dart:async';
import 'dart:math' as math;
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

  double? stayLatitude;
  double? stayLongitude;
  DateTime? stayDateTime;

  // 애플리케이션에서 지도를 이동하기 위한 컨트롤러
  late GoogleMapController _controller;

  // 지도가 시작될 때 첫 번째 위치 (강남으로 설정)
  // app이 로드되자마자 위치 추적을 시작하는 것이 아닌, Float button 클릭시 시작
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(21.017901, -128.847953));

  // 지도 클릭 시 표시할 장소에 대한 마커 목록
  // final List<Marker> markers = [];

  // addMarker(cordinate) {
  //   int id = Random().nextInt(100);

  //   setState(() {
  //     markers
  //         .add(Marker(position: cordinate, markerId: MarkerId(id.toString())));
  //   });
  // }

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
        // markers: markers.toSet(),
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
  }

  void getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

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
          print(sec);
          if (sec == 30) {
            sec = 0;
            getLocation();
            updateUserStay();
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

  double getDistance(lat1, lon1, lat2, lon2) {
    if ((lat1 == lat2) && (lon1 == lon2)) {
      return 0;
    }
    var radLat1 = math.pi * lat1 / 180;
    var radLat2 = math.pi * lat2 / 180;
    var theta = lon1 - lon2;
    var radTheta = math.pi * theta / 180;
    var dist = math.sin(radLat1) * math.sin(radLat2) +
        math.cos(radLat1) * math.cos(radLat2) * math.cos(radTheta);
    if (dist > 1) dist = 1;

    dist = math.acos(dist);
    dist = dist * 180 / math.pi;
    dist = dist * 60 * 1.1515 * 1.609344 * 1000;
    if (dist < 100)
      dist = (dist / 10).round() * 10;
    else
      dist = (dist / 100).round() * 100;
    return dist;
  }

  void updateUserStay() {
    print('update함수');
    if (stayLatitude == null && stayLongitude == null && stayDateTime == null) {
      // 정의되어 있지 않을 때 등록
      print('등록');
      setState(() {
        stayLatitude = Latitude!;
        stayLongitude = Longitude!;
        stayDateTime = DateTime.now();
      });
    } else {
      var dis =
          getDistance(Latitude!, Longitude!, stayLatitude!, stayLongitude!);
      print('distance');
      print(dis);
      if (getDistance(Latitude!, Longitude!, stayLatitude!, stayLongitude!) >
          2000) {
        //거리가 2km 벗어났다면 수행
        print('벗어남');
        var days = stayDateTime!.difference(DateTime.now()).inMinutes;
        print(days);
        setState(() {
          stayLatitude = Latitude!;
          stayLongitude = Longitude!;
          stayDateTime = DateTime.now();
        });
      }
    }
  }
}
