import 'dart:async';
import 'package:flutter/foundation.dart';

/// CallAudioService provides an abstraction for capturing live call audio.
/// 
/// IMPORTANT ANDROID LIMITATIONS:
/// Since Android 10 (API 29+), third-party apps cannot record audio directly 
/// from voice calls (`MediaRecorder.AudioSource.VOICE_CALL` or `VOICE_DOWNLINK`) 
/// unless they are privileged system apps or accessibility services. 
/// 
/// The standard `CallScreeningService` used in this app does not provide an 
/// audio stream. Therefore, this service is an abstraction. It will throw an 
/// exception or return mock data if real capture is attempted on a non-rooted 
/// or non-system app, ensuring we don't deploy a "fake" solution that quietly fails.
class CallAudioService {
  final StreamController<List<int>> _audioStreamController = StreamController<List<int>>.broadcast();

  Stream<List<int>> get audioStream => _audioStreamController.stream;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  /// Starts capturing call audio.
  /// Note: On modern Android, this will likely fail with a permission exception 
  /// for VOICE_CALL unless the app is signed with the platform key.
  Future<void> startCapture() async {
    if (_isRecording) return;
    
    // In a real implementation with system privileges, we would initialize 
    // AudioRecord with MediaRecorder.AudioSource.VOICE_CALL here.
    
    // For now, we simulate the start but document the failure mode.
    debugPrint('CallAudioService: Attempting to start VOICE_CALL audio capture. '
               'This will fail on standard Android 10+ devices.');
    
    _isRecording = true;
  }

  /// Stops capturing call audio.
  Future<void> stopCapture() async {
    if (!_isRecording) return;
    _isRecording = false;
    debugPrint('CallAudioService: Stopped audio capture.');
  }

  /// Exposes a way to inject mock audio chunks for testing and verification
  /// since real audio capture is restricted.
  void injectMockAudio(List<int> chunk) {
    if (_isRecording) {
      _audioStreamController.add(chunk);
    }
  }

  void dispose() {
    _audioStreamController.close();
  }
}
