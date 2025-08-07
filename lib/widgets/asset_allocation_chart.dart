import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/portfolio_model.dart';
import '../utils/app_colors.dart';

class AssetAllocationChart extends StatelessWidget {
  final PortfolioData portfolioData;

  const AssetAllocationChart({
    super.key,
    required this.portfolioData,
  });

  @override
  Widget build(BuildContext context) {
    final totalValue = portfolioData.silver.value + portfolioData.gold.value;
    final silverPercentage = (portfolioData.silver.value / totalValue) * 100;
    final goldPercentage = (portfolioData.gold.value / totalValue) * 100;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: AppColors.silverColor,
                  value: portfolioData.silver.value,
                  title: '${silverPercentage.toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: AppColors.goldColor,
                  value: portfolioData.gold.value,
                  title: '${goldPercentage.toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                'Silver',
                AppColors.silverColor,
                '\$${portfolioData.silver.value.toStringAsFixed(0)}',
              ),
              const SizedBox(height: 12),
              _buildLegendItem(
                'Gold',
                AppColors.goldColor,
                '\$${portfolioData.gold.value.toStringAsFixed(0)}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
