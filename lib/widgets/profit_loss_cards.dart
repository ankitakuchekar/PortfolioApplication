import 'package:flutter/material.dart';
import '../models/portfolio_model.dart';

class ProfitLossCards extends StatelessWidget {
  final PortfolioData portfolioData;

  const ProfitLossCards({super.key, required this.portfolioData});

  void _showInfoDialog(BuildContext context, String title, String message) {
    final investment = portfolioData.data[0].investment;
    final double totalCurrentValue =
        investment.totalGoldCurrent + investment.totalSilverCurrent;
    final double totalAcquisitionCost =
        investment.totalGoldInvested + investment.totalSilverInvested;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calculate,
                          color: Color(0xFF63B3ED),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Calculated by:',
                          style: TextStyle(
                            color: Color(0xFF63B3ED),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (title == 'Total Profit & Loss') ...[
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          children: [
                            TextSpan(text: '• Total P/L = ('),
                            TextSpan(
                              text: 'Total Current Value',
                              style: TextStyle(color: Color(0xFF63B3ED)),
                            ),
                            TextSpan(text: ' - '),
                            TextSpan(
                              text: 'Purchase Cost',
                              style: TextStyle(color: Color(0xFF63B3ED)),
                            ),
                            TextSpan(text: ')'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(text: '• Total P/L = ('),
                            TextSpan(
                              text: totalCurrentValue.toStringAsFixed(2),
                              style: const TextStyle(color: Color(0xFF68D391)),
                            ),
                            const TextSpan(text: ' - '),
                            TextSpan(
                              text: totalAcquisitionCost.toStringAsFixed(2),
                              style: const TextStyle(color: Color(0xFFF56565)),
                            ),
                            const TextSpan(text: ')'),
                          ],
                        ),
                      ),
                    ] else ...[
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          children: [
                            TextSpan(text: '• Day P/L = '),
                            TextSpan(
                              text: 'Daily Gold Change',
                              style: TextStyle(color: Color(0xFF63B3ED)),
                            ),
                            TextSpan(text: ' + '),
                            TextSpan(
                              text: 'Daily Silver Change',
                              style: TextStyle(color: Color(0xFF63B3ED)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(text: '• Day P/L = '),
                            TextSpan(
                              text: investment.dayGold.toStringAsFixed(2),
                              style: TextStyle(
                                color: investment.dayGold >= 0
                                    ? const Color(0xFF68D391)
                                    : const Color(0xFFF56565),
                              ),
                            ),
                            const TextSpan(text: ' + '),
                            TextSpan(
                              text: investment.daySilver.toStringAsFixed(2),
                              style: TextStyle(
                                color: investment.daySilver >= 0
                                    ? const Color(0xFF68D391)
                                    : const Color(0xFFF56565),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
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
                // GestureDetector(
                //   onTap: () {
                //     final message = title == 'Total Profit & Loss'
                //         ? 'Total Profit and Loss shows the net gain or loss from your bullion investments. A positive value indicates a profit, while a negative value indicates a loss.'
                //         : 'Day Profit and Loss shows the net daily change in your bullion investments.';
                //     _showInfoDialog(context, title, message);
                //   },
                //   child: Container(
                //     padding: const EdgeInsets.all(4),
                //     child: Icon(icon, size: 16, color: textColor),
                //   ),
                // ),
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
    final investment = portfolioData.data[0].investment;

    final double totalCurrentValue =
        investment.totalGoldCurrent + investment.totalSilverCurrent;

    final double totalAcquisitionCost =
        investment.totalGoldInvested + investment.totalSilverInvested;

    final double difference = totalCurrentValue - totalAcquisitionCost;
    final double totalProfitDifference = (difference < 0)
        ? -difference
        : difference;

    final double percentDifference = totalAcquisitionCost > 0
        ? (totalProfitDifference / totalAcquisitionCost) * 100
        : 0;

    final double dayProfitLoss = investment.dayGold + investment.daySilver;

    final double percentDayProfitLossPage = investment.dayChangePercentage;

    final double percentDayProfitLoss =
        totalAcquisitionCost > 0 && !percentDayProfitLossPage.isNaN
        ? percentDayProfitLossPage.abs()
        : 0;

    return Row(
      children: [
        _buildCard(
          context: context,
          title: 'Total Profit & Loss',
          value: totalProfitDifference > 0
              ? '+\$${totalProfitDifference.toStringAsFixed(2)}'
              : '-\$${totalProfitDifference.abs().toStringAsFixed(2)}',
          percentage: percentDifference > 0
              ? '+${percentDifference.toStringAsFixed(2)}%'
              : '-${percentDifference.abs().toStringAsFixed(2)}%',
          backgroundColor: totalProfitDifference > 0
              ? const Color(0xFF16A34A)
              : const Color(0xFFDC2626),
          textColor: Colors.white,
          icon: Icons.info_outline,
        ),
        const SizedBox(width: 12),
        _buildCard(
          context: context,
          title: 'Day Profit & Loss',
          value: dayProfitLoss >= 0
              ? '+\$${dayProfitLoss.toStringAsFixed(2)}'
              : '-\$${dayProfitLoss.abs().toStringAsFixed(2)}',
          percentage: percentDayProfitLoss > 0
              ? '+${percentDayProfitLoss.toStringAsFixed(2)}%'
              : '-${percentDayProfitLoss.abs().toStringAsFixed(2)}%',
          backgroundColor: dayProfitLoss >= 0
              ? const Color(0xFF16A34A)
              : const Color(0xFFDC2626),
          textColor: Colors.white,
          icon: Icons.info_outline,
        ),
      ],
    );
  }
}
