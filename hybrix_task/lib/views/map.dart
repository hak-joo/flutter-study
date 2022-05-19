import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
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
  void dispose() {
    _controller.dispose();
    timer ?? timer!.cancel();
  }

  @override
  void didChangeDependencies() {
    /* 위젯트리 외부에서 Provider를 전달받을 수 없다.
    api 호출하는 함수가 외부에 있기 때문에,
    수명주기를 통해 Provider와 Service들을 접근할 수 있도록 한다. */
    super.didChangeDependencies();
    authService = Provider.of<AuthService>(context);
    userLocationService = Provider.of<UserLocationService>(context);
  }

  var sec = 0;
  var isPlaying = false;

  double? Latitude;
  double? Longitude;

  // 애플리케이션에서 지도를 이동하기 위한 컨트롤러
  late GoogleMapController _controller;

  // 지도가 시작될 때 첫 번째 위치 (강남으로 설정)
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(37.497952, 127.027619));

  // 지도 클릭 시 표시할 장소에 대한 마커 목록
  final List<Marker> markers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        //초기 위치 설정
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
      ),
      //기록 시작/중지 버튼. 시작 시 아이콘 색 변경
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

  /* 위치를 받아오고 조건에 따라 처리하는 함수
    flag는 offset에 상관없이 사용자의 위치를 저장하기 위해 설정 (60분 마다 위치 저장) */
  void getLocation(bool flag) async {
    bool serviceEnabled;
    LocationPermission permission;

    //권한 확인
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
    // 권한 확인 완료 후, 사용자의 위치를 받아온다. latitude, longitude
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // 처음 위치 측정이 시작되었을 때
    if (Latitude == null && Longitude == null) {
      setState(() {
        Latitude = position.latitude;
        Longitude = position.longitude;
        _initialPosition =
            CameraPosition(target: LatLng(Latitude!, Longitude!));
        _controller.animateCamera(
            CameraUpdate.newLatLng(LatLng(Latitude!, Longitude!)));
      });
      // api 호출 후 위치 정보 저장
      userLocationService!.create(authService!.currentUser()!.uid,
          Timestamp.now(), Latitude!, Longitude!);
    } else {
      // 100미터 밖으로 나갔을 때 위치 재할당 후 api 호출
      if (getDistance(
              Latitude, Longitude, position.latitude, position.longitude) >
          100) {
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
      } else {
        //거리가 유지되었고 1시간마다 수행할 때 (flag == true)
        if (flag == true) {
          userLocationService!.create(authService!.currentUser()!.uid,
              Timestamp.now(), Latitude!, Longitude!);
        }
      }
    }
  }

  //floating button 클릭시 호출.
  void start() {
    getLocation(false);
    // 1초마다 수행되도록 한다.
    timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (isPlaying == true) {
        setState(() {
          sec++;
          print(sec);
          if (sec % 60 == 0) {
            // 1시간마다 flag true 를 통해 바로 저장될 수 있도록 한다.
            if (sec % 3600 == 0) {
              getLocation(true);
            }
            // 1분마다 위치 확인
            else {
              getLocation(false);
            }
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  // 두 개의 위도 경도 정보를 이용하여 두 좌표의 거리를 구한다. 단위는 m
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
}
