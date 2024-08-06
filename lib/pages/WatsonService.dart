import 'package:ibm_watson_assistant/ibm_watson_assistant.dart';

class WatsonService {
  final IbmWatsonAssistant? _bot;
  String? _sessionId;

  WatsonService()
      : _bot = IbmWatsonAssistant(
          IbmWatsonAssistantAuth(
            assistantId:
                '', // Replace with your actual Assistant ID
            url:
                '', // Replace with your actual Assistant URL
            apikey:
                '', // Replace with your actual API Key
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
