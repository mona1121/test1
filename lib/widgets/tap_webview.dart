import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../screens/ThankYou_screen.dart';

class TapPaymentWebView extends StatefulWidget {
  final String paymentUrl;

  const TapPaymentWebView({required this.paymentUrl});

  @override
  State<TapPaymentWebView> createState() => _TapPaymentWebViewState();
}

class _TapPaymentWebViewState extends State<TapPaymentWebView> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Payment"),
        backgroundColor: Colors.white,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
