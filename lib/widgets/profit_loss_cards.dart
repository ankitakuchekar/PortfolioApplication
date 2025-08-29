import 'package:flutter/material.dart';
import '../models/portfolio_model.dart';
import '../utils/app_colors.dart';
import '../models/investment.dart';

class ProfitLossCards extends StatelessWidget {
  final PortfolioData portfolioData;

  const ProfitLossCards({super.key, required this.portfolioData});

  Widget _buildCard({
    required String title,
    required String value,
    required String percentage,
    required Color backgroundColor,
    required Color textColor,
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: title == 'Total Profit & Loss'
                      ? 'Total Profit and Loss shows the net gain or loss from your bullion investments. A positive value indicates a profit, while a negative value indicates a loss.'
                      : 'Day Profit and Loss shows the net daily change in your bullion investments.',
                  child: Icon(icon, size: 16, color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
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

    final double difference = totalCurrentValue - totalAcquisitionCost;
    final double totalProfitDifference = (difference < 0)
        ? -difference
        : difference;

    final double percentDifference = totalAcquisitionCost > 0
        ? (totalProfitDifference / totalAcquisitionCost) * 100
        : 0;

    final double dayProfitLoss = investment.dayGold + investment.daySilver;

    final double percentDayProfitLossPage = investment.dayChangePercentage;

    final double percentDayProfitLoss =
        totalAcquisitionCost > 0 && !percentDayProfitLossPage.isNaN
        ? percentDayProfitLossPage.abs()
        : 0;

    return Row(
      children: [
        _buildCard(
          title: 'Total Profit & Loss',
          value: totalProfitDifference > 0
              ? '+\$${totalProfitDifference.toStringAsFixed(2)}'
              : '-\$${totalProfitDifference.abs().toStringAsFixed(2)}',
          percentage: percentDifference > 0
              ? '+${percentDifference.toStringAsFixed(2)}%'
              : '-${percentDifference.abs().toStringAsFixed(2)}%',
          backgroundColor: totalProfitDifference > 0
              ? const Color(0xFF16A34A)
              : const Color(0xFFDC2626),
          textColor: Colors.white,
          icon: Icons.info_outline,
        ),
        const SizedBox(width: 12),
        _buildCard(
          title: 'Day Profit & Loss',
          value: dayProfitLoss >= 0
              ? '+\$${dayProfitLoss.toStringAsFixed(2)}'
              : '-\$${dayProfitLoss.abs().toStringAsFixed(2)}',
          percentage: percentDayProfitLoss > 0
              ? '+${percentDayProfitLoss.toStringAsFixed(2)}%'
              : '-${percentDayProfitLoss.abs().toStringAsFixed(2)}%',
          backgroundColor: dayProfitLoss >= 0
              ? const Color(0xFF16A34A)
              : const Color(0xFFDC2626),
          textColor: Colors.white,
          icon: Icons.info_outline,
        ),
      ],
    );
  }
}
