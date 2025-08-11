import 'package:flutter/material.dart';
import '../models/spot_price_model.dart';
import '../utils/app_colors.dart';

class AssetAllocationSection extends StatelessWidget {
  final SpotPriceData? spotPrices;

  const AssetAllocationSection({
    super.key,
    this.spotPrices,
  });

  Widget _buildPriceRow({
    required String label,
    required String price,
    required String change,
    required String changePercent,
    required bool isPositive,
  }) {
    final changeColor = isPositive ? AppColors.profitGreen : AppColors.lossRed;
    final backgroundColor = label == 'Silver' 
        ? const Color(0xFFE8F5E8) 
        : const Color(0xFFFFF8DC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label: $price USD',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: changeColor,
                size: 20,
              ),
              Text(
                '$change ($changePercent)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: changeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
                const Text(
                  'Asset Allocation and Valuation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (spotPrices != null) ...[
              _buildPriceRow(
                label: 'Silver',
                price: '\$${spotPrices!.silverAsk.toStringAsFixed(2)}',
                change: '\$${spotPrices!.silverChange.toStringAsFixed(2)}',
                changePercent: '${spotPrices!.silverChangePercent.toStringAsFixed(2)}%',
                isPositive: spotPrices!.silverChange >= 0,
              ),
              const SizedBox(height: 8),
              _buildPriceRow(
                label: 'Gold',
                price: '\$${spotPrices!.goldAsk.toStringAsFixed(2)}',
                change: '\$${spotPrices!.goldChange.toStringAsFixed(2)}',
                changePercent: '${spotPrices!.goldChangePercent.toStringAsFixed(2)}%',
                isPositive: spotPrices!.goldChange >= 0,
              ),
            ] else ...[
              _buildPriceRow(
                label: 'Silver',
                price: '\$38.02',
                change: '\$0.62',
                changePercent: '-1.6%',
                isPositive: false,
              ),
              const SizedBox(height: 8),
              _buildPriceRow(
                label: 'Gold',
                price: '\$3,371.70',
                change: '\$75.60',
                changePercent: '-2.17%',
                isPositive: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
