import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _locationServiceEnabled && _locationPermissionGranted
              ? Column(
                  children: [
                    Expanded(
                      child: GoogleMap(
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
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text('Location permissions are not granted'),
                ),
    );
  }
}
