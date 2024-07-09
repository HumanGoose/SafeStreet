import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safestreet/pages/auth.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized
  await Firebase.initializeApp(); // Initialize Firebase
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
