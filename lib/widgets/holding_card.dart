import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:flutter/material.dart';

class HoldingCard extends StatelessWidget {
  final ProductHolding holding;

  const HoldingCard({super.key, required this.holding});

  @override
  Widget build(BuildContext context) {
    final profit = holding.currentMetalValue - holding.avgPrice;
    final profitColor = profit >= 0 ? Colors.green : Colors.red;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.network(
                holding.productImage,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  holding.assetList,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("Qty: 1"),
          Text("Total Weight: ${holding.weight.toStringAsFixed(2)} oz"),
          Text("Date: ${holding.orderDate.toIso8601String().split('T')[0]}"),
          const Divider(height: 20),
          Text("Average Unit Price: \$${holding.avgPrice.toStringAsFixed(2)}"),
          Text(
            "Current Price: \$${holding.currentMetalValue.toStringAsFixed(2)}",
          ),
          Row(
            children: [
              const Text("Profit/Loss: "),
              Text(
                "\$${profit.toStringAsFixed(2)}",
                style: TextStyle(color: profitColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Buy"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sell),
                label: const Text("Sell/Exit"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete),
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
