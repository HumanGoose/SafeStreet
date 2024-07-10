import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_sms/background_sms.dart';

class SosPage extends StatefulWidget {
  @override
  _SosPageState createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  Position? _currentPosition;
  String? _currentAddress;
  LocationPermission? _permission;

  @override
  void initState() {
    super.initState();
    _getPermission();
  }

  _getPermission() async {
    _permission = await Geolocator.checkPermission();
    if (_permission == LocationPermission.denied) {
      _permission = await Geolocator.requestPermission();
      if (_permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: "Location permission permanently denied");
      }
    }
    if (_permission == LocationPermission.whileInUse ||
        _permission == LocationPermission.always) {
      _getCurrentLocation();
    }
  }

  _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (_currentPosition != null) {
        _getAddressfromLatLong();
      } else {
        Fluttertoast.showToast(msg: "Unable to fetch location");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  _getAddressfromLatLong() async {
    try {
      double lat = _currentPosition!.latitude;
      double lon = _currentPosition!.longitude;
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      Placemark place = placemarks[0];

      setState(() {
        _currentAddress =
            "${place.locality},${place.street},${place.postalCode}";
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void _sendSms(String phoneNumber, String message) async {
    await BackgroundSms.sendMessage(phoneNumber: phoneNumber, message: message)
        .then((SmsStatus status) {
      if (status == SmsStatus.sent) {
        Fluttertoast.showToast(msg: "Message sent successfully");
      } else {
        Fluttertoast.showToast(msg: "Failed to send message");
      }
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Error: $error");
    });
  }

  void sendMessage() {
    _sendSms("8296853488", "Test SOS message");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: sendMessage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
          ),
          child: Text('Send SOS'),
        ),
      ),
    );
  }
}
