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
                Icon(icon, size: 16, color: textColor),
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
    final investment = portfolioData.data.investment is List
        ? (portfolioData.data.investment
              as List)[0] // Access the first element of the list
        : null;

    if (investment == null) {
      return Center(child: Text("No investment data available"));
    }

    final double totalCurrentValue =
        investment.totalGoldCurrent + investment.totalSilverCurrent;
    print("Total Current Value: ${investment.totalGoldCurrent}");
    final double totalAcquisitionCost =
        portfolioData.data.investment.totalGoldInvested +
        portfolioData.data.investment.totalSilverInvested;
    final double difference = totalCurrentValue - totalAcquisitionCost;
    final double totalProfitDifference = (difference < 0)
        ? -difference
        : difference;
    final double percentDifference = totalAcquisitionCost > 0
        ? (totalProfitDifference / totalAcquisitionCost) * 100
        : 0;
    final double dayProfitLoss =
        portfolioData.data.investment.dayGold +
        portfolioData.data.investment.daySilver;
    final double percentDayProfitLossPage =
        portfolioData.data.investment.dayChangePercentage;

    final double percentDayProfitLoss =
        totalAcquisitionCost > 0 && !percentDayProfitLossPage.isNaN
        ? percentDayProfitLossPage.abs()
        : 0;
    print('Total Current Value: ${totalProfitDifference}');
    return Row(
      children: [
        _buildCard(
          title: 'Total Profit & Loss',
          value: '+\$${totalProfitDifference.toStringAsFixed(2)}',
          percentage: '+${percentDifference.toStringAsFixed(2)}%',
          backgroundColor: AppColors.profitGreen,
          textColor: Colors.white,
          icon: Icons.info_outline,
        ),
        const SizedBox(width: 12),
        _buildCard(
          title: 'Day Profit & Loss',
          value: dayProfitLoss >= 0
              ? '+\$${dayProfitLoss.toStringAsFixed(2)}'
              : '-\$${dayProfitLoss.abs().toStringAsFixed(2)}',
          percentage: '${percentDayProfitLoss.toStringAsFixed(2)}%',
          backgroundColor: dayProfitLoss >= 0
              ? AppColors.profitGreen
              : AppColors.lossRed,
          textColor: Colors.white,
          icon: Icons.info_outline,
        ),
      ],
    );
  }
}
