import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InvoiceViewerScreen extends StatefulWidget {
  final String invoiceUrl;
  final String? orderTitle;

  const InvoiceViewerScreen({
    Key? key,
    required this.invoiceUrl,
    this.orderTitle,
  }) : super(key: key);

  @override
  State<InvoiceViewerScreen> createState() => _InvoiceViewerScreenState();
}

class _InvoiceViewerScreenState extends State<InvoiceViewerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              setState(() {
                _isLoading = false;
                _hasError = true;
                _errorMessage = error.description;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.invoiceUrl));
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.orderTitle?.toUpperCase() ?? 'FACTURE',
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView
          if (!_hasError)
            WebViewWidget(controller: _controller),

          // Error State
          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Impossible de charger la facture',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage ?? 'Une erreur s\'est produite',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                        });
                        _initializeWebView();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Loading Indicator
          if (_isLoading && !_hasError)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chargement de la facture...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: 'Lato',
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
