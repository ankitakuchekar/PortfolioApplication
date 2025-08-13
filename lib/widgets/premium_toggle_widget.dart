import 'package:flutter/material.dart';

class PremiumToggleWidget extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onToggle;

  const PremiumToggleWidget({
    super.key,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE5534D), Color(0xFF2CC399)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        children: [
          const Text(
            "Do you want to Include Premium Price?",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),

          /// ClipRRect ensures the child stays inside the rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: double.infinity, // makes it stretch within available space
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 50,
              color: Colors.white,
              child: Row(
                children: [
                  // Exclude Premium section
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Exclude Premium",
                          style: TextStyle(
                            color: !value ? Colors.teal : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: !value ? Colors.teal : Colors.grey,
                        ),
                      ],
                    ),
                  ),

                  // Toggle switch
                  Switch(
                    value: value,
                    onChanged: onToggle,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.grey,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),

                  // Include Premium section
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Include Premium",
                          style: TextStyle(
                            color: value ? Colors.teal : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: value ? Colors.teal : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
