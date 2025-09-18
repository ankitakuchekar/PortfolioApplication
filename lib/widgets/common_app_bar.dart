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
      backgroundColor: AppColors.black,
      elevation: 0,
      title: Row(
        children: [
          // Moved the title to the left side
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          // Moved the timer widget to the right side
          CountdownTimerWidget(
            durationSeconds: timerDurationSeconds,
            onTimerComplete: () => _onTimerComplete(context),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50), // fixed height always
        child: Consumer<PortfolioProvider>(
          builder: (context, portfolio, child) {
            final spotPrices = portfolio.spotPrices?.data;
            return Container(
              height: 50,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: (spotPrices == null)
                  ? const Center(
                      child: Text(
                        "Loading prices...",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildPriceBox(
                            label: 'Silver',
                            price: spotPrices.silverAsk,
                            change: spotPrices.silverChange,
                            color: const Color(0xFFE8F5F3),
                            highlight: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPriceBox(
                            label: 'Gold',
                            price: spotPrices.goldAsk,
                            change: spotPrices.goldChange,
                            color: Colors.amber.shade50,
                            highlight: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPriceBox({
    required String label,
    required double price,
    required double change,
    required Color color,
    required Color highlight,
  }) {
    final isPositive = change >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPositive ? Colors.green : Colors.red,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: highlight.withOpacity(0.2),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              '$label: \$${price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Icon(
              isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: isPositive ? Colors.green : Colors.red,
              size: 16,
            ),
            Text(
              '\$${change.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 50);
}
