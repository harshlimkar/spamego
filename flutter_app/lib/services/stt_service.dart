import 'dart:async';
import 'package:flutter/foundation.dart';
import 'call_audio_service.dart';

/// SttService abstracts the Speech-to-Text conversion process.
/// 
/// Since we don't have access to live call audio due to Android constraints 
/// (as documented in CallAudioService), this service provides the interface 
/// and a simulation mode to verify the STT -> Risk API pipeline.
class SttService {
  final CallAudioService _audioService;
  
  final StreamController<String> _transcriptStreamController = StreamController<String>.broadcast();
  Stream<String> get transcriptStream => _transcriptStreamController.stream;
  
  StreamSubscription<List<int>>? _audioSubscription;
  Timer? _mockTimer;
  
  String _currentTranscript = '';
  
  SttService(this._audioService);

  void startTranscription() {
    _currentTranscript = '';
    
    // In a real implementation with system audio access, we would stream 
    // audio chunks to a local ML model (like vosk) or cloud API here.
    
    _audioSubscription = _audioService.audioStream.listen((chunk) {
      // Decode audio and convert to text...
      // For now, we rely on the injected mock text directly for pipeline testing.
      final simulatedTextChunk = String.fromCharCodes(chunk);
      _currentTranscript += simulatedTextChunk;
      _transcriptStreamController.add(_currentTranscript);
    });
  }

  void stopTranscription() {
    _audioSubscription?.cancel();
    _audioSubscription = null;
    _mockTimer?.cancel();
    _mockTimer = null;
  }
  
  /// Helper to push mock transcript chunks directly for UI testing.
  void injectMockTranscriptChunk(String chunk) {
    if (_audioSubscription != null) {
      _currentTranscript += ' $chunk';
      _transcriptStreamController.add(_currentTranscript.trim());
    }
  }
  
  /// Simulates a full scam call conversation over time.
  void simulateScamCall() {
    startTranscription();
    final chunks = [
      "Hello, am I speaking with the account holder?",
      "I am calling from State Bank of India customer care.",
      "We have detected some unauthorized transactions on your account.",
      "To block these transactions and secure your account,",
      "we have sent a 6-digit OTP to your registered mobile number.",
      "Please share the OTP with me immediately so I can freeze the account.",
    ];
    
    int index = 0;
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (index < chunks.length) {
        injectMockTranscriptChunk(chunks[index]);
        index++;
      } else {
        timer.cancel();
      }
    });
  }

  void dispose() {
    stopTranscription();
    _transcriptStreamController.close();
  }
}
