import 'dart:convert';
import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:bold_portfolio/services/auth_service.dart'; // Assuming AuthService is here
import 'package:fluttertoast/fluttertoast.dart';

class ExitForm extends StatefulWidget {
  final ScrollController scrollController;
  final ProductHolding holding;

  const ExitForm({
    required this.scrollController,
    required this.holding,
    super.key,
  });

  @override
  State<ExitForm> createState() => _ExitFormState();
}

class _ExitFormState extends State<ExitForm> {
  final TextEditingController soldCostController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController soldDateController = TextEditingController();

  DateTime? soldDate;
  bool isLoading = false;

  Future<void> _submitExit() async {
    final quantity = int.tryParse(qtyController.text) ?? 0;
    final soldCost = double.tryParse(soldCostController.text) ?? 0.0;

    if (quantity <= 0 || soldCost <= 0 || soldDate == null) {
      Fluttertoast.showToast(
        msg: "Please fill all fields correctly.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final formattedDate =
        '${soldDate!.month.toString().padLeft(2, '0')}/${soldDate!.day.toString().padLeft(2, '0')}/${soldDate!.year}';

    final authService = AuthService();
    final fetchedUserId = await authService.getUser();
    final token = await authService.getToken();

    final user = {
      "userId": int.parse(fetchedUserId?.id ?? '0'),
      "firstName": fetchedUserId?.firstName ?? '',
      "lastName": fetchedUserId?.lastName ?? '',
      "userEmail": fetchedUserId?.email ?? '',
      "phoneNumber": fetchedUserId?.mobNo ?? '',
    };

    final product = {
      "productId": widget.holding.productId,
      "name": widget.holding.name,
      "metal": widget.holding.metal,
      "quantity": widget.holding.totalQtyOrdered,
      "weight": widget.holding.weight,
    };

    final payload = {
      "customerId": user['userId'] ?? 0,
      "productId": product['productId'] ?? 0,
      "transactionDate": formattedDate,
      "transactionQuantity": quantity,
      "productUnitPrice": soldCost,
      "transactionType": "EXIT",
      "goldSpot": 0,
      "silverSpot": 0,
      "source": product['isBold'] == true
          ? "Bold Precious Metals"
          : "Not Purchased on Bold",
      "metal": product['metal'],
      "ouncesPerUnit": product['weight'],
      "productName": product['name'],
      "sourceName": product['sourceName'],
    };

    try {
      setState(() => isLoading = true);
      final String baseUrl = dotenv.env['API_URL']!;

      final response = await http.post(
        Uri.parse('$baseUrl/Portfolio/AddCustomerHoldings'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Exit transaction successful!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context); // Close bottom sheet
      } else {
        String errorMessage = "Failed to exit holding.";

        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson is Map && errorJson.containsKey('message')) {
            errorMessage = errorJson['message'];
          } else {
            errorMessage = response.body;
          }
        } catch (_) {
          errorMessage = response.body;
        }

        Fluttertoast.showToast(
          msg: errorMessage,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Exit Holdings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("Are you sure you want to exit this holding?"),
          const SizedBox(height: 20),

          // Sold Cost
          RichText(
            text: const TextSpan(
              text: 'Sold Cost (Per Unit)',
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: soldCostController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter sold price",
            ),
          ),
          const SizedBox(height: 16),

          // Qty
          RichText(
            text: const TextSpan(
              text: 'Qty',
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter Quantity",
            ),
          ),
          const SizedBox(height: 16),

          // Sold On Date
          RichText(
            text: const TextSpan(
              text: 'Sold On',
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: soldDateController,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "mm/dd/yyyy",
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(), // 👈 Prevent selecting a future date
              );
              if (picked != null) {
                setState(() {
                  soldDate = picked;
                  soldDateController.text =
                      '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
                });
              }
            },
          ),
          const SizedBox(height: 30),

          // Confirm Exit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitExit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Confirm Exit"),
            ),
          ),
        ],
      ),
    );
  }
}
