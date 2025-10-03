import 'package:bold_portfolio/screens/HoldingScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PortfolioValuationDialog extends StatelessWidget {
  final String metalType;
  final double currentValue;
  final double purchaseValue;
  final double loss;
  final double percentageLoss;
  final double metalSpotPrice;
  final double metalPriceChange;
  final double metalPriceChangePercent;
  final List<PortfolioItem> items;

  const PortfolioValuationDialog({
    super.key,
    required this.metalType,
    required this.currentValue,
    required this.purchaseValue,
    required this.loss,
    required this.percentageLoss,
    required this.metalSpotPrice,
    required this.metalPriceChange,
    required this.metalPriceChangePercent,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: "\$");
    final percentFormatter = NumberFormat("#,##0.00");
    final bool isMetalPriceUp = metalPriceChange >= 0;
    final Color metalPriceTextColor = isMetalPriceUp
        ? const Color(0xFF4CAF50)
        : const Color(0xFFF44336);
    final IconData metalPriceIcon = isMetalPriceUp
        ? Icons.arrow_drop_up
        : Icons.arrow_drop_down;
    final Color metalPriceBarBgColor = isMetalPriceUp
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFBE9E7);

    final bool isOverallProfit = loss <= 0;
    final Color profitLossColor = isOverallProfit
        ? const Color(0xFF4CAF50)
        : const Color(0xFFF44336);
    final String profitLossLabel = isOverallProfit ? "Profit" : "LOSS";
    final double displayedProfitLoss = loss.abs();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 24.0,
      ),
      child: ConstrainedBox(
        // <-- Constrain dialog height to avoid overflow
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max, // <-- fill the constrained height
            children: [
              // Header with Gradient and Title (FIXED)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: metalType == 'Silver'
                        ? const [Color(0xFF8A2BE2), Color(0xFF9932CC)]
                        : const [Color(0xFFB8860B), Color(0xFFFFD700)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "$metalType Portfolio Valuation",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Expanded area contains both the fixed top content and the scrollable list.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: [
                      // ---------------- Top fixed content ----------------
                      // Metal price bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          color: metalPriceBarBgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$metalType: ${currencyFormatter.format(metalSpotPrice)} USD",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              metalPriceIcon,
                              color: metalPriceTextColor,
                              size: 20,
                            ),
                            Text(
                              "${currencyFormatter.format(metalPriceChange.abs())} (${percentFormatter.format(metalPriceChangePercent.abs())}%)",
                              style: TextStyle(
                                color: metalPriceTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Portfolio value + cards
                      Container(
                        color: metalType == "Silver"
                            ? const Color(0xFFF3E5F5)
                            : const Color(0xFFFFF8E1),
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                color: metalType == "Silver"
                                    ? const Color(0xFFF3E5F5)
                                    : const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Portfolio Value",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormatter.format(currentValue),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: metalType == 'Silver'
                                          ? const Color(0xFF581C87)
                                          : const Color(0xFFB8860B),
                                    ),
                                  ),
                                  const Text(
                                    "Current Value",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 105,
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                      color: const Color(0xFFF5F5F5),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "PURCHASE VALUE",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              currencyFormatter.format(
                                                purchaseValue,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SizedBox(
                                    height: 105,
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                      color: const Color(0xFFF5F5F5),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              profitLossLabel,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              currencyFormatter.format(
                                                displayedProfitLoss,
                                              ),
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: profitLossColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${percentFormatter.format(percentageLoss.abs())}%",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: profitLossColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ---------------- Scrollable item list ----------------
                      // This ListView is inside an Expanded so it scrolls within the dialog.
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 8,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return PortfolioItemCard(
                              item: item,
                              metalType: metalType,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PortfolioItem {
  final String name;
  final String? imageUrl;
  final int quantity;
  final double purchasePrice;
  final double currentPrice;

  const PortfolioItem({
    required this.name,
    this.imageUrl,
    required this.quantity,
    required this.purchasePrice,
    required this.currentPrice,
  });
}
