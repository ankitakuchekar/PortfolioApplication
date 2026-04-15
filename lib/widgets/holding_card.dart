import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/providers/portfolio_provider.dart';
import 'package:bold_portfolio/screens/ProductLifeCycle.dart';
import 'package:bold_portfolio/screens/bold_webview_screen.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:bold_portfolio/widgets/ExitForm.dart';
import 'package:bold_portfolio/widgets/SellTousForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
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
  State<HoldingCard> createState() => _HoldingCardState();
}

class _HoldingCardState extends State<HoldingCard> {
  bool showPercentage = false;
  bool _isBuyLoading = false;

  void toggleDisplay() {
    setState(() {
      showPercentage = !showPercentage;
    });
  }

  String formatPrice(num price) {
    final format = NumberFormat.simpleCurrency(locale: 'en_US');
    return format.format(price);
  }

  // ---------------------------------------------------------------------------
  // 🛒 Buy button handler — opens in-app WebView with auto-login
  // ---------------------------------------------------------------------------
  Future<void> _onBuyPressed() async {
    final redirectionUrl = dotenv.env['URL_Redirection'] ?? '';
    final productUrl =
        '$redirectionUrl/product/${widget.holding.productId}/${Uri.encodeComponent(widget.holding.name)}';

    // Show loading state on the button
    setState(() => _isBuyLoading = true);

    try {
      final authService = AuthService();
      final token = await authService.getToken();
      final user = await authService.getUser();

      if (!mounted) return;

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Navigate to in-app WebView, passing token + target URL
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BuyWebViewScreen(
            url: productUrl,
            token: token,
            userEmail: user?.emailId, // used for cookie/JS injection
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBuyLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(
      'MM/dd/yyyy',
    ).format(widget.holding.orderDate);

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

    const String fallbackImage =
        'https://res.cloudinary.com/bold-pm/image/upload/q_auto:good/Graphics/no_img_preview_product.png';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // ── Product image + info row ─────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.holding.productImage.isNotEmpty
                    ? widget.holding.productImage
                    : fallbackImage,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductLifecycleScreen(
                              imageUrl: widget.holding.productImage,
                              title: widget.holding.assetList,
                              productId: widget.holding.productId,
                              frequency: '3M',
                              metal: widget.holding.metal,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        widget.holding.assetList,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Qty: ${widget.holding.totalQtyOrdered ?? 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total Weight: ${widget.holding.weight.toStringAsFixed(2)} oz',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
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

          // ── Price details ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Average Unit Price'),
              Text(formatPrice(widget.holding.avgPrice)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.showActualPrice
                    ? 'Actual Purchase Price'
                    : 'Purchase Metal Value',
              ),
              Text(formatPrice(widget.holding.pastMetalValue)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.showActualPrice
                    ? 'Approx. Current Price'
                    : 'Approx. Metal Value',
              ),
              Text(formatPrice(widget.holding.currentMetalValue)),
            ],
          ),

          // ── Profit / Loss toggle ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: toggleDisplay,
                child: Row(
                  children: const [
                    Text(
                      'Profit/Loss ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                      ),
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
                          ? '${gainLossPercentage.toStringAsFixed(2)}%'
                          : formatPrice(gainLossValue.abs()),
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

          // ── Action buttons ───────────────────────────────────────────────
          Row(
            children: [
              // Buy button
              Expanded(
                child: ElevatedButton.icon(
                  icon: _isBuyLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_upward),
                  label: Text(_isBuyLoading ? 'Opening…' : 'Buy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: (!widget.holding.isBold)
                      ? null
                      : _onBuyPressed, // ✅ clean
                ),
              ),
              const SizedBox(width: 10),

              // Sell/Exit button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => showSellExitPopup(
                    context,
                    widget.holding,
                    widget.holding.isBold,
                  ),
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('Sell/Exit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Delete button
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

// =============================================================================
// Sell/Exit popup — unchanged logic, minor style cleanup
// =============================================================================

void showSellExitPopup(
  BuildContext context,
  ProductHolding holding,
  bool isBold,
) {
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
            length: isBold ? 2 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tabs: [
                      if (isBold)
                        const Tab(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('Sell'),
                          ),
                        ),
                      const Tab(
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
                Expanded(
                  child: TabBarView(
                    children: [
                      if (isBold)
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

// =============================================================================
// Delete confirmation + remove product — unchanged logic, mounted guard added
// =============================================================================

Future<void> _showConfirmationDialog(
  BuildContext context,
  ProductHolding holding,
) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text(
        'Are you sure you want to remove this product?',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'This action cannot be undone. This will permanently remove all '
        'quantities of the product from your portfolio.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _removeProduct(context, holding),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: const Text('Remove Position'),
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
  final user = await authService.getUser();
  final token = await authService.getToken();

  if (token == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
    }
    return;
  }

  final body = jsonEncode({
    'customerId': int.parse(user?.id ?? '0'),
    'productId': holding.productId,
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

    if (!context.mounted) return;
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      final provider = Provider.of<PortfolioProvider>(context, listen: false);
      await provider.refreshDataFromAPIs(provider.frequency);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product removed successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove: ${response.body}')),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}
