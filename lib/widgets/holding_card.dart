import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/providers/portfolio_provider.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:bold_portfolio/widgets/ExitForm.dart';
import 'package:bold_portfolio/widgets/SellTousForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class HoldingCard extends StatefulWidget {
  final ProductHolding holding;
  final bool showActualPrice;
  final bool showMetalPrice;

  const HoldingCard({
    super.key,
    required this.holding,
    required this.showActualPrice,
    required this.showMetalPrice,
  });

  @override
  _HoldingCardState createState() => _HoldingCardState();
}

class _HoldingCardState extends State<HoldingCard> {
  bool showPercentage = false;

  void toggleDisplay() {
    setState(() {
      showPercentage = !showPercentage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profit = widget.holding.currentMetalValue - widget.holding.avgPrice;
    final selectedImage =
        "https://res.cloudinary.com/bold-pm/image/upload/q_auto:good/Graphics/no_img_preview_product.png";

    final double gainLossValue =
        widget.holding.currentMetalValue - widget.holding.pastMetalValue;

    final double gainLossPercentage = widget.holding.pastMetalValue == 0
        ? 0
        : ((gainLossValue / widget.holding.pastMetalValue) * 100);

    final Color valueColor = gainLossValue == 0
        ? Colors.grey
        : gainLossValue > 0
        ? Colors.green
        : Colors.red;

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
              Image.network(
                widget.holding.productImage.isNotEmpty == true
                    ? widget.holding.productImage
                    : selectedImage,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image);
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: widget.holding.isBold
                          ? () async {
                              final encodedName = Uri.encodeComponent(
                                widget.holding.name,
                              );
                              final url = Uri.parse(
                                'https://www.bullionupdates.com/product/${widget.holding.productId}/$encodedName',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not launch URL'),
                                  ),
                                );
                              }
                            }
                          : null,
                      child: Text(
                        widget.holding.assetList,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          color: Colors.black, // looks like a hyperlink
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Qty: ${widget.holding.totalQtyOrdered ?? 1}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Total Weight: ${widget.holding.weight.toStringAsFixed(2)} oz",
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.holding.orderDate.toIso8601String().split(
                            'T',
                          )[0],
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

          // Price details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Average Unit Price"),
              Text("\$${widget.holding.avgPrice.toStringAsFixed(2)}"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.showActualPrice)
                const Text(
                  "Actual Purchase Price",
                  style: TextStyle(color: Colors.black),
                ),
              if (widget.showMetalPrice)
                const Text(
                  "Purchase Metal Value",
                  style: TextStyle(color: Colors.black),
                ),
              Text("\$${widget.holding.pastMetalValue.toStringAsFixed(2)}"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.showActualPrice
                    ? "Approx. Current Price"
                    : 'Approx. Metal Value',
              ),
              Text("\$${widget.holding.currentMetalValue.toStringAsFixed(2)}"),
            ],
          ),

          // Profit / Loss toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: toggleDisplay,
                child: Row(
                  children: const [
                    Text(
                      "Profit/Loss ",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Icon(Icons.swap_vert, size: 18),
                  ],
                ),
              ),
              Row(
                children: [
                  if (gainLossValue != 0)
                    Icon(
                      gainLossValue > 0
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: valueColor,
                      size: 24,
                    ),
                  GestureDetector(
                    onTap: toggleDisplay,
                    child: Text(
                      showPercentage
                          ? "${gainLossPercentage.toStringAsFixed(2)}%"
                          : "\$${gainLossValue.abs().toStringAsFixed(2)}",
                      style: TextStyle(
                        color: valueColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.holding.isBold
                      ? () async {
                          final url = Uri.parse(
                            'https://www.bullionupdates.com/product/${widget.holding.productId}/${widget.holding.name}',
                          );
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        }
                      : null,
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
                  onPressed: widget.holding.isBold
                      ? () => showSellExitPopup(context, widget.holding)
                      : null,
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
                  onPressed: () =>
                      _showConfirmationDialog(context, widget.holding),
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
  final String baseUrl = dotenv.env['API_URL']!;
  final url = Uri.parse('$baseUrl/Portfolio/RemovePortfolioProducts');

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
      final provider = Provider.of<PortfolioProvider>(context, listen: false);
      await provider.refreshDataFromAPIs(provider.frequency);
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
