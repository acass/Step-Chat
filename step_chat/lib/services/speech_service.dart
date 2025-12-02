import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  /// Initializes the speech recognition service
  Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception('Microphone permission denied');
    }

    _isInitialized = await _speechToText.initialize(
      onError: (error) => throw Exception('Speech recognition error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );

    return _isInitialized;
  }

  /// Checks if speech recognition is available
  bool get isAvailable => _speechToText.isAvailable;

  /// Checks if currently listening
  bool get isListening => _speechToText.isListening;

  /// Starts listening for speech input
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_speechToText.isAvailable) {
      throw Exception('Speech recognition not available');
    }

    await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        } else if (onPartialResult != null) {
          onPartialResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  /// Stops listening
  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  /// Cancels listening
  Future<void> cancelListening() async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
  }

  /// Gets available locales for speech recognition
  Future<List<dynamic>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _speechToText.locales();
  }

  /// Disposes the speech service
  void dispose() {
    _speechToText.cancel();
  }
}
