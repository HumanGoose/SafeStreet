import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safestreet/services/database_service.dart';
import 'package:safestreet/models/reports.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  LatLng? _initialCameraPosition;
  bool _locationServiceEnabled = false;
  bool _locationPermissionGranted = false;
  bool _isLoading = true;
  Marker? _selectedMarker;
  LatLng? _selectedLatLng;
  late GoogleMapController _mapController;
  bool _showReportCard = false;
  Map<String, bool> _reportOptions = {
    'Catcalling': false,
    'Stalking': false,
    'No Streetlamps': false,
  };

  final DatabaseService _databaseService = DatabaseService();
  Set<Circle> _reportCircles = {};

  @override
  void initState() {
    super.initState();
    _getLocationPermission();
    _initializeRealTimeUpdates();
  }

  Future<void> _getLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Location services are disabled');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: 'Location permissions are permanently denied');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _locationServiceEnabled = serviceEnabled;
      _locationPermissionGranted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    });

    if (_locationPermissionGranted) {
      await _getCurrentLocation();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialCameraPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to get current location');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedMarker = Marker(
        markerId: MarkerId('selected_location'),
        position: position,
      );
      _selectedLatLng = position;
      _showReportCard = false;
    });
  }

  @override
  void dispose() {
    // Cancel timers, animations, or any ongoing processes
    super.dispose();
  }

  void _showReportDialog() {
    setState(() {
      _showReportCard = true;
    });
  }

  void _submitReport() {
    if (_reportOptions.values.every((value) => !value)) {
      Fluttertoast.showToast(msg: 'Please select at least one option');
      return;
    }

    sendDataToDb();
    setState(() {
      _showReportCard = false;
      _selectedMarker = null; // Remove the pin after reporting
    });
    Fluttertoast.showToast(
        msg: 'Successfully Reported! Thank you for making the world safer!');
  }

  void _initializeRealTimeUpdates() {
    FirebaseFirestore.instance
        .collection('reports')
        .snapshots()
        .listen((snapshot) {
      List<QueryDocumentSnapshot> documents = snapshot.docs;
      Map<LatLng, List<GeoPoint>> reportClusters = {};

      for (var doc in documents) {
        GeoPoint geoPoint = doc['location'];
        LatLng latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

        // Flag to check if the point was added to an existing cluster
        bool addedToCluster = false;

        // Check for nearby clusters
        reportClusters.forEach((existingLatLng, points) {
          double distance = Geolocator.distanceBetween(
            latLng.latitude,
            latLng.longitude,
            existingLatLng.latitude,
            existingLatLng.longitude,
          );

          if (distance < 20) {
            // Distance threshold in meters
            points.add(geoPoint);
            addedToCluster = true;
          }
        });

        // If not added to any cluster, create a new cluster
        if (!addedToCluster) {
          reportClusters[latLng] = [geoPoint];
        }
      }

      // Generate report circles based on clusters
      _generateReportCircles(reportClusters);
    });
  }

  void _generateReportCircles(Map<LatLng, List<GeoPoint>> reportClusters) {
    Set<Circle> circles = reportClusters.entries.where((entry) {
      return entry.value.length >=
          3; // Only include clusters with at least 3 reports
    }).map((entry) {
      LatLng position = entry.key;
      int count = entry.value.length;

      double opacity = (count > 5)
          ? 1.0
          : (count * 0.2); // Adjust opacity based on the count
      double radius = 50; // Fixed radius in meters

      return Circle(
        circleId: CircleId(position.toString()),
        center: position,
        radius: radius, // Fixed radius in meters
        fillColor: Colors.red.withOpacity(opacity),
        strokeColor: Colors.red.withOpacity(opacity),
        strokeWidth: 1,
      );
    }).toSet();

    setState(() {
      _reportCircles = circles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _locationServiceEnabled && _locationPermissionGranted
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _initialCameraPosition!,
                        zoom: 18,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers:
                          _selectedMarker != null ? {_selectedMarker!} : {},
                      circles: _reportCircles,
                      onTap: _onMapTapped,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                    )
                  : Center(
                      child: Text('Location permissions are not granted'),
                    ),
          if (_selectedMarker != null)
            Positioned(
              bottom: 20,
              left: MediaQuery.of(context).size.width / 2 - 28,
              child: FloatingActionButton(
                onPressed: _showReportDialog,
                child: Icon(Icons.report),
              ),
            ),
          if (_showReportCard)
            Center(
              child: Card(
                margin: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Why do you want to report this area?',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      ..._reportOptions.keys.map((String key) {
                        return CheckboxListTile(
                          title: Text(key),
                          value: _reportOptions[key],
                          onChanged: (bool? value) {
                            setState(() {
                              _reportOptions[key] = value!;
                            });
                          },
                        );
                      }).toList(),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _submitReport,
                        child: Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 12.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void sendDataToDb() {
    if (_selectedLatLng == null) {
      Fluttertoast.showToast(msg: 'No location selected');
      return;
    }

    GeoPoint geoPoint =
        GeoPoint(_selectedLatLng!.latitude, _selectedLatLng!.longitude);
    String selectedReportTypes = _reportOptions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .join(', ');

    Reports report = Reports(
      location: geoPoint,
      type: selectedReportTypes,
    );

    _databaseService.addReport(report);
  }
}
