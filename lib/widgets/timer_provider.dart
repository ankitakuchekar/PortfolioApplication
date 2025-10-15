import 'dart:async';
import 'package:flutter/material.dart';

class TimerProvider with ChangeNotifier {
  late Timer _timer;
  int _remainingSeconds = 45;

  int get remainingSeconds => _remainingSeconds;

  TimerProvider() {
    _startTimer();
  }

  // Start the timer
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners(); // Notify listeners whenever the timer changes
      } else {
        _onTimerComplete(); // Timer complete logic (e.g., refresh data)
      }
    });
  }

  // Called when the timer completes
  void _onTimerComplete() {
    notifyListeners();
    resetTimer();
  }

  // Reset the timer (e.g., after data refresh)
  void resetTimer() {
    _remainingSeconds = 45;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
