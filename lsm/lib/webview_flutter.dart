import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late InAppWebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 3, 0, 0),
      appBar: AppBar(
        title: Text('WebView'),
        backgroundColor: Colors.black,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        onWebViewCreated: (InAppWebViewController controller) {
          _webViewController = controller;
        },
        androidOnPermissionRequest: (InAppWebViewController controller,
            String origin, List<String> resources) async {
          return PermissionRequestResponse(
            resources: resources,
            action: PermissionRequestResponseAction.GRANT,
          );
        },
      ),
      // body: WebViewWidget(
      //   controller: WebViewController()
      //     ..setJavaScriptMode(
      //         JavaScriptMode.unrestricted) // Habilitar JavaScript
      //     ..setNavigationDelegate(
      //       NavigationDelegate(
      //         onPageStarted: (String url) {
      //           debugPrint('Página cargada: $url');
      //         },
      //       ),
      //     )
      //     ..loadRequest(Uri.parse(url)),
      // ),
    );
  }
}

