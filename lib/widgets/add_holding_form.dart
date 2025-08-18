import 'dart:async';
import 'dart:convert';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddHoldingForm extends StatefulWidget {
  final VoidCallback onClose;

  const AddHoldingForm({super.key, required this.onClose});

  @override
  State<AddHoldingForm> createState() => _AddHoldingFormState();
}

class _AddHoldingFormState extends State<AddHoldingForm> {
  final _formKey = GlobalKey<FormState>();

  String selectedDealer = 'Bold Precious Metals';
  List<String> dealers = ['Bold Precious Metals', 'Not Purchased on Bold'];

  final TextEditingController productController = TextEditingController();
  final TextEditingController purchaseCostController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController spotPriceController = TextEditingController();
  final TextEditingController premiumCostController = TextEditingController();
  final FocusNode _productFocusNode = FocusNode();

  DateTime? purchaseDate;
  bool showSpotPremium = false;
  bool isSearching = false;
  List<dynamic> searchResults = [];

  Timer? _debounce;
  Map<String, dynamic>? selectedProduct;
  // New flag to manage programmatic text changes
  bool _isSelectingProduct = false;

  @override
  void initState() {
    super.initState();
    productController.addListener(_onProductChanged);
    _productFocusNode.addListener(_onFocusChange);
  }

  void _onProductChanged() {
    // If we are programmatically setting the text, do not search
    if (_isSelectingProduct) {
      return;
    }
    // Clear selected product when the user starts typing again
    setState(() {
      selectedProduct = null;
    });
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (productController.text.isNotEmpty) {
        searchProducts(productController.text);
      } else {
        setState(() {
          searchResults.clear();
        });
      }
    });
  }

  void _onFocusChange() {
    if (!_productFocusNode.hasFocus) {
      // Delay clearing search results to allow for onTap to fire
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!_productFocusNode.hasFocus) {
          setState(() {
            searchResults.clear();
          });
        }
      });
    }
  }

  Future<void> searchProducts(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        searchResults.clear();
        isSearching = false;
      });
      return;
    }

    setState(() => isSearching = true);

    try {
      final response = await http.post(
        Uri.parse(
          'https://mobile-dev-api.boldpreciousmetals.com/api/Product/SearchProductsByKWs',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "customerId": 0,
          "pageNumber": 0,
          "searchKW": keyword,
          "size": 12,
          "isExcludeGroupProduct": true,
          "isExcludeJWAndMetals": true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          searchResults = data['dataList']['searchProductsByKW'] ?? [];
          isSearching = false;
        });
      } else {
        setState(() {
          searchResults = [];
          isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
    }
  }

  Future<void> _addHolding() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedProduct == null && selectedDealer == 'Bold Precious Metals') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product from the list.')),
      );
      return;
    }

    final String transactionDate = purchaseDate != null
        ? '${purchaseDate!.month.toString().padLeft(2, '0')}/${purchaseDate!.day.toString().padLeft(2, '0')}/${purchaseDate!.year}'
        : '';

    final payload = {
      "customerId": 98937,
      "productId": selectedProduct?['id'] ?? 0,
      "transactionDate": transactionDate,
      "transactionQuantity": int.tryParse(qtyController.text) ?? 1,
      "productUnitPrice": double.tryParse(purchaseCostController.text) ?? 0.0,
      "transactionType": "PURCHASED",
      "goldSpot": selectedProduct?['goldSpot'] ?? 0,
      "silverSpot": selectedProduct?['silverSpot'] ?? 0,
      "source": selectedDealer,
      "metal": selectedProduct?['metal'] ?? "N/A",
      "ouncesPerUnit": selectedProduct?['ouncesPerUnit'] ?? 0,
      "productName": productController.text,
      "sourceName": selectedDealer.split(' ').first,
      "userSpot": double.tryParse(spotPriceController.text) ?? 0.0,
      "userPremium": double.tryParse(premiumCostController.text) ?? 0.0,
    };

    try {
      final authService = AuthService();
      final token = await authService.getToken();
      final response = await http.post(
        Uri.parse(
          'https://mobile-dev-api.boldpreciousmetals.com/api/Portfolio/AddCustomerHoldings',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Holding added successfully!')),
        );
        widget.onClose();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add holding: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    productController.removeListener(_onProductChanged);
    _productFocusNode.removeListener(_onFocusChange);
    productController.dispose();
    purchaseCostController.dispose();
    qtyController.dispose();
    spotPriceController.dispose();
    premiumCostController.dispose();
    _productFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Add Holdings By Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedDealer,
                        items: dealers.map((dealer) {
                          return DropdownMenuItem(
                            value: dealer,
                            child: Text(dealer),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => selectedDealer = value!),
                        decoration: const InputDecoration(labelText: 'Dealer'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: productController,
                        focusNode: _productFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Product *',
                          suffixIcon: isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (searchResults.isNotEmpty &&
                          _productFocusNode.hasFocus)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final product = searchResults[index];
                              return ListTile(
                                leading: product['imagePath'] != null
                                    ? Image.network(
                                        product['imagePath'],
                                        width: 32,
                                        height: 32,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.image),
                                      )
                                    : const Icon(Icons.image),
                                title: Text(
                                  product['name'] ?? 'Unnamed Product',
                                ),
                                onTap: () {
                                  // Set flag to prevent search on programmatic text change
                                  setState(() {
                                    _isSelectingProduct = true;
                                  });
                                  productController.text =
                                      product['name'] ?? '';
                                  setState(() {
                                    selectedProduct = product;
                                    searchResults.clear();
                                    isSearching = false;
                                  });
                                  _productFocusNode.unfocus();
                                  // Reset the flag after a short delay
                                  Future.delayed(
                                    const Duration(milliseconds: 50),
                                    () {
                                      _isSelectingProduct = false;
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: purchaseCostController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Purchase Cost (Per Unit) *',
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: qtyController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Qty *',
                              ),
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() => purchaseDate = picked);
                                }
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Purchase Date *',
                                    hintText: 'MM/DD/YYYY',
                                  ),
                                  controller: TextEditingController(
                                    text: purchaseDate == null
                                        ? ''
                                        : '${purchaseDate!.month.toString().padLeft(2, '0')}/${purchaseDate!.day.toString().padLeft(2, '0')}/${purchaseDate!.year}',
                                  ),
                                  validator: (_) =>
                                      purchaseDate == null ? 'Required' : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text(
                          "Do you want to enter spot price and premium?",
                        ),
                        value: showSpotPremium,
                        onChanged: (value) =>
                            setState(() => showSpotPremium = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (showSpotPremium) ...[
                        TextFormField(
                          controller: spotPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Spot Price',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: premiumCostController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Premium Cost',
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Save & Add More logic here
                              }
                            },
                            child: const Text('Save & Add More'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _addHolding();
                              }
                            },
                            child: const Text('Save & Close'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
