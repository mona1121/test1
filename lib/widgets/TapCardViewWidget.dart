// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:card_flutter/card_flutter.dart';

// class CardViewScreen extends StatefulWidget {
//   const CardViewScreen({Key? key}) : super(key: key);

//   @override
//   _CardViewScreenState createState() => _CardViewScreenState();
// }

// class _CardViewScreenState extends State<CardViewScreen> {
//   dynamic mCardSDKResponse;
//   bool generateToken = false;
//   bool showTapTokenButton = false;

//   // Define parameters map for TapCardViewWidget
//   final Map<String, dynamic> parameters = {
//     "operator": {
//       "publicKey":
//           "pk_test_YhUjg9PNT8oDlKJ1aE2fMRz7" // Replace with your actual public key
//     },
//     "scope": "Token",
//     "purpose": "Charge",
//     "order": {
//       "id": "",
//       "amount": 1.0,
//       "currency": "SAR",
//       "description": "Authentication description",
//       "reference": ""
//     },
//     "customer": {
//       "id": "",
//       "name": [
//         {"lang": "en", "first": "TAP", "middle": "", "last": "PAYMENTS"}
//       ],
//       "nameOnCard": "TAP PAYMENTS",
//       "editable": true,
//       "contact": {
//         "email": "tap@tap.company",
//         "phone": {"countryCode": "+965", "number": "88888888"}
//       }
//     }
//   };

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payment Page'),
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(CupertinoIcons.back),
//         ),
//       ),
//       body: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TapCardViewWidget(
//             sdkConfiguration: parameters,
//             generateToken: generateToken,
//             onReady: () {
//               setState(() {
//                 showTapTokenButton = true;
//               });
//             },
//             onFocus: () {
//               setState(() {
//                 generateToken = false;
//               });
//             },
//             onSuccess: (String? success) {
//               setState(() {
//                 mCardSDKResponse = success.toString();
//                 generateToken = false;
//               });
//             },
//             onValidInput: (String? validInput) {
//               setState(() {
//                 mCardSDKResponse = validInput.toString();
//                 generateToken = false;
//               });
//             },
//             onHeightChange: (String? heightChange) {
//               setState(() {
//                 mCardSDKResponse = heightChange.toString();
//               });
//             },
//             onBinIdentification: (String? bindIdentification) {
//               setState(() {
//                 mCardSDKResponse = bindIdentification.toString();
//               });
//             },
//             onChangeSaveCard: (String? saveCard) {
//               setState(() {
//                 mCardSDKResponse = saveCard.toString();
//               });
//             },
//             onError: (String? error) {
//               setState(() {
//                 mCardSDKResponse = error.toString();
//                 generateToken = false;
//               });
//             },
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
//                       : "SDK RESPONSE : $mCardSDKResponse",
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