import 'package:flutter/material.dart';
import '../models/portfolio_model.dart';
import '../utils/app_colors.dart';

class MetalBreakdownCard extends StatelessWidget {
  final MetalData metalData;
  final Color color;

  const MetalBreakdownCard({
    super.key,
    required this.metalData,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                Text(
                  metalData.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '\$${metalData.value.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${metalData.ounces.toStringAsFixed(2)} oz',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '\$${metalData.profit.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: metalData.profit >= 0 
                        ? AppColors.profitGreen 
                        : AppColors.lossRed,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${metalData.profitPercentage >= 0 ? '+' : ''}${metalData.profitPercentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: metalData.profit >= 0 
                        ? AppColors.profitGreen 
                        : AppColors.lossRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
