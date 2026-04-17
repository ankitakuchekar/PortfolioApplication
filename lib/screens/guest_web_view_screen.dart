import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A clean, unauthenticated WebView for guest users.
/// No token, no cookies, no auth headers — just a plain browser session.
class GuestWebViewScreen extends StatefulWidget {
  const GuestWebViewScreen({super.key});

  @override
  State<GuestWebViewScreen> createState() => _GuestWebViewScreenState();
}

class _GuestWebViewScreenState extends State<GuestWebViewScreen> {
  InAppWebViewController? _webViewController;
  double _loadingProgress = 0;
  bool _hasError = false;
  bool _canGoBack = false;
  String _pageTitle =
      dotenv.env['URL_Redirection']?.replaceAll(
        RegExp(r'^https?://(www\.)?'),
        '',
      ) ??
      'bullionupdates.com';

  String get _homeUrl =>
      dotenv.env['URL_Redirection'] ?? 'https://www.bullionupdates.com';

  InAppWebViewSettings get _webViewSettings => InAppWebViewSettings(
    javaScriptEnabled: true,
    domStorageEnabled: true,
    databaseEnabled: true,
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    cacheMode: CacheMode.LOAD_NO_CACHE, // ✅ no stale auth cache
    userAgent:
        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36',
    sharedCookiesEnabled: false, // ✅ don't share any app cookies
    limitsNavigationsToAppBoundDomains: false,
    allowsBackForwardNavigationGestures: !kIsWeb,
    applePayAPIEnabled: false,
    useHybridComposition: true,
    supportZoom: false,
    builtInZoomControls: false,
    clearCache: true, // ✅ start with clean cache
  );

  /// Clear ALL cookies before loading so the website sees a fresh visitor
  Future<void> _clearSessionCookies() async {
    final cookieManager = CookieManager.instance();
    await cookieManager.deleteAllCookies();
    debugPrint('[GuestWebView] All cookies cleared for guest session');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final canGoBack = await _webViewController?.canGoBack() ?? false;
        if (canGoBack) {
          await _webViewController?.goBack();
        } else {
          if (mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        extendBody: false,
        extendBodyBehindAppBar: false,
        body: SafeArea(
          bottom: true,
          child: Stack(
            children: [
              _hasError ? _buildErrorView() : _buildWebView(),
              if (_loadingProgress < 1.0)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: _loadingProgress,
                    minHeight: 3,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      leading: _canGoBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: () => _webViewController?.goBack(),
            )
          : null,
      title: Text(
        _pageTitle,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Reload',
          onPressed: () async {
            setState(() {
              _hasError = false;
              _loadingProgress = 0;
            });
            await _webViewController?.reload();
          },
        ),
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(_homeUrl),
        // ✅ No auth headers — plain request like any browser
      ),
      initialSettings: _webViewSettings,
      onWebViewCreated: (controller) async {
        _webViewController = controller;
        // ✅ Clear cookies so website sees no previous session
        await _clearSessionCookies();
      },
      onLoadStart: (controller, url) {
        if (mounted)
          setState(() {
            _loadingProgress = 0.05;
            _hasError = false;
          });
      },
      onProgressChanged: (controller, progress) {
        if (mounted) setState(() => _loadingProgress = progress / 100);
      },
      onLoadStop: (controller, url) async {
        if (mounted) setState(() => _loadingProgress = 1.0);
        final title = await controller.getTitle();
        final host = url?.host ?? 'bullionupdates.com';
        if (mounted) {
          setState(() {
            _pageTitle = (title != null && title.isNotEmpty) ? title : host;
          });
        }
      },
      onUpdateVisitedHistory: (controller, url, isReload) async {
        final canGoBack = await controller.canGoBack();
        if (mounted) setState(() => _canGoBack = canGoBack);
      },
      onReceivedError: (controller, request, error) {
        if (request.isForMainFrame ?? false) {
          if (mounted)
            setState(() {
              _loadingProgress = 1.0;
              _hasError = true;
            });
          debugPrint('[GuestWebView] Error: ${error.description}');
        }
      },
      // ✅ Allow all navigation — guest can browse freely
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        return NavigationActionPolicy.ALLOW;
      },
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Could not load the page',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  _hasError = false;
                  _loadingProgress = 0;
                });
                await _webViewController?.reload();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
