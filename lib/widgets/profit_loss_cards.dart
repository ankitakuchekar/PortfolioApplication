import 'package:flutter/material.dart';
import '../models/portfolio_model.dart';
import '../utils/app_colors.dart';

class ProfitLossCards extends StatelessWidget {
  final PortfolioData portfolioData;

  const ProfitLossCards({
    super.key,
    required this.portfolioData,
  });

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
                Icon(
                  icon,
                  size: 16,
                  color: textColor,
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
    return Row(
      children: [
        _buildCard(
          title: 'Total Profit & Loss',
          value: '+\$${portfolioData.totalProfitLoss.toStringAsFixed(2)}',
          percentage: '+${portfolioData.totalProfitLossPercentage.toStringAsFixed(2)}%',
          backgroundColor: AppColors.profitGreen,
          textColor: Colors.white,
          icon: Icons.info_outline,
        ),
        const SizedBox(width: 12),
        _buildCard(
          title: 'Day Profit & Loss',
          value: portfolioData.dayProfitLoss >= 0 
              ? '+\$${portfolioData.dayProfitLoss.toStringAsFixed(2)}'
              : '-\$${portfolioData.dayProfitLoss.abs().toStringAsFixed(2)}',
          percentage: '${portfolioData.dayProfitLossPercentage.toStringAsFixed(2)}%',
          backgroundColor: portfolioData.dayProfitLoss >= 0 
              ? AppColors.profitGreen 
              : AppColors.lossRed,
          textColor: Colors.white,
          icon: Icons.info_outline,
        ),
      ],
    );
  }
}
