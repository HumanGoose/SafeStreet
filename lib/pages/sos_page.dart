import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_sms/background_sms.dart';
import 'package:safestreet/pages/intro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contacts_service/contacts_service.dart';

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
    _loadSelectedContacts();
  }

  Future<void> _getContactsPermission() async {
    PermissionStatus permission = await Permission.sms.status;
    if (permission != PermissionStatus.granted) {
      permission = await Permission.sms.request();
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

  void sendMessageToAll() {
    for (Contact contact in _selectedContacts) {
      for (Item phone in contact.phones ?? []) {
        sendMessagee(phone.value!,
            "SOS message with location"); // Customize your message
      }
    }
  }

  void sendMessagee(String phoneNumber, String message) {
    BackgroundSms.sendMessage(phoneNumber: phoneNumber, message: message)
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
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                sendMessageToAll(); // Send the messages
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
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
                ElevatedButton(
                  onPressed: _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.all(
                        100), // Increased padding for larger size
                    shape: CircleBorder(),
                  ),
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 50, // Increased font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Card(
                  elevation: 4,
                  margin: EdgeInsets.all(16.0),
                  color: brownn,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(40), // Adjust the value as needed
                  ),
                  child: Container(
                    color: brownn, // Background color for the entire card
                    child: Padding(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
