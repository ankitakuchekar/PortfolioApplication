import 'dart:async';
import 'package:flutter/material.dart';

class TimerProvider with ChangeNotifier {
  // --- Variables for the 45-second UI countdown ---
  Timer? _timer;
  int _remainingSeconds = 45;
  int get remainingSeconds => _remainingSeconds;

  // --- Variables for the Session/PIN Lock ---
  Timer? _pinTimer;
  DateTime? _backGroundTimestamp;

  TimerProvider() {
    _startTimer();
  }

  // 1. Logic for the 45-second periodic timer (UI updates)
  void _startTimer() {
    _timer?.cancel(); // Clear existing timer if any
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onTimerComplete();
      }
    });
  }

  void _onTimerComplete() {
    // You can trigger an API refresh here
    resetTimer();
  }

  void resetTimer() {
    _remainingSeconds = 45;
    notifyListeners();
  }

  // 2. Logic for the In-App Inactivity Lock (User is touching the screen)
  void resetTimersForPin(VoidCallback onTimeout) {
    _pinTimer?.cancel();
    // Set to 2 minutes as per your previous requirement
    _pinTimer = Timer(const Duration(minutes: 2), onTimeout);
  }

  // 3. Logic for Background Lock (Detecting if 5+ minutes passed while app was closed)

  /// Records the exact time when the user minimizes the app.
  void recordStartTime() {
    _backGroundTimestamp = DateTime.now();
    debugPrint("Background time recorded: $_backGroundTimestamp");
  }

  /// Compares current time with background time.
  /// Returns true if 5 minutes or more have passed.
  bool shouldLockApp() {
    if (_backGroundTimestamp == null) return false;

    final now = DateTime.now();
    final difference = now.difference(_backGroundTimestamp!);

    // Clear the timestamp after checking so it doesn't trigger again immediately
    _backGroundTimestamp = null;

    debugPrint("Minutes passed since background: ${difference.inMinutes}");

    // Change '5' to any number of minutes you prefer for testing
    return difference.inMinutes >= 15;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinTimer?.cancel();
    super.dispose();
  }
}
