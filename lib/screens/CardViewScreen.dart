// import 'package:flutter/material.dart';
// import 'package:card_flutter/card_flutter.dart';

// class CardViewScreen extends StatefulWidget {
//   final Map<String, dynamic> dictionaryMap;

//   const CardViewScreen({Key? key, required this.dictionaryMap}) : super(key: key);

//   @override
//   _CardViewScreenState createState() => _CardViewScreenState();
// }

// class _CardViewScreenState extends State<CardViewScreen> {
//   dynamic mCardSDKResponse;
//   bool generateToken = false;
//   bool showTapTokenButton = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payment Page'),
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back),
//         ),
//       ),
//       body: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TapCardViewWidget(
//             sdkConfiguration: widget.dictionaryMap,
//             onReady: () {
//               setState(() {
//                 showTapTokenButton = true;
//               });
//             },
//             onSuccess: (String? success) {
//               setState(() {
//                 mCardSDKResponse = success;
//               });
//             },
//             onError: (String? error) {
//               setState(() {
//                 mCardSDKResponse = error;
//               });
//             },
//             generateToken: generateToken,
//           ),
//           const SizedBox(height: 10),
//           Visibility(
//             visible: showTapTokenButton,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     generateToken = true;
//                   });
//                 },
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(
//                     MediaQuery.of(context).size.width * 0.96,
//                     50,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text("Get Tap Token"),
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SingleChildScrollView(
//                 child: SelectableText(
//                   mCardSDKResponse == null
//                       ? ""
//                       : "SDK RESPONSE: $mCardSDKResponse",
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
