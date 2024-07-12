import 'package:ibm_watson_assistant/ibm_watson_assistant.dart';

class WatsonService {
  final IbmWatsonAssistant? _bot;
  String? _sessionId;

  WatsonService()
      : _bot = IbmWatsonAssistant(
          IbmWatsonAssistantAuth(
            assistantId:
                'de32bb79-ad8d-4212-a734-be46e6d2ded6', // Replace with your actual Assistant ID
            url:
                'https://api.au-syd.assistant.watson.cloud.ibm.com/instances/1e655fea-f37f-4152-b729-09251df7e5db ', // Replace with your actual Assistant URL
            apikey:
                '97DysCryGNyKZGN5RKzgzqoYuXDSe_fjRNxf5paFNv83', // Replace with your actual API Key
          ),
        ) {
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    try {
      _sessionId = await _bot!.createSession();
    } catch (e) {
      print('Error initializing session: $e');
    }
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _bot!.sendInput(message, sessionId: _sessionId!);
      return response.output!.generic!.first.text!;
    } catch (e) {
      print('Error sending message: $e');
      return 'Error: $e';
    }
  }

  void dispose() {
    if (_sessionId != null) {
      _bot!.deleteSession(_sessionId!);
    }
  }
}
