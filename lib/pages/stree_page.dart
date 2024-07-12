import 'package:flutter/material.dart';
import 'package:kommunicate_flutter/kommunicate_flutter.dart';

class StreePage extends StatefulWidget {
  @override
  _StreePageState createState() => _StreePageState();
}

class _StreePageState extends State<StreePage> {
  @override
  void initState() {
    super.initState();
    _initializeChatBot();
  }

  void _initializeChatBot() async {
    try {
      dynamic conversationObject = {
        'appId':
            '131ee462705217ba11b9cda0eccf0d006', // Replace 'YOUR_APP_ID' with your Kommunicate App ID
      };

      KommunicateFlutterPlugin.buildConversation(conversationObject)
          .then((result) {
        print("Conversation builder success : " + result.toString());
      }).catchError((error) {
        print("Conversation builder error : " + error.toString());
      });
    } catch (e) {
      print("Error initializing chatbot: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Initializing Chatbot...'),
      ),
    );
  }
}
