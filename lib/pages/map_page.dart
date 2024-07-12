import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late GoogleMapController _mapController;
  Set<Circle> _dangerousAreas = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentPosition;
  LatLng? _startLocation;
  LatLng? _endLocation;
  String _startAddress = '';
  String _endAddress = '';

  @override
  void initState() {
    super.initState();
    _initializeRealTimeUpdates();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to get current location: $e');
    }
  }

  Future<void> _initializeRealTimeUpdates() async {
    _firestore.collection('reports').snapshots().listen((snapshot) {
      List<QueryDocumentSnapshot> documents = snapshot.docs;
      Map<LatLng, List<GeoPoint>> reportClusters = {};

      for (var doc in documents) {
        GeoPoint geoPoint = doc['location'];
        LatLng latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

        bool addedToCluster = false;

        reportClusters.forEach((existingLatLng, points) {
          double distance = Geolocator.distanceBetween(
            latLng.latitude,
            latLng.longitude,
            existingLatLng.latitude,
            existingLatLng.longitude,
          );

          if (distance < 20) {
            points.add(geoPoint);
            addedToCluster = true;
          }
        });

        if (!addedToCluster) {
          reportClusters[latLng] = [geoPoint];
        }
      }

      _generateDangerousAreas(reportClusters);
    });
  }

  void _generateDangerousAreas(Map<LatLng, List<GeoPoint>> reportClusters) {
    Set<Circle> circles = reportClusters.entries.where((entry) {
      return entry.value.length >= 3;
    }).map((entry) {
      LatLng position = entry.key;
      int count = entry.value.length;

      double opacity = (count > 5) ? 1.0 : (count * 0.2);
      double radius = 50; // Radius in meters

      return Circle(
        circleId: CircleId(position.toString()),
        center: position,
        radius: radius,
        fillColor: Colors.red.withOpacity(opacity),
        strokeColor: Colors.red.withOpacity(opacity),
        strokeWidth: 1,
      );
    }).toSet();

    setState(() {
      _dangerousAreas = circles;
    });
  }

  Future<void> _calculateAndDisplayRoute() async {
    if (_startLocation == null || _endLocation == null) {
      Fluttertoast.showToast(msg: 'Please select both start and end locations');
      return;
    }

    final String directionsUrl =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${_startLocation!.latitude},${_startLocation!.longitude}'
        '&destination=${_endLocation!.latitude},${_endLocation!.longitude}'
        '&key=AIzaSyDHbXQWMe2xNwJiyaLRlWH4B0WdE9dyc-E';

    try {
      final response = await http.get(Uri.parse(directionsUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          List<LatLng> polylineCoordinates = [];
          data['routes'][0]['legs'][0]['steps'].forEach((step) {
            polylineCoordinates.add(LatLng(
              step['start_location']['lat'],
              step['start_location']['lng'],
            ));
            polylineCoordinates.add(LatLng(
              step['end_location']['lat'],
              step['end_location']['lng'],
            ));
          });

          // Check if any of the polyline points intersect with dangerous areas
          bool isSafeRoute = true;
          for (var point in polylineCoordinates) {
            for (var circle in _dangerousAreas) {
              double distance = Geolocator.distanceBetween(
                point.latitude,
                point.longitude,
                circle.center.latitude,
                circle.center.longitude,
              );
              if (distance < circle.radius) {
                isSafeRoute = false;
                break;
              }
            }
            if (!isSafeRoute) break;
          }

          if (isSafeRoute) {
            setState(() {
              _polylines.add(Polyline(
                polylineId: PolylineId('safe_route'),
                color: Colors.blue,
                width: 5,
                points: polylineCoordinates,
              ));
            });
            Fluttertoast.showToast(msg: 'Safe route found');
          } else {
            Fluttertoast.showToast(
                msg: 'No safe route found, please try another route');
          }
        } else {
          Fluttertoast.showToast(
              msg: 'Directions API error: ${data['status']}');
        }
      } else {
        Fluttertoast.showToast(
            msg: 'Failed to fetch directions: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching directions: $e');
    }
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      if (_startLocation == null) {
        _startLocation = latLng;
        _startAddress = 'Start Point';
      } else if (_endLocation == null) {
        _endLocation = latLng;
        _endAddress = 'End Point';
      }
    });
  }

  void _removeMarker(LatLng latLng) {
    setState(() {
      if (_startLocation != null && _startLocation == latLng) {
        _startLocation = null;
        _startAddress = '';
      } else if (_endLocation != null && _endLocation == latLng) {
        _endLocation = null;
        _endAddress = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _currentPosition == null
                    ? Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        onTap: _onMapTap,
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition!,
                          zoom: 15,
                        ),
                        circles: _dangerousAreas,
                        markers: {
                          if (_startLocation != null)
                            Marker(
                              markerId: MarkerId('start'),
                              position: _startLocation!,
                              infoWindow: InfoWindow(title: 'Start'),
                              onTap: () => _removeMarker(_startLocation!),
                            ),
                          if (_endLocation != null)
                            Marker(
                              markerId: MarkerId('end'),
                              position: _endLocation!,
                              infoWindow: InfoWindow(title: 'End'),
                              onTap: () => _removeMarker(_endLocation!),
                            ),
                        },
                        polylines: _polylines,
                      ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: ElevatedButton(
                onPressed: _calculateAndDisplayRoute,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child:
                      Text('Calculate Route', style: TextStyle(fontSize: 18)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue, // Set your preferred button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Adjust as needed
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
