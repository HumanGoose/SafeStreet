import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_sms/background_sms.dart';

class SosPage extends StatefulWidget {
  @override
  _SosPageState createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  @override
  void initState() {
    super.initState();
    _getContactsPermission();
  }

  Future<void> _getContactsPermission() async {
    PermissionStatus permission = await Permission.sms.status;
    if (permission != PermissionStatus.granted) {
      permission = await Permission.sms.request();
    }
    if (permission == PermissionStatus.granted) {
      // Permission granted, you can proceed
    } else {
      // Handle if permission is denied
    }
  }

  sendMessagee(String phoneNumber, String message) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Corrected onPressed handler
            sendMessagee("8296853488", "Whats up bro");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text('Send SOS'),
        ),
      ),
    );
  }
}
