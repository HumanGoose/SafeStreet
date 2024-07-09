import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:safestreet/pages/home.dart";
import "package:safestreet/pages/intro.dart";

class Auth_Page extends StatelessWidget {
  const Auth_Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              //User logged in
              if (snapshot.hasData) {
                return HomePage();
              }
              //User NOT logged in
              else {
                return IntroductionScreen();
              }
            }));
  }
}
