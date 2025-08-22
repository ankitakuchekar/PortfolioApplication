import 'package:flutter/material.dart';

class ExitForm extends StatelessWidget {
  final ScrollController scrollController;

  const ExitForm({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
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
          const Text("Sold Cost (Per Unit) *"),
          const SizedBox(height: 6),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter sold price",
            ),
          ),
          const SizedBox(height: 16),

          // Qty
          const Text("Qty *"),
          const SizedBox(height: 6),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter Quantity",
            ),
          ),
          const SizedBox(height: 16),

          // Sold On Date
          const Text("Sold On *"),
          const SizedBox(height: 6),
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "mm/dd/yyyy",
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
            },
          ),
          const SizedBox(height: 30),

          // Confirm Exit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("Confirm Exit"),
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
