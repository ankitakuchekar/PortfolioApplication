import 'package:flutter/material.dart';
import '../models/portfolio_model.dart';
import '../utils/app_colors.dart';

class HoldingCard extends StatelessWidget {
  final Holding holding;

  const HoldingCard({
    super.key,
    required this.holding,
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: holding.type == 'Gold' 
                        ? AppColors.goldColor.withValues(alpha: 0.2)
                        : AppColors.silverColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.monetization_on,
                    color: holding.type == 'Gold' 
                        ? AppColors.goldColor
                        : AppColors.silverColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holding.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${holding.quantity} ${holding.type == 'Gold' ? 'gram' : 'oz'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${holding.profitPercentage >= 0 ? '+' : ''}${holding.profitPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: holding.profit >= 0 
                        ? AppColors.profitGreen 
                        : AppColors.lossRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPriceItem(
                    'Actual Purchase Price',
                    '\$${holding.purchasePrice.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _buildPriceItem(
                    'Approx. Current Price',
                    '\$${holding.currentPrice.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPriceItem(
              'Profit/Loss',
              '\$${holding.profit.toStringAsFixed(2)}',
              color: holding.profit >= 0 
                  ? AppColors.profitGreen 
                  : AppColors.lossRed,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Buy feature coming soon!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.profitGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Buy'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sell feature coming soon!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lossRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Sell'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit feature coming soon!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textSecondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  ),
                  child: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
