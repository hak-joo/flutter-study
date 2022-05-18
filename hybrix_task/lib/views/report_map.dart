import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReportMap extends StatefulWidget {
  double? Latitude;
  double? Longitude;

  ReportMap(Latitude, Longitude) {
    this.Latitude = Latitude;
    this.Longitude = Longitude;
  }

  @override
  State<ReportMap> createState() => _ReportMapState(Latitude!, Longitude!);
}

class _ReportMapState extends State<ReportMap> {
  double? Latitude;
  double? Longitude;
  late GoogleMapController _controller;

  final List<Marker> markers = [];

  _ReportMapState(double Latitude, double Longitude) {
    this.Latitude = Latitude;
    this.Longitude = Longitude;
  }
  CameraPosition? _initialPosition;

  @override
  void initState() {
    setState(() {
      _initialPosition = CameraPosition(target: LatLng(Latitude!, Longitude!));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Latitude!.toString()),
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(Latitude!, Longitude!),
            zoom: 20,
          ),
          mapType: MapType.normal,
          myLocationEnabled: true,
          onMapCreated: (controller) {
            setState(() {
              _controller = controller;
              markers.add(Marker(
                  position: LatLng(Latitude!, Longitude!),
                  markerId: MarkerId("1")));
            });
          },
          markers: markers.toSet(),
        ));
  }
}
