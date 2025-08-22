import 'dart:convert';
import 'dart:html' as html; // For Flutter web file picker
import 'dart:typed_data';
import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class SellForm extends StatefulWidget {
  final ScrollController scrollController;
  final ProductHolding holding;

  const SellForm({
    super.key,
    required this.scrollController,
    required this.holding,
  });

  @override
  State<SellForm> createState() => _SellFormState();
}

class _SellFormState extends State<SellForm> {
  final List<String> productConditions = [
    "BU",
    "Proof",
    "Mint condition",
    "Scratches",
    "Dents",
    "Fingerprints",
    "Milk spots",
    "Toning",
    "Other",
  ];

  final TextEditingController _quantityController = TextEditingController();
  List<String> selectedConditions = [];
  bool isSelectAll = false;
  String selectedImage =
      "https://res.cloudinary.com/bold-pm/image/upload/q_auto:good/Graphics/no_img_preview_product.png";

  bool isLoading = false;

  void _showConditionDialog() async {
    List<String> tempSelection = [...selectedConditions];
    bool selectAllTemp = isSelectAll;

    final result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Select Product Condition"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text("Select All"),
                      value: selectAllTemp,
                      onChanged: (value) {
                        setState(() {
                          selectAllTemp = value!;
                          tempSelection = selectAllTemp
                              ? [...productConditions]
                              : [];
                        });
                      },
                    ),
                    const Divider(),
                    ...productConditions.map((condition) {
                      return CheckboxListTile(
                        title: Text(condition),
                        value: tempSelection.contains(condition),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              tempSelection.add(condition);
                            } else {
                              tempSelection.remove(condition);
                            }
                            selectAllTemp =
                                tempSelection.length ==
                                productConditions.length;
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, tempSelection),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedConditions = result;
        isSelectAll = result.length == productConditions.length;
      });
    }
  }

  Future<void> _pickImage() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/png,image/jpeg,image/jpg';
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;
      final file = files[0];
      final fileName = file.name.toLowerCase();
      final mimeType = file.type.toLowerCase();

      // Validate file type
      if (!(fileName.endsWith('.png') ||
              fileName.endsWith('.jpg') ||
              fileName.endsWith('.jpeg')) ||
          !(mimeType == 'image/png' ||
              mimeType == 'image/jpeg' ||
              mimeType == 'image/jpg')) {
        Fluttertoast.showToast(
          msg: "Please upload a jpg, jpeg, or png image.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
        return;
      }

      // Read file as bytes
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((e) async {
        final bytes = reader.result as List<int>;
        final uri = Uri.parse(
          'https://mobile-dev-api.boldpreciousmetals.com/api/Account/UploadProductImageselltobold',
        );

        final request = http.MultipartRequest('POST', uri)
          ..files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: 'thumb.png'),
          )
          ..fields['imageType'] = 'boldimagetype';

        try {
          final response = await request.send();
          if (response.statusCode == 200) {
            final responseBody = await response.stream.bytesToString();
            final decoded = jsonDecode(responseBody);

            if (decoded['success'] == true) {
              final imageUrl = decoded['data']; // ✅ Safe to assign

              setState(() {
                selectedImage = imageUrl;
              });
            }

            Fluttertoast.showToast(
              msg: "Image uploaded successfully!",
              backgroundColor: Colors.green,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_SHORT,
            );
          } else {
            Fluttertoast.showToast(
              msg: "Upload failed. Try again.",
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        } catch (e) {
          Fluttertoast.showToast(
            msg: "Upload error: $e",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      });
    });
  }

  Future<void> _submitSellRequest() async {
    final quantityStr = _quantityController.text.trim();

    final authService = AuthService();
    final fetchedUserId = await authService.getUser();
    print('Holding: ${widget.holding}');
    if (quantityStr.isEmpty ||
        double.tryParse(quantityStr) == null ||
        double.parse(quantityStr) < 1 ||
        selectedConditions.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter all fields.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    setState(() => isLoading = true);
    // Example user/product data - replace with real ones
    final user = {
      "userId": int.parse(fetchedUserId?.id ?? '0'),
      "firstName": fetchedUserId?.firstName,
      "lastName": fetchedUserId?.lastName,
      "userEmail": fetchedUserId?.email,
      "phoneNumber": fetchedUserId?.mobNo,
    };

    final product = {
      "productId": widget.holding.productId,
      "name": widget.holding.name,
      "metal": widget.holding.metal,
      "quantity": widget.holding.totalQtyOrdered,
    };
    final quantityAvailable = (product['quantity'] as num).toDouble();

    if (double.parse(quantityStr) > quantityAvailable) {
      Fluttertoast.showToast(
        msg:
            "Quantity must be less than or equal to ${quantityAvailable.toStringAsFixed(0)}.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
      setState(() => isLoading = false);
      return;
    }

    final sellRequest = {
      "userId": user['userId'],
      "firstName": user['firstName'],
      "lastName": user['lastName'],
      "email": user['userEmail'],
      "phoneNo": user['phoneNumber'],
      "description": "",
      "isPortfolioRequest": true,
      "products": [
        {
          "productName": product['name'] ?? '',
          "metalId": product['metal'] ?? '',
          "quantity": quantityStr,
          "productCondition": selectedConditions.join(", "),
          "productDescription": "",
          "productId": product['productId'].toString(),
          "productNameWithHypen": "",
          "imagepath": selectedImage,
        },
      ],
      "status": "submitted",
    };

    try {
      final response = await http.post(
        Uri.parse(
          "https://mobile-dev-api.boldpreciousmetals.com/api/Customer/SellToBoldRequests",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(sellRequest),
      );

      if (response.statusCode == 200) {
        _quantityController.clear();
        setState(() {
          selectedConditions = [];
          isSelectAll = false;
        });
        Fluttertoast.showToast(
          msg: "Your sell request has been successfully submitted.",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context); // Close bottom sheet
      } else {
        Fluttertoast.showToast(
          msg: "Something went wrong. Try again.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "API error: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
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
            "Sell To Us",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Are you interested in selling your item to us? Please confirm the details below:",
          ),
          const SizedBox(height: 20),

          // Quantity
          const Text("Qty *"),
          const SizedBox(height: 6),
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter Quantity",
            ),
          ),
          const SizedBox(height: 16),

          // Product Condition
          const Text("Product Condition *"),
          const SizedBox(height: 6),
          InkWell(
            onTap: _showConditionDialog,
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Select Product Condition",
              ),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: selectedConditions.isEmpty
                    ? [
                        const Text(
                          "Select Product Condition",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ]
                    : selectedConditions
                          .map((e) => Chip(label: Text(e)))
                          .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Upload Image
          const Text("Upload Image (Optional)"),
          const SizedBox(height: 6),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.attach_file),
            label: const Text("Choose File"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Show selected image preview
          if (selectedImage.isNotEmpty)
            SizedBox(
              height: 150,
              child: Image.network(
                selectedImage,
                errorBuilder: (context, error, stackTrace) {
                  return const Text("Could not load image.");
                },
              ),
            ),
          const SizedBox(height: 30),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitSellRequest,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Confirm Sell"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
