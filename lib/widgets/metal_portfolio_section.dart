import 'package:flutter/material.dart';
import '../models/portfolio_model.dart';
import '../utils/app_colors.dart';

class MetalPortfolioSection extends StatelessWidget {
  final PortfolioData portfolioData;
  final String metalType; // "Gold" or "Silver"

  const MetalPortfolioSection({
    super.key,
    required this.portfolioData,
    required this.metalType,
  });

  @override
  Widget build(BuildContext context) {
    final investment = portfolioData.data[0].investment;
    final bool isGold = metalType == "Gold";

    // Colors
    final headerColor = isGold
        ? const Color(0xFFFFF2CC)
        : const Color(0xFFD9F1EA);
    final valueBoxColor = Colors.white;

    // Metal values
    final double currentValue = isGold
        ? investment.totalGoldCurrent
        : investment.totalSilverCurrent;

    final double ounces = isGold
        ? investment.totalGoldOunces
        : investment.totalSilverOunces;

    final double investedAmount = isGold
        ? investment.totalGoldInvested
        : investment.totalSilverInvested;

    final double profitOrLoss = currentValue - investedAmount;
    final double absProfitOrLoss = profitOrLoss.abs();

    final double percentageChange = investedAmount != 0
        ? (profitOrLoss / investedAmount) * 100
        : 0;

    final bool isProfit = profitOrLoss > 0;

    final Color pnlColor = isProfit ? AppColors.profitGreen : AppColors.lossRed;
    final Color profitColor = absProfitOrLoss == 0
        ? AppColors
              .textPrimary // Neutral text color (dark gray/black)
        : isProfit
        ? AppColors.profitGreen
        : AppColors.lossRed;

    final IconData arrowIcon = isProfit
        ? Icons.arrow_upward
        : Icons.arrow_downward;

    final IconData valuationIcon = isProfit
        ? Icons.trending_up
        : Icons.trending_down;

    final Color valuationIconColor = isProfit
        ? AppColors.profitGreen
        : AppColors.lossRed;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Container(
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  metalType,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bar_chart,
                        size: 14,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$metalType Portfolio Valuation',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(valuationIcon, size: 18, color: valuationIconColor),
              ],
            ),
          ),

          // Value Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: valueBoxColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Left Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _labelWithIcon("Current Value"),
                          const SizedBox(height: 4),
                          _valueText("\$${currentValue.toStringAsFixed(2)}"),
                          const SizedBox(height: 16),
                          _labelWithIcon("Purchase Cost"),
                          const SizedBox(height: 4),
                          _valueText("\$${investedAmount.toStringAsFixed(2)}"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _labelWithIcon("Purchased $metalType (oz)"),
                          const SizedBox(height: 4),
                          _valueText("${ounces.toStringAsFixed(2)} oz"),
                          const SizedBox(height: 16),
                          const Text(
                            "Profit & Loss",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "\$${absProfitOrLoss.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: profitColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "(",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: profitColor,
                                    ),
                                  ),
                                  if (percentageChange != 0)
                                    Icon(
                                      isProfit
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      size: 14,
                                      color: profitColor,
                                    ),
                                  const SizedBox(width: 2),
                                  Text(
                                    "${percentageChange.toStringAsFixed(2)}%",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: profitColor,
                                    ),
                                  ),
                                  Text(
                                    " )",
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelWithIcon(String label) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.info_outline,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _valueText(String value) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
