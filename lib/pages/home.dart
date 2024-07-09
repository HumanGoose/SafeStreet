import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vibration/vibration.dart';

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
    ContactsPage(),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: curr,
        onTap: (int newIndex) {
          setState(() {
            curr = newIndex;
          });
        },
        backgroundColor: brownn, // Set the navigation bar background color
        elevation: 8, // Add elevation for a shadow effect
        selectedItemColor: Colors.black, // Set the selected item color
        unselectedItemColor: Colors.grey, // Set the unselected item color
        selectedFontSize: 14, // Adjust the selected item font size
        unselectedFontSize: 12, // Adjust the unselected item font size
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
    );
  }
}

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Report Page'),
    );
  }
}

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Map Page'),
    );
  }
}

class ContactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Contacts Page'),
    );
  }
}

class SosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('SOS Page'),
    );
  }
}

class StreePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Stree Page'),
    );
  }
}

// class StreePage extends StatefulWidget {
//   @override
//   _StreePageState createState() => _StreePageState();
// }

// class _StreePageState extends State<StreePage> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, String>> _messages = [];
//   final Set<int> _selectedMessages = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadMessages();
//   }

//   Future<void> _loadMessages() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? messages = prefs.getString('messages');
//     if (messages != null) {
//       setState(() {
//         _messages.addAll(List<Map<String, String>>.from(json.decode(messages)));
//       });
//     }
//   }

//   Future<void> _saveMessages() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('messages', json.encode(_messages));
//   }

//   void _sendMessage() {
//     if (_controller.text.isNotEmpty) {
//       setState(() {
//         _messages.add({
//           'text': _controller.text,
//           'time': DateFormat('h:mm a').format(DateTime.now()),
//         });
//         _controller.clear();
//       });
//       _saveMessages();
//     }
//   }

//   void _deleteMessages() {
//     setState(() {
//       _selectedMessages.toList().reversed.forEach((index) {
//         _messages.removeAt(index);
//       });
//       _selectedMessages.clear();
//     });
//     _saveMessages();
//   }

//   void _onMessageLongPress(int index) {
//     setState(() {
//       if (_selectedMessages.isEmpty) {
//         _selectedMessages.add(index);
//       }
//     });
//     Vibration.vibrate(duration: 50);
//   }

//   void _onMessageTap(int index) {
//     setState(() {
//       if (_selectedMessages.isNotEmpty) {
//         if (_selectedMessages.contains(index)) {
//           _selectedMessages.remove(index);
//         } else {
//           _selectedMessages.add(index);
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             itemCount: _messages.length,
//             itemBuilder: (context, index) {
//               bool isSelected = _selectedMessages.contains(index);
//               return GestureDetector(
//                 onLongPress: () => _onMessageLongPress(index),
//                 onTap: () => _onMessageTap(index),
//                 child: Container(
//                   color: isSelected ? Colors.grey[300] : Colors.transparent,
//                   child: Align(
//                     alignment: Alignment.centerRight,
//                     child: Container(
//                       margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                       padding:
//                           EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                       decoration: BoxDecoration(
//                         color: Colors.blueAccent,
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Stack(
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 _messages[index]['text']!,
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                               SizedBox(height: 5),
//                               Text(
//                                 _messages[index]['time']!,
//                                 style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 10,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           if (isSelected)
//                             Positioned(
//                               top: 0,
//                               right: 0,
//                               child: Icon(
//                                 Icons.check_circle,
//                                 color: Colors.white,
//                                 size: 20,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         if (_selectedMessages.isNotEmpty)
//           Container(
//             color: Colors.red,
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.delete, color: Colors.white),
//                   onPressed: _deleteMessages,
//                 ),
//                 Text(
//                   '${_selectedMessages.length} selected',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _controller,
//                   decoration: InputDecoration(
//                     hintText: 'Type a message',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                   onSubmitted: (value) => _sendMessage(),
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(Icons.send),
//                 onPressed: _sendMessage,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
