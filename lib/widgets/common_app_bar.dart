import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';
import 'circular_timer_widget.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int timerDurationSeconds;

  const CommonAppBar({
    super.key,
    required this.title,
    this.timerDurationSeconds = 45,
  });

  void _onTimerComplete(BuildContext context) {
    Provider.of<PortfolioProvider>(
      context,
      listen: false,
    ).refreshDataFromAPIs();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircularTimerWidget(
            durationSeconds: timerDurationSeconds,
            onTimerComplete: () => _onTimerComplete(context),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
