import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safestreet/services/database_service.dart';
import 'package:safestreet/models/reports.dart'; // Add this import

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

  @override
  void initState() {
    super.initState();
    _getLocationPermission();
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
      setState(() {
        _isLoading = false;
      });
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

  void _showReportDialog() {
    setState(() {
      _showReportCard = true;
    });
  }

  void _submitReport() {
    sendDataToDb();
    setState(() {
      _showReportCard = false;
    });
    Fluttertoast.showToast(
        msg: 'Successfully Reported! Thank you for making the world safer!');
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

    // Convert _selectedLatLng to GeoPoint
    GeoPoint geoPoint =
        GeoPoint(_selectedLatLng!.latitude, _selectedLatLng!.longitude);

    // Prepare the selected report types
    String selectedReportTypes = _reportOptions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .join(', ');

    // Create a Reports object
    Reports report = Reports(
      location: geoPoint,
      type: selectedReportTypes,
    );

    // Store data in Firestore using DatabaseService
    _databaseService.addReport(report);
  }
}
