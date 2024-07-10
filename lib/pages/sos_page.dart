// import 'package:flutter/material.dart';
// // import 'package:location/location.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_sms/flutter_sms.dart';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:contacts_service/contacts_service.dart';

// class SosPage extends StatefulWidget {
//   @override
//   _SosPageState createState() => _SosPageState();
// }

// class _SosPageState extends State<SosPage> {
//   // Location _location = Location();

//   void _sendSosMessage() async {
//     // Check if location service is enabled
//     bool _serviceEnabled;
//     // PermissionStatus _permissionGranted;
//     // LocationData _locationData;

//     // _serviceEnabled = await _location.serviceEnabled();
//     // if (!_serviceEnabled) {
//     //   _serviceEnabled = await _location.requestService();
//     //   if (!_serviceEnabled) {
//     //     return;
//     //   }
//     // }

//     // _permissionGranted = await _location.hasPermission();
//     // if (_permissionGranted == PermissionStatus.denied) {
//     //   _permissionGranted = await _location.requestPermission();
//     //   if (_permissionGranted != PermissionStatus.granted) {
//     //     return;
//     //   }
//     // }

//     // _locationData = await _location.getLocation();

//     String message =
//         "SOS! I need help. My current location is: Your mums house";
//     // String message = "SOS! I need help. My current location is: "
//     //     "https://www.google.com/maps/search/?api=1&query=${_locationData.latitude},${_locationData.longitude}";

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String>? storedContacts = prefs.getStringList('selectedContacts');

//     if (storedContacts != null) {
//       List<String> phoneNumbers = [];
//       List<Contact> selectedContacts = storedContacts.map((contactJson) {
//         Map<String, dynamic> contactMap = jsonDecode(contactJson);
//         if (contactMap['avatar'] is List<dynamic>) {
//           contactMap['avatar'] = Uint8List.fromList(
//               List<int>.from(contactMap['avatar'] as List<dynamic>));
//         }
//         return Contact.fromMap(contactMap);
//       }).toList();

//       for (Contact contact in selectedContacts) {
//         for (Item phone in contact.phones!) {
//           phoneNumbers.add(phone.value!);
//         }
//       }

//       await sendSMS(message: message, recipients: phoneNumbers)
//           .catchError((onError) {
//         print(onError);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('SOS Page'),
//         backgroundColor: Colors.red,
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _sendSosMessage,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.red,
//             padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
//             textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           child: Text('Send SOS'),
//         ),
//       ),
//     );
//   }
// }
