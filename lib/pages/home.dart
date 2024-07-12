import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'contacts_page.dart';
import 'sos_page.dart';
import 'report_page.dart';
import 'stree_page.dart';
import 'map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color yelloww = Color(0xfff1e4a7);
  static const Color brownn = Color.fromARGB(255, 36, 17, 5);

  void signUserOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  int curr = 0;

  List<Widget> body = [
    ReportPage(),
    MapPage(),
    ContactsPage(), // Use the new ContactsPage
    SosPage(),
    StreePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => signUserOut(context),
            icon: Icon(Icons.logout),
            color: yelloww,
          )
        ],
        title: const Text(
          "SafeStreet",
          style: TextStyle(
            color: yelloww,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: brownn, // Set the app bar color
      ),
      body: Center(
        child: body[curr],
      ),
      backgroundColor: brownn, // Set the Scaffold background color
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the BottomNavigationBar
          canvasColor: brownn,
          // sets the active color of the BottomNavigationBar if Brightness is light
          primaryColor: Colors.black,
          textTheme: Theme.of(context).textTheme.copyWith(
                bodySmall: TextStyle(color: Colors.grey),
              ), // sets the inactive color of the BottomNavigationBar
        ),
        child: BottomNavigationBar(
          currentIndex: curr,
          onTap: (int newIndex) {
            setState(() {
              curr = newIndex;
            });
          },
          elevation: 8,
          selectedItemColor: yelloww,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              label: 'Report',
              icon: Icon(Icons.assignment),
            ),
            BottomNavigationBarItem(
              label: 'Map',
              icon: Icon(Icons.map_outlined),
            ),
            BottomNavigationBarItem(
              label: 'Contacts',
              icon: Icon(Icons.menu_book),
            ),
            BottomNavigationBarItem(
              label: 'SOS',
              icon: Icon(Icons.report_problem),
            ),
            BottomNavigationBarItem(
              label: 'Stree',
              icon: Icon(Icons.question_answer),
            ),
          ],
        ),
      ),
    );
  }
}
