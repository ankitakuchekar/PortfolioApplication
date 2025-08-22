import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:bold_portfolio/services/portfolio_service.dart';
import 'package:bold_portfolio/widgets/ExitForm.dart';
import 'package:bold_portfolio/widgets/SellTousForm.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class HoldingCard extends StatelessWidget {
  final ProductHolding holding;

  const HoldingCard({super.key, required this.holding});

  @override
  Widget build(BuildContext context) {
    final profit = holding.currentMetalValue - holding.avgPrice;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image on left
              Image.network(
                holding.productImage,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),

              const SizedBox(width: 10),

              // Text details on right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name with underline
                    Text(
                      holding.assetList,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Qty, weight, and date using Column instead of RichText
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Qty: ${holding.totalQtyOrdered ?? 1}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Total Weight: ${holding.weight.toStringAsFixed(2)} oz",
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${holding.orderDate.toIso8601String().split('T')[0]}",
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Price details in two columns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Average Unit Price"),
              Text("\$${holding.avgPrice.toStringAsFixed(2)}"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Actual Purchase Price"),
              Text("\$${holding.avgPrice.toStringAsFixed(2)}"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Approx. Current Price"),
              Text("\$${holding.currentMetalValue.toStringAsFixed(2)}"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text("Profit/Loss "),
                  Icon(Icons.swap_vert, size: 18),
                ],
              ),
              Row(
                children: [
                  Icon(
                    profit >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: profit >= 0 ? Colors.green : Colors.red,
                  ),
                  Text(
                    "\$${profit.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: profit >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Buttons row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text("Buy"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => showSellExitPopup(context, holding),
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text("Sell/Exit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(width: 10),
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => _showConfirmationDialog(context, holding),
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showSellExitPopup(BuildContext context, ProductHolding holding) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.95,
          ),
          child: DefaultTabController(
            length: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Row
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, right: 16),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),

                // TabBar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 20,
                    ),
                    indicatorSize: TabBarIndicatorSize
                        .tab, // This makes indicator match the tab width
                    indicator: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // smooth, but not too round
                    ),
                    tabs: const [
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                          ), // control height
                          child: Text('Sell'),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Exit'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                const Divider(height: 1, color: Colors.grey),

                // TabBar View Content
                Expanded(
                  child: TabBarView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SellForm(
                          scrollController: ScrollController(),
                          holding: holding,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ExitForm(
                          scrollController: ScrollController(),
                          holding: holding,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _showConfirmationDialog(
  BuildContext context,
  ProductHolding holding,
) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text(
        "Are you sure you want to remove this product?",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        "This action cannot be undone. This will permanently remove all quantities of the product from your portfolio.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => _removeProduct(context, holding),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: const Text("Confirm"),
        ),
      ],
    ),
  );
}

Future<void> _removeProduct(
  BuildContext context,
  ProductHolding holding,
) async {
  final url = Uri.parse(
    'https://mobile-dev-api.boldpreciousmetals.com/api/Portfolio/RemovePortfolioProducts',
  );

  final authService = AuthService();
  final fetchedUserId = await authService.getUser();
  final token = await authService.getToken();
  if (token == null) throw Exception('Unauthenticated');
  final body = jsonEncode({
    "customerId": int.parse(fetchedUserId?.id ?? '0'),
    "productId": holding.productId,
  });

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop(); // Close dialog
      await PortfolioService.fetchCustomerPortfolio(0, '3M');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product removed successfully')),
      );
      // if (onDelete != null) onDelete!(); // Refresh parent
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove: ${response.body}')),
      );
    }
  } catch (e) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}
