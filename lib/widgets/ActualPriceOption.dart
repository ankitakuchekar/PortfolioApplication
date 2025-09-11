// import 'package:bold_portfolio/models/portfolio_model.dart';
// import 'package:flutter/material.dart';
// import '../services/api_service.dart';

// class ActualPriceBannerOption extends StatefulWidget {
//   final int customerId;
//   final PortfolioSettings settings;
//   final String token;
//   final Future<void> Function() fetchChartData;
//   final bool isActualPrice;

//   const ActualPriceBannerOption({
//     super.key,
//     required this.customerId,
//     required this.settings,
//     required this.token,
//     required this.fetchChartData,
//     required this.isActualPrice,
//   });

//   @override
//   State<ActualPriceBannerOption> createState() => _ActualPriceBannerState();
// }

// class _ActualPriceBannerState extends State<ActualPriceBannerOption> {
//   late bool isActualPrice;
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     isActualPrice = widget.isActualPrice;
//   }

//   Future<void> handleToggle(bool value) async {
//     setState(() => isLoading = true);

//     bool result = await updatePortfolioSettings(
//       customerId: widget.customerId,
//       settings: widget.settings,
//       showActualPrice: value,
//       token: widget.token,
//     );

//     if (result) {
//       setState(() => isActualPrice = value);
//       await widget.fetchChartData();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           behavior: SnackBarBehavior.floating,
//           margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
//           content: Text(
//             value ? 'Premium price included' : 'Premium price excluded',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to update settings')),
//       );
//     }

//     setState(() => isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     const double toggleWidth = 52;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Color(0xFFD95D5C), // red-ish
//             Color(0xFF51C89D), // green-ish
//           ],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         borderRadius: BorderRadius.zero,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             isActualPrice ? 'Include Premium Price' : 'Exclude Premium Price',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(
//             width: toggleWidth,
//             height: 30,
//             child: isLoading
//                 ? const Center(
//                     child: SizedBox(
//                       height: 18,
//                       width: 18,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     ),
//                   )
//                 : Transform.scale(
//                     scale: 0.7,
//                     child: Switch(
//                       value: isActualPrice,
//                       onChanged: handleToggle,
//                       activeColor: Colors.white,
//                       activeTrackColor: Colors.greenAccent,
//                       inactiveThumbColor: Colors.grey.shade300,
//                       inactiveTrackColor: Colors.grey.shade600,
//                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class ActualPriceBannerOption extends StatelessWidget {
  final bool isActualPrice;
  final bool isLoading;
  final ValueChanged<bool> onToggle;

  const ActualPriceBannerOption({
    super.key,
    required this.isActualPrice,
    required this.isLoading,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    const double toggleWidth = 52;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFD95D5C), // red-ish
            Color(0xFF51C89D), // green-ish
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isActualPrice ? 'Include Premium Price' : 'Exclude Premium Price',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            width: toggleWidth,
            height: 30,
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: isActualPrice,
                      onChanged: onToggle,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.greenAccent,
                      inactiveThumbColor: Colors.grey.shade300,
                      inactiveTrackColor: Colors.grey.shade600,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
