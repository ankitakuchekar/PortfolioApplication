import 'package:flutter/material.dart';
import '../models/portfolio_model.dart';
import 'package:intl/intl.dart';

class ValueCostCards extends StatelessWidget {
  final PortfolioData portfolioData;

  const ValueCostCards({super.key, required this.portfolioData});

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String value,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                // GestureDetector(
                //   onTap: () {
                //     final message = title == 'Current Value'
                //         ? 'Displays the total worth of your holdings based on the latest market prices.'
                //         : 'The Total Purchase Cost shows how much you\'ve spent on your holdings.';
                //     _showInfoDialog(context, title, message);
                //   },
                //   child: Container(
                //     padding: const EdgeInsets.all(4),
                //     child: Icon(icon, size: 16, color: Colors.white),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final investment = portfolioData.data[0].investment;

    final double totalCurrentValue =
        investment.totalGoldCurrent + investment.totalSilverCurrent;

    final double totalAcquisitionCost =
        investment.totalGoldInvested + investment.totalSilverInvested;
    return Row(
      children: [
        _buildCard(
          context: context,
          title: 'Current Value',
          value: '\$${NumberFormat("#,##0.00").format(totalCurrentValue)}',
          backgroundColor: const Color(0xFF6A4CAF),
          icon: Icons.info_outline,
        ),
        const SizedBox(width: 12),
        _buildCard(
          context: context,
          title: 'Purchase Cost',
          value: '\$${NumberFormat("#,##0.00").format(totalAcquisitionCost)}',
          backgroundColor: const Color(0xFF3F51B5),
          icon: Icons.info_outline,
        ),
      ],
    );
  }
}
