import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView'),
        backgroundColor: Colors.black,
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                print('Pagina cargada: $url');
              },
            ),
          )
          ..loadRequest(Uri.parse(url)),
      ),
    );
  }
}
