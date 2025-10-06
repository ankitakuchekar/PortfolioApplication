import 'package:bold_portfolio/screens/main_screen.dart';
import 'package:bold_portfolio/widgets/portfolioValuation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_drawer.dart';

class HoldingDetailScreen extends StatelessWidget {
  final String metal;
  final double currentValue;
  final double totalPL;
  final double percentPL;
  final double dayPL;
  final double percentDayPL;
  final double purchaseCost;
  final List<PortfolioItem> holdings;

  const HoldingDetailScreen({
    super.key,
    required this.metal,
    required this.currentValue,
    required this.totalPL,
    required this.percentPL,
    required this.dayPL,
    required this.percentDayPL,
    required this.purchaseCost,
    required this.holdings,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: "\$");

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Bold Portfolio'),
      drawer: const CommonDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              label: const Text(
                'Back',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              onPressed: () {
                final mainState = context
                    .findAncestorStateOfType<MainScreenState>();
                mainState?.onNavigationTap(0);
              },
            ),
            _buildSummaryCard(currencyFormatter),
            const SizedBox(height: 20),
            ...holdings
                .map((item) => PortfolioItemCard(item: item, metalType: metal))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(NumberFormat currencyFormatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$metal Current Value',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            currencyFormatter.format(currentValue),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24, thickness: 1),
          _buildValueRow(
            label: 'Total P/L',
            value:
                '${totalPL >= 0 ? '+' : '-'}${currencyFormatter.format(totalPL.abs())} (${percentPL.toStringAsFixed(2)}%)',
            valueColor: totalPL >= 0 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 8),
          _buildValueRow(
            label: 'Day P/L',
            value:
                '${dayPL >= 0 ? '+' : '-'}${currencyFormatter.format(dayPL.abs())} (${percentDayPL.toStringAsFixed(2)}%)',
            valueColor: dayPL >= 0 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 8),
          _buildValueRow(
            label: '$metal Purchase Cost',
            value: currencyFormatter.format(purchaseCost),
            valueColor: Colors.black87,
          ),
        ],
      ),
    );
  }

  Widget _buildValueRow({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: valueColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class PortfolioItemCard extends StatelessWidget {
  final PortfolioItem item;
  final String metalType;

  const PortfolioItemCard({
    super.key,
    required this.item,
    required this.metalType,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: "\$");
    final Color currentPriceColor = item.currentPrice < item.purchasePrice
        ? const Color(0xFFF44336)
        : Colors.black;
    final selectedImage =
        "https://res.cloudinary.com/bold-pm/image/upload/q_auto:good/Graphics/no_img_preview_product.png";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                        : Image.network(selectedImage, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quantity",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: metalType == 'Silver'
                            ? const Color(0xFFF3E5F5)
                            : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        item.quantity.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: metalType == 'Silver'
                              ? const Color(0xFF8A2BE2)
                              : const Color(0xFFB8860B),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Purchase",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormatter.format(item.purchasePrice),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormatter.format(item.currentPrice),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: currentPriceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
