/*
import 'dart:io';

import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebLoginView extends StatelessWidget {
  const WebLoginView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = S.of(context).login_web;
    WebViewController _controller;
    final WebviewCookieManager cookieManager = WebviewCookieManager();

    final CupertinoPageScaffold cpf = CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        transitionBetweenRoutes: false,
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: const Icon(
            CupertinoIcons.add_circled_solid,
            color: Color(0x000000),
          ),
          onPressed: () {
            final Map<String, String> cookieMap = <String, String>{};
            cookieManager
                .getCookies(EHConst.EH_BASE_URL)
                .then((List<Cookie> value) {
              logger.d(' $value');
              value.forEach(
                  (Cookie cookie) => cookieMap[cookie.name] = cookie.value);
              logger.d(' $cookieMap');
            });
          },
        ),
      ),
      child: SafeArea(
        child: WebView(
          initialUrl: EHConst.URL_SIGN_IN,
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
          onWebViewCreated: (WebViewController webViewController) {
            _controller = webViewController;
          },
          onPageStarted: (String url) {
            loggerNoStack.i('Page started loading: $url');
          },
          onPageFinished: (String url) {
            final Uri _uri = Uri.parse(url);
            logger.d(' ${_uri.queryParameters}');
            if (_uri.path == '/index.php' && _uri.queryParameters.isEmpty) {
              logger.i('onPageFinished $url');
              final Map<String, String> cookieMap = <String, String>{};
              cookieManager
                  .getCookies(EHConst.EH_BASE_URL)
                  .then((List<Cookie> value) {
                logger.d(' $value');
                value.forEach(
                    (Cookie cookie) => cookieMap[cookie.name] = cookie.value);
                logger.d(' $cookieMap');
                Get.back(result: cookieMap);
              });
            }
          },
          navigationDelegate: (NavigationRequest request) {
            final Uri _uri = Uri.parse(request.url);
            logger.d(' $_uri');
            if (_uri.path == '/index.php') {
              // _controller.loadUrl('${Api.getBaseUrl()}/uconfig.php');
              logger.d(' to index');
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      ),
    );

    return cpf;
  }
}
*/
