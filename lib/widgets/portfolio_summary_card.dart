import 'package:flutter/material.dart';
import '../models/portfolio_model.dart';
import '../utils/app_colors.dart';

class PortfolioSummaryCard extends StatelessWidget {
  final PortfolioData portfolioData;

  const PortfolioSummaryCard({
    super.key,
    required this.portfolioData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Portfolio Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Investment',
                    '\$${portfolioData.totalInvestment.toStringAsFixed(2)}',
                    AppColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Current Value',
                    '\$${portfolioData.currentValue.toStringAsFixed(2)}',
                    AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total P&L',
                    '\$${portfolioData.totalProfitLoss.toStringAsFixed(2)}',
                    portfolioData.totalProfitLoss >= 0 
                        ? AppColors.profitGreen 
                        : AppColors.lossRed,
                    subtitle: '${portfolioData.totalProfitLossPercentage >= 0 ? '+' : ''}${portfolioData.totalProfitLossPercentage.toStringAsFixed(2)}%',
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Day P&L',
                    '\$${portfolioData.dayProfitLoss.toStringAsFixed(2)}',
                    portfolioData.dayProfitLoss >= 0 
                        ? AppColors.profitGreen 
                        : AppColors.lossRed,
                    subtitle: '${portfolioData.dayProfitLossPercentage >= 0 ? '+' : ''}${portfolioData.dayProfitLossPercentage.toStringAsFixed(2)}%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    Color valueColor, {
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: valueColor,
            ),
          ),
        ],
      ],
    );
  }
}
