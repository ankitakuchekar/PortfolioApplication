// Your existing imports
import 'dart:async';
import 'dart:convert';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../services/portfolio_service.dart';

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
  final TextEditingController purchaseCostController = TextEditingController(
    text: '0',
  );
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController spotPriceController = TextEditingController();
  final TextEditingController premiumCostController = TextEditingController();
  final TextEditingController dealerNameController = TextEditingController();

  final FocusNode _productFocusNode = FocusNode();

  DateTime? purchaseDate;
  bool showSpotPremium = false;
  bool isSearching = false;
  List<dynamic> searchResults = [];

  Timer? _debounce;
  Map<String, dynamic>? selectedProduct;
  bool _isSelectingProduct = false;

  final List<Map<String, String>> steps = [
    {
      "title": "Type the product name.",
      "image":
          "https://res.cloudinary.com/bold-pm/image/upload/v1739187199/Graphics/product-5.webp",
    },
    {
      "title": "Select it from the suggestions or enter the full name.",
      "image":
          "https://res.cloudinary.com/bold-pm/image/upload/v1739187200/Graphics/product-6.webp",
    },
    {
      "title": "List appears—select the first option if product isn't found.",
      "image":
          "https://res.cloudinary.com/bold-pm/image/upload/v1739187200/Graphics/product-4.webp",
    },
    {
      "title": "Selected product name will be displayed.",
      "image":
          "https://res.cloudinary.com/bold-pm/image/upload/v1739187199/Graphics/product-7.webp",
    },
  ];

  @override
  void initState() {
    super.initState();
    productController.addListener(_onProductChanged);
    _productFocusNode.addListener(_onFocusChange);
  }

  void _onProductChanged() {
    if (_isSelectingProduct) return;
    setState(() => selectedProduct = null);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (productController.text.isNotEmpty) {
        searchProducts(productController.text);
      } else {
        setState(() => searchResults.clear());
      }
    });
  }

  void _onFocusChange() {
    if (!_productFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!_productFocusNode.hasFocus) {
          setState(() => searchResults.clear());
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
        List<dynamic> results = data['dataList']['searchProductsByKW'] ?? [];

        if (selectedDealer == 'Not Purchased on Bold' &&
            productController.text.trim().isNotEmpty &&
            !results.any(
              (p) =>
                  (p['name'] as String?)?.toLowerCase() ==
                  productController.text.trim().toLowerCase(),
            )) {
          results.insert(0, {
            'id': 0,
            'name': productController.text.trim(),
            'imagePath': null,
          });
        }

        setState(() {
          searchResults = results;
          isSearching = false;
        });
      } else {
        setState(() {
          searchResults = [];
          isSearching = false;
        });
      }
    } catch (_) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
    }
  }

  void _showStepsPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add any product to your portfolio outside of BOLD',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < steps.length; i++) ...[
                  Text(
                    'Step ${i + 1}: ${steps[i]['title']}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      steps[i]['image']!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addHolding() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedProduct == null && selectedDealer == 'Bold Precious Metals') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product from the list.')),
      );
      return;
    }

    final transactionDate = purchaseDate != null
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
      "sourceName": selectedDealer == 'Not Purchased on Bold'
          ? dealerNameController.text
          : selectedDealer.split(' ').first,
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
        await PortfolioService.fetchCustomerPortfolio(0, '3M');
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
    dealerNameController.dispose();
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

                      // Dealer Dropdown
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
                        decoration: const InputDecoration(
                          labelText: 'Dealer *',
                        ),
                      ),
                      // Product Field ( ALWAYS )
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // const Text.rich(
                              //   TextSpan(
                              //     text: 'Product ',
                              //     style: TextStyle(
                              //       fontSize: 16,
                              //       fontWeight: FontWeight.w600,
                              //     ),
                              //     children: [
                              //       TextSpan(
                              //         text: '*',
                              //         style: TextStyle(color: Colors.red),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              const SizedBox(height: 12),
                              if (selectedDealer == 'Not Purchased on Bold')
                                GestureDetector(
                                  onTap: _showStepsPopup,
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 6),
                                    child: Text(
                                      '(What if you didn’t find the product?)',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: productController,
                            focusNode: _productFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Product name',
                              suffixIcon: isSearching
                                  ? const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: SizedBox(
                                        height: 14,
                                        width: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),

                      // Autocomplete suggestions
                      if (searchResults.isNotEmpty &&
                          _productFocusNode.hasFocus)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 180),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ListView.builder(
                            itemCount: searchResults.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final prod = searchResults[index];
                              return ListTile(
                                leading: prod['imagePath'] != null
                                    ? Image.network(
                                        prod['imagePath'],
                                        height: 32,
                                        width: 32,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.image),
                                      )
                                    : const Icon(Icons.image),
                                title: Text(prod['name'] ?? 'Unnamed Product'),
                                onTap: () {
                                  setState(() {
                                    _isSelectingProduct = true;
                                    productController.text = prod['name'] ?? '';
                                    selectedProduct = prod;
                                    searchResults.clear();
                                    isSearching = false;
                                  });
                                  _productFocusNode.unfocus();
                                  Future.delayed(
                                    const Duration(milliseconds: 50),
                                    () => _isSelectingProduct = false,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Purchase Cost (Per Unit) * - always shown
                      TextFormField(
                        controller: purchaseCostController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Purchase Cost (Per Unit) *',
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      // Dealer Name field if NOT from Bold
                      if (selectedDealer == 'Not Purchased on Bold') ...[
                        TextFormField(
                          controller: dealerNameController,
                          decoration: const InputDecoration(
                            labelText: 'Dealer Name *',
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Metal
                        DropdownButtonFormField<String>(
                          value: selectedProduct?['metal'] ?? 'Silver',
                          items: ['Silver', 'Gold']
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedProduct = {
                                ...?selectedProduct,
                                'metal': val,
                              };
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Metal *',
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue:
                                    selectedProduct?['ouncesPerUnit']
                                        ?.toString() ??
                                    '0',
                                decoration: const InputDecoration(
                                  labelText: 'Ounces Per Unit *',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setState(() {
                                    selectedProduct = {
                                      ...?selectedProduct,
                                      'ouncesPerUnit':
                                          double.tryParse(val) ?? 0,
                                    };
                                  });
                                },
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: purchaseCostController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Purchase Cost (Per Unit) *',
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Qty + Date Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: qtyController,
                              decoration: const InputDecoration(
                                labelText: 'Qty *',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || val.isEmpty
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

                                  // Format date as MM/DD/YYYY
                                  final formattedDate =
                                      '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';

                                  final productName = productController.text
                                      .trim();
                                  final metal =
                                      selectedProduct?['metal'] ??
                                      'Gold'; // default fallback
                                  final authService = AuthService();
                                  final token = await authService.getToken();

                                  if (token == null ||
                                      productName.isEmpty ||
                                      metal.isEmpty) {
                                    // optionally show an error or skip
                                    return;
                                  }

                                  try {
                                    final spotResponse =
                                        await fetchSpotPricesDateWise(
                                          productName: productName,
                                          purchaseDate: formattedDate,
                                          token: token,
                                          metal: metal,
                                        );

                                    // TODO: Handle the response (e.g., update spot price field or save to state)
                                    print("Spot Price Response: $spotResponse");
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Failed to fetch spot price: $e",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: TextEditingController(
                                    text: purchaseDate == null
                                        ? ''
                                        : '${purchaseDate!.month.toString().padLeft(2, '0')}/${purchaseDate!.day.toString().padLeft(2, '0')}/${purchaseDate!.year}',
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Purchase Date mm/dd/yyy*',
                                    hintText: 'MM/DD/YYYY',
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

                      // Spot / Premium
                      CheckboxListTile(
                        title: const Text(
                          'Do you want to enter spot price and premium?',
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
                          decoration: const InputDecoration(
                            labelText: 'Spot Price',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: premiumCostController,
                          decoration: const InputDecoration(
                            labelText: 'Premium Cost',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Your “Save & Add more” logic here
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
                  top: 0,
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
