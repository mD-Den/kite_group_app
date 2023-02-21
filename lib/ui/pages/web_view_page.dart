import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kite_group_app/data/local_data_store/local_data_store.dart';
import 'package:kite_group_app/ui/widgets/custom_loader.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  static const String id = 'WebViewPage';

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final LocalDataStore _store = LocalDataStore();
  late InAppWebViewController _webViewController;
  late Uri? url;
  bool isLoaded = false;

  @override
  void initState() {
    url = Uri.parse(_store.getUrl());
    super.initState();
  }

  Future<bool> _exitApp(BuildContext context) async {
    log('${await _webViewController.canGoBack()}');
    if (await _webViewController.canGoBack()) {
      _webViewController.goBack();
      return Future.value(false);
    } else {
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        body: Stack(
          children: [
            isLoaded
                ? const SizedBox()
                : const CustomLoader(
                    color: Colors.purple,
                  ),
            InAppWebView(
                onLoadStop: (webViewController, url) {
                  setState(() {
                    isLoaded = true;
                  });
                },
                initialUrlRequest: URLRequest(url: Uri.parse(_store.getUrl())),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
                androidOnPermissionRequest: (InAppWebViewController controller,
                    String origin, List<String> resources) async {
                  log('android 11');
                  await Permission.camera.request();
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                }),
          ],
        ),
      ),
    );
  }
}
