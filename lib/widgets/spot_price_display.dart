import 'package:flutter/material.dart';
import '../models/spot_price_model.dart';
import '../utils/app_colors.dart';

class SpotPriceDisplay extends StatelessWidget {
  final SpotPriceData? spotPrices;

  const SpotPriceDisplay({
    super.key,
    this.spotPrices,
  });

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2);
  }

  Widget _buildPriceItem({
    required String label,
    required double price,
    required double change,
    required double changePercent,
  }) {
    final isPositive = change >= 0;
    final changeColor = isPositive ? AppColors.profitGreen : AppColors.lossRed;

    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          '\$${_formatCurrency(price)} USD',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: changeColor,
          size: 16,
        ),
        Text(
          '\$${_formatCurrency(change.abs())}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: changeColor,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '(${changePercent.toStringAsFixed(2)}%)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: changeColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (spotPrices == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceItem(
            label: 'Silver',
            price: spotPrices!.silverAsk,
            change: spotPrices!.silverChange,
            changePercent: spotPrices!.silverChangePercent,
          ),
          const SizedBox(height: 4),
          _buildPriceItem(
            label: 'Gold',
            price: spotPrices!.goldAsk,
            change: spotPrices!.goldChange,
            changePercent: spotPrices!.goldChangePercent,
          ),
        ],
      ),
    );
  }
}
