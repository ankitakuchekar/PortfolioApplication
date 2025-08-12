import 'package:flutter/material.dart';
import '../models/portfolio_model.dart';

class ValueCostCards extends StatelessWidget {
  final PortfolioData portfolioData;

  const ValueCostCards({super.key, required this.portfolioData});

  Widget _buildCard({
    required String title,
    required String value,
    required Color backgroundColor,
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, size: 16, color: Colors.white),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
          title: 'Current Value',
          value:
              '\$${portfolioData.data.investment.customerId.toStringAsFixed(2)}',
          backgroundColor: const Color(0xFF8B5CF6),
          icon: Icons.info_outline,
        ),
        const SizedBox(width: 12),
        _buildCard(
          title: 'Purchase Cost',
          value:
              '\$${portfolioData.data.investment.customerId.toStringAsFixed(2)}',
          backgroundColor: const Color(0xFF3B82F6),
          icon: Icons.info_outline,
        ),
      ],
    );
  }
}
