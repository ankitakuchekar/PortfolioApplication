import 'package:flutter/widgets.dart';

class AppLifecycleHandler with WidgetsBindingObserver {
  DateTime? _pausedTime;
  final Duration idleThreshold;
  final VoidCallback onRequireBiometric;

  AppLifecycleHandler({
    required this.idleThreshold,
    required this.onRequireBiometric,
  });

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pausedTime = DateTime.now();
    }

    if (state == AppLifecycleState.resumed && _pausedTime != null) {
      final idleTime = DateTime.now().difference(_pausedTime!);

      if (idleTime >= idleThreshold) {
        onRequireBiometric();
      }
    }
  }
}
