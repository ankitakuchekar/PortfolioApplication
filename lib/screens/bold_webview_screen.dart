import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bold_portfolio/services/auth_service.dart';

class BuyWebViewScreen extends StatefulWidget {
  final String url;
  final String token;
  final String? userEmail;

  const BuyWebViewScreen({
    super.key,
    required this.url,
    required this.token,
    this.userEmail,
  });

  @override
  State<BuyWebViewScreen> createState() => _BuyWebViewScreenState();
}

class _BuyWebViewScreenState extends State<BuyWebViewScreen> {
  InAppWebViewController? _webViewController;
  double _loadingProgress = 0;
  bool _hasError = false;
  String _pageTitle = 'bullionupdates.com';
  bool _canGoBack = false; // ✅ CHANGE 1: new field

  // ✅ AFTER
  String get _autoLoginUrl {
    // Guest user — no token, just open the URL directly, skip auto-login
    if (widget.token.isEmpty) return widget.url;

    final productUri = Uri.tryParse(widget.url);
    final redirect = productUri != null
        ? '${productUri.path}${productUri.query.isNotEmpty ? '?${productUri.query}' : ''}'
        : '/';
    final baseWebUrl =
        dotenv.env['URL_Redirection'] ?? 'https://www.bullionupdates.com';
    return Uri.parse('$baseWebUrl/auto-login')
        .replace(queryParameters: {'token': widget.token, 'redirect': redirect})
        .toString();
  }

  String get _cookieDomain =>
      dotenv.env['WEBVIEW_COOKIE_DOMAIN'] ?? 'bullionupdates.com';

  List<String> get _allowedHosts {
    String bare(String h) => h.startsWith('www.') ? h.substring(4) : h;
    final hosts = <String>{};
    final bareCookie = bare(_cookieDomain);
    hosts.addAll([bareCookie, 'www.$bareCookie']);
    final productHost = Uri.tryParse(widget.url)?.host ?? '';
    if (productHost.isNotEmpty) {
      final bareProduct = bare(productHost);
      hosts.addAll([bareProduct, 'www.$bareProduct']);
    }
    return hosts.toList();
  }

  Future<void> _injectTokenCookie() async {
    final cookieManager = CookieManager.instance();
    final domains = <String>{
      _cookieDomain,
      Uri.tryParse(widget.url)?.host ?? _cookieDomain,
    };
    for (final domain in domains) {
      await cookieManager.setCookie(
        url: WebUri(widget.url),
        name: 'token',
        value: widget.token,
        domain: domain,
        path: '/',
        isSecure: true,
        isHttpOnly: false,
        sameSite: HTTPCookieSameSitePolicy.LAX,
      );
    }
  }

  InAppWebViewSettings get _webViewSettings => InAppWebViewSettings(
    javaScriptEnabled: true,
    domStorageEnabled: true,
    databaseEnabled: true,
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    cacheMode: CacheMode.LOAD_DEFAULT,
    userAgent: 'BoldPortfolioApp/1.0 Flutter',
    sharedCookiesEnabled: true,
    limitsNavigationsToAppBoundDomains: false,
    allowsBackForwardNavigationGestures: !kIsWeb,
    applePayAPIEnabled: false,
    useHybridComposition: true,
    supportZoom: false,
    builtInZoomControls: false,
  );

  // ✅ CHANGE 2: wrap Scaffold with PopScope
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

  // ✅ CHANGE 3: add leading back arrow driven by _canGoBack
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
    return SafeArea(
      bottom: true,
      child: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(_autoLoginUrl),
          headers: {'x-flutter-app': 'true', 'x-client-type': 'mobile'},
        ),
        initialSettings: _webViewSettings,
        onWebViewCreated: (controller) async {
          _webViewController = controller;
          if (widget.token.isNotEmpty) {
            // ← only inject cookie for logged-in users
            await _injectTokenCookie();
          }
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
          final host = url?.host ?? _cookieDomain;
          if (mounted) {
            setState(() {
              _pageTitle =
                  (title != null &&
                      title.isNotEmpty &&
                      title != 'Bold Bullion' &&
                      title != 'Securely signing you in…')
                  ? title
                  : host;
            });
          }
        },
        // ✅ CHANGE 4: track WebView history on every navigation
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
          }
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final uri = navigationAction.request.url;
          if (uri == null) return NavigationActionPolicy.ALLOW;
          final isAllowed = _allowedHosts.any(
            (h) => uri.host == h || uri.host.endsWith('.$h'),
          );
          if (isAllowed) return NavigationActionPolicy.ALLOW;
          return NavigationActionPolicy.CANCEL;
        },
      ),
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
