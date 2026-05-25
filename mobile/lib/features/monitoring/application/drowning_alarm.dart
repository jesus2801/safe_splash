import 'dart:async';

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../../../core/debug_logger.dart';

/// Plays the device's system alarm tone for a bounded duration.
///
/// Uses `asAlarm: true` so the sound bypasses ringer/silent mode. The instance
/// owns its own auto-stop timer so callers cannot accidentally leave the alarm
/// looping forever after the controller is disposed.
class DrowningAlarm {
  DrowningAlarm({FlutterRingtonePlayer? player})
      : _player = player ?? FlutterRingtonePlayer();

  final FlutterRingtonePlayer _player;

  Timer? _stopTimer;
  bool _playing = false;
  bool _disposed = false;

  bool get isPlaying => _playing;

  /// Starts the alarm if not already playing. Auto-stops after [duration].
  /// Calls during an active alarm are ignored (no overlap, no restart).
  Future<void> trigger(Duration duration) async {
    if (_disposed || _playing) return;
    _playing = true;
    try {
      await _player.play(
        android: AndroidSounds.alarm,
        ios: IosSounds.alarm,
        looping: true,
        asAlarm: true,
        volume: 1.0,
      );
    } catch (e, st) {
      _playing = false;
      DebugLogger.error('Alarm play', e, st);
      return;
    }
    _stopTimer?.cancel();
    _stopTimer = Timer(duration, _stopInternal);
  }

  Future<void> stop() async {
    _stopTimer?.cancel();
    _stopTimer = null;
    await _stopInternal();
  }

  Future<void> _stopInternal() async {
    if (!_playing) return;
    _playing = false;
    try {
      await _player.stop();
    } catch (e) {
      DebugLogger.error('Alarm stop', e);
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _stopTimer?.cancel();
    _stopTimer = null;
    if (_playing) {
      _playing = false;
      try {
        await _player.stop();
      } catch (_) {}
    }
  }
}
