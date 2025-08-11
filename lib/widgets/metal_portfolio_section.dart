import 'package:flutter/material.dart';
import '../models/portfolio_model.dart';
import '../utils/app_colors.dart';

class MetalPortfolioSection extends StatelessWidget {
  final MetalData metalData;
  final bool isGold;

  const MetalPortfolioSection({
    super.key,
    required this.metalData,
    required this.isGold,
  });

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isGold 
        ? const Color(0xFFFFF8DC) 
        : const Color(0xFFE8F5E8);
    
    final profitColor = metalData.profit >= 0 
        ? AppColors.profitGreen 
        : AppColors.lossRed;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    metalData.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${metalData.name} Portfolio Valuation',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          metalData.profit >= 0 ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: profitColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          label: 'Current Value',
                          value: '\$${metalData.value.toStringAsFixed(2)}',
                          icon: Icons.info_outline,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          label: 'Purchase Cost',
                          value: '\$${(metalData.value - metalData.profit).toStringAsFixed(2)}',
                          icon: Icons.info_outline,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          label: 'Purchased ${metalData.name} (oz)',
                          value: '${metalData.ounces.toStringAsFixed(2)} oz',
                          icon: Icons.info_outline,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Profit & Loss',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${metalData.profit.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: profitColor,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      metalData.profit >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                      size: 12,
                                      color: profitColor,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${metalData.profitPercentage.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: profitColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
