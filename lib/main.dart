import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safestreet/firebase_options.dart';
import 'package:safestreet/pages/auth.dart';
import 'package:kommunicate_flutter/kommunicate_flutter.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true); // Corrected spelling
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeStreet',
      debugShowCheckedModeBanner: false,
      home: Auth_Page(),
    );
  }
}
