import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// The Happer FAQ, rendered inside the app.
///
/// It used to open in the system browser, which dropped the user out of Happer
/// entirely — they came back, if at all, through the app switcher. The content
/// still comes from the website so support can edit it without shipping a
/// build; only the frame around it is ours.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key, this.url = defaultUrl});

  static const String defaultUrl = 'https://happer.fr/faq';

  final String url;

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  late final WebViewController _controller;
  late final Uri _pageUri = Uri.parse(widget.url);

  bool _isLoading = true;
  bool _hasError = false;

  /// The document actually being loaded, which is not always [_pageUri] —
  /// happer.fr/faq redirects to happer.fr/faq/, and comparing against the
  /// pre-redirect URL would miss an error on the page that really loaded.
  Uri? _currentUri;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onNavigationRequest,
          onPageStarted: (url) {
            _currentUri = Uri.tryParse(url);
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          // Only a failure of the page itself is worth an error screen. A
          // missing image or a blocked tracker also lands here, and blanking
          // a perfectly readable FAQ over one of those would be worse than
          // showing it.
          onWebResourceError: (error) {
            if (error.isForMainFrame == false) return;
            _showError();
          },
          // The FAQ URL is configured, not discovered, so a 404 is a real
          // possibility — surface it instead of rendering the site's own
          // error page inside our chrome.
          onHttpError: (error) {
            final status = error.response?.statusCode ?? 0;
            final failed = error.request?.uri;
            final isPageItself = failed != null &&
                (failed == _pageUri || failed == _currentUri);
            if (isPageItself && status >= 400) _showError();
          },
        ),
      );
    _load();
  }

  void _showError() {
    if (!mounted) return;
    setState(() {
      _hasError = true;
      _isLoading = false;
    });
  }

  void _load() {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    _controller.loadRequest(_pageUri);
  }

  /// Keeps FAQ browsing in the app but hands anything else to the OS: a
  /// `mailto:` support link or an off-site page has no business rendering in a
  /// window with no address bar and no way to tell where you are.
  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final target = Uri.tryParse(request.url);
    if (target == null) return NavigationDecision.prevent;

    final isWeb = target.scheme == 'http' || target.scheme == 'https';
    if (isWeb && target.host == _pageUri.host) {
      return NavigationDecision.navigate;
    }

    _openExternally(target);
    return NavigationDecision.prevent;
  }

  Future<void> _openExternally(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Back steps through the FAQ's own history before it leaves the screen, so
  /// tapping into an answer and going back doesn't exit to the support page.
  Future<void> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: HapperAppBar(title: 'FAQ', onBack: _handleBack),
        body: _hasError
            ? _FaqErrorView(onRetry: _load)
            : Stack(
                children: [
                  WebViewWidget(
                    controller: _controller,
                    // Without this the page scrolls the Flutter route instead
                    // of its own content on iOS.
                    gestureRecognizers: {
                      Factory<VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer(),
                      ),
                    },
                  ),
                  // Covers the web view completely while it paints, so the
                  // white flash and half-drawn page never show.
                  if (_isLoading)
                    const Positioned.fill(child: _FaqSkeleton()),
                ],
              ),
      ),
    );
  }
}

/// Loading state shaped like the content behind it — a stack of question rows
/// with a couple of answer lines under the first — rather than a spinner on an
/// empty screen.
class _FaqSkeleton extends StatelessWidget {
  const _FaqSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bar(height: 22, width: 160),
            const SizedBox(height: 24),
            _row(expanded: true),
            _row(),
            _row(),
            _row(),
            _row(),
          ],
        ),
      ),
    );
  }

  /// One collapsed question, or the first one opened with its answer showing.
  static Widget _row({bool expanded = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 10),
            _bar(height: 12, width: double.infinity),
            const SizedBox(height: 8),
            _bar(height: 12, width: double.infinity),
            const SizedBox(height: 8),
            _bar(height: 12, width: 200),
          ],
        ],
      ),
    );
  }

  static Widget _bar({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Shown when the FAQ can't be reached at all. Deliberately offers a way
/// forward rather than a dead end — support is one back-tap away on the screen
/// this was opened from.
class _FaqErrorView extends StatelessWidget {
  const _FaqErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline,
                size: 30,
                color: Color(0xFF8D8D8D),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'FAQ indisponible',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Impossible de charger la FAQ pour le moment. '
              'Vérifiez votre connexion et réessayez.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF6B6B6B),
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'RÉESSAYER',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
