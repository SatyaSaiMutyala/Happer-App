import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';

class ContractWebViewScreen extends StatefulWidget {
  const ContractWebViewScreen({Key? key}) : super(key: key);

  @override
  State<ContractWebViewScreen> createState() => _ContractWebViewScreenState();
}

class _ContractWebViewScreenState extends State<ContractWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _isLoading = false),
      ));
    _loadContract();
  }

  Future<void> _loadContract() async {
    final html =
        await rootBundle.loadString('assets/html/esign_agreement.html');
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

    final sealBytes = await rootBundle.load('assets/images/seal.png');
    final sealDataUri =
        'data:image/png;base64,${base64Encode(sealBytes.buffer.asUint8List())}';

    final filled = html
        .replaceAll('{{esigned_date}}', today)
        .replaceAll('{{creator_name}}', 'Prénom Nom')
        .replaceAll('{{creator_username}}', 'Nom d\'utilisateur')
        .replaceAll('{{creator_email}}', 'Email')
        .replaceAll('{{creator_phone}}', 'Téléphone')
        .replaceAll('{{creator_address}}', 'Adresse')
        .replaceAll('{{creator_signature}}', 'Signature')
        .replaceAll('{{company_stamp_url}}', sealDataUri);
    _controller.loadHtmlString(filled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Contrat Happer Creator',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
            gestureRecognizers: {
              Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
              ),
            },
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.black)),
        ],
      ),
    );
  }
}
