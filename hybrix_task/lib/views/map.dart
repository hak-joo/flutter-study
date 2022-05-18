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

class Map extends StatefulWidget {
  late final String title;

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> with ChangeNotifier {
  AuthService? authService;
  UserLocationService? userLocationService;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //위젯트리 외부에서 Provider를 전달받을 수 없다.
    //수명주기를 통해 Provider와 Service들을 접근할 수 있도록 한다.
    super.didChangeDependencies();
    authService = Provider.of<AuthService>(context);
    userLocationService = Provider.of<UserLocationService>(context);
  }

  var sec = 0;
  var min = 0;
  var hour = 0;
  var isPlaying = false;

  double? Latitude;
  double? Longitude;

  // double? stayLatitude;
  // double? stayLongitude;
  // DateTime? stayDateTime;

  // 애플리케이션에서 지도를 이동하기 위한 컨트롤러
  late GoogleMapController _controller;

  // 지도가 시작될 때 첫 번째 위치 (강남으로 설정)
  // app이 로드되자마자 위치 추적을 시작하는 것이 아닌, Float button 클릭시 시작
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(37.497952, 127.027619));

  // 지도 클릭 시 표시할 장소에 대한 마커 목록
  final List<Marker> markers = [];

  addMarker(cordinate) {
    int id = 1;

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
            target: LatLng(Latitude == null ? 37.497952 : Latitude!,
                Longitude == null ? 127.027619 : Longitude!),
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
            getLocation(false);
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

  void getLocation(bool flag) async {
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
    if (Latitude == null && Longitude == null) {
      setState(() {
        Latitude = position.latitude;
        Longitude = position.longitude;
        _initialPosition =
            CameraPosition(target: LatLng(Latitude!, Longitude!));
        _controller.animateCamera(
            CameraUpdate.newLatLng(LatLng(Latitude!, Longitude!)));
      });
      userLocationService!.create(authService!.currentUser()!.uid,
          Timestamp.now(), Latitude!, Longitude!);
      print('초기 세팅');
    } else {
      if (getDistance(
              Latitude, Longitude, position.latitude, position.longitude) >
          100) {
        // 100미터 밖으로 나갔을 때 위치 재할당 후 api 호출
        print('벗어남');
        setState(() {
          Latitude = position.latitude;
          Longitude = position.longitude;
          min = 0;
          _initialPosition =
              CameraPosition(target: LatLng(Latitude!, Longitude!));
          _controller.animateCamera(
              CameraUpdate.newLatLng(LatLng(Latitude!, Longitude!)));
        });
        userLocationService!.create(authService!.currentUser()!.uid,
            Timestamp.now(), Latitude!, Longitude!);
      } else {
        //거리가 유지되었고 1시간마다 수행할 때
        if (flag == true) {
          userLocationService!.create(authService!.currentUser()!.uid,
              Timestamp.now(), Latitude!, Longitude!);
        }
      }
    }
  }

  void start() {
    getLocation(false);

    timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (isPlaying == true) {
        setState(() {
          sec++;
          print(sec);
          if (sec == 60) {
            sec = 0;
            min++;
            getLocation(false);
            if (min == 60) {
              getLocation(true);
              min = 0;
              hour++;
            }

            if (hour == 24) {
              hour = 0;
            }
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

  // void updateUserStay() {
  //   print('update함수');
  //   if (stayLatitude == null && stayLongitude == null && stayDateTime == null) {
  //     // 정의되어 있지 않을 때 등록
  //     print('등록');
  //     setState(() {
  //       stayLatitude = Latitude!;
  //       stayLongitude = Longitude!;
  //       stayDateTime = DateTime.now();
  //     });
  //   } else {
  //     var dis =
  //         getDistance(Latitude!, Longitude!, stayLatitude!, stayLongitude!);
  //     print(dis);
  //     if (getDistance(Latitude!, Longitude!, stayLatitude!, stayLongitude!) >
  //         750) {
  //       //거리가 750M 넘어갔을 때
  //       var days = DateTime.now().difference(stayDateTime!).inMinutes;
  //       print('차이 시간');
  //       print(days);
  //       setState(() {
  //         stayLatitude = Latitude!;
  //         stayLongitude = Longitude!;
  //         stayDateTime = DateTime.now();
  //       });
  //     }
  //   }
  // }
}
