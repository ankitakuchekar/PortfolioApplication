import 'dart:convert';
import 'dart:typed_data';
import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

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

  void pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final String extension = path.extension(image.name).toLowerCase().trim();
      final allowedExtensions = ['.jpg', '.jpeg', '.png'];

      print("File extension: $extension");

      if (!allowedExtensions.contains(extension)) {
        Fluttertoast.showToast(
          msg: "Please upload a jpg, jpeg, or png image.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
        return;
      }

      try {
        Uint8List imageBytes = await image.readAsBytes();
        final String baseUrl = dotenv.env['API_URL']!;
        final uri = Uri.parse('$baseUrl/Account/UploadProductImageselltobold');
        final request = http.MultipartRequest('POST', uri);

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: image.name,
            contentType: getContentType(extension),
          ),
        );
        request.fields['imageType'] = 'boldimagetype';

        final response = await request.send();

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: "Image uploaded Successfully.",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
          );
          setState(() {
            selectedImage =
                image.path; // Update selectedImage with the image path
          });
        } else {
          Fluttertoast.showToast(
            msg: "Image upload failed with status: ${response.statusCode}",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
          );
          print('Image upload failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  // Optional: helper to get the content type based on extension
  MediaType? getContentType(String extension) {
    switch (extension) {
      case '.png':
        return MediaType('image', 'png');
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      default:
        return null;
    }
  }

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
      final String baseUrl = dotenv.env['API_URL']!;
      final response = await http.post(
        Uri.parse("$baseUrl/Customer/SellToBoldRequests"),
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

  late String imagePath;

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
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter Quantity",
            ),
          ),
          const SizedBox(height: 16),

          // Product Condition
          RichText(
            text: const TextSpan(
              text: 'Product Condition',
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
            onPressed: () => pickAndUploadImage(),
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
