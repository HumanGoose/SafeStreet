import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_sms/background_sms.dart';
import 'package:safestreet/pages/intro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:geolocator/geolocator.dart';

class SosPage extends StatefulWidget {
  @override
  _SosPageState createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  List<Contact> _selectedContacts = [];

  @override
  void initState() {
    super.initState();
    _getContactsPermission();
    _getLocationPermission();
    _loadSelectedContacts();
    _getSmsPermission();
  }

  Future<void> _getSmsPermission() async {
    PermissionStatus permission = await Permission.sms.status;
    if (permission != PermissionStatus.granted) {
      permission = await Permission.sms.request();
      if (permission != PermissionStatus.granted) {
        Fluttertoast.showToast(msg: 'SMS permissions are denied');
        return;
      }
    }
  }

  Future<void> _getLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Location services are disabled');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: 'Location permissions are permanently denied');
      return;
    }
  }

  Future<void> _getContactsPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted) {
      permission = await Permission.contacts.request();
      if (permission != PermissionStatus.granted) {
        Fluttertoast.showToast(msg: 'Contacts permissions are denied');
        return;
      }
    }
  }

  Future<void> _loadSelectedContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedContacts = prefs.getStringList('selectedContacts');
    if (storedContacts != null) {
      setState(() {
        _selectedContacts = storedContacts.map((contactJson) {
          Map<String, dynamic> contactMap = jsonDecode(contactJson);
          if (contactMap['avatar'] is List<dynamic>) {
            contactMap['avatar'] = Uint8List.fromList(
                List<int>.from(contactMap['avatar'] as List<dynamic>));
          }
          return Contact.fromMap(contactMap);
        }).toList();
      });
    }
  }

  void sendMessageToAll(Position position) {
    String message =
        'SOS! I need some help. Here is my location: https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
    for (Contact contact in _selectedContacts) {
      for (Item phone in contact.phones ?? []) {
        sendMessage(phone.value!, message); // Send message to each contact
      }
    }
  }

  void sendMessage(String phoneNumber, String message) {
    BackgroundSms.sendMessage(phoneNumber: phoneNumber, message: message)
        .then((SmsStatus status) {
      if (status == SmsStatus.sent) {
        Fluttertoast.showToast(msg: "Message sent successfully");
      } else {
        Fluttertoast.showToast(msg: "Failed to send message $status");
      }
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Error: $error");
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Send SOS'),
          content: Text(
              'Are you sure you want to send an SOS message to your contacts?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _sendSOS(); // Send the SOS messages
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendSOS() async {
    if (_selectedContacts.isEmpty) {
      Fluttertoast.showToast(msg: 'No contacts selected.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      sendMessageToAll(position);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brownn,
      body: Center(
        child: Card(
          elevation: 4,
          margin: EdgeInsets.all(16.0),
          color: yelloww,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 110),
                ElevatedButton(
                  onPressed: _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.all(100), // Adjusted padding
                    shape: CircleBorder(),
                  ),
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  color: brownn,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Immediately send your location to your safe contacts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 180),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
