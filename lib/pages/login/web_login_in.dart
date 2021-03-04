import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

class WebLoginViewIn extends StatelessWidget {
  WebLoginViewIn({
    Key key,
  }) : super(key: key);

  final CookieManager _cookieManager = CookieManager.instance();

  @override
  Widget build(BuildContext context) {
    final String title = S.of(context).login_web;
    InAppWebViewController _controller;
    final WebviewCookieManager cookieManager = WebviewCookieManager();

    final CupertinoPageScaffold cpf = CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        transitionBetweenRoutes: false,
      ),
      child: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(EHConst.URL_SIGN_IN)),
          onWebViewCreated: (InAppWebViewController webViewController) {
            _controller = webViewController;
          },
          onLoadStart: (InAppWebViewController controller, Uri url) {
            logger.d('Page started loading: $url');

            if (!(url.path == '/uconfig.php') && !(url.path == '/index.php')) {
              logger.d('阻止打开 $url');
              controller.stopLoading();
            }
          },
          onLoadStop: (InAppWebViewController controller, Uri url) async {
            logger.d('Page Finished loading: $url');

            if (url.path == '/index.php' && url.queryParameters.isEmpty) {
              final Map<String, String> cookieMap = <String, String>{};
              // 写入cookie到dio
              _cookieManager.getCookies(url: url).then((List<Cookie> value) {
                logger.d(' $value');
                value.forEach(
                    (Cookie cookie) => cookieMap[cookie.name] = cookie.value);
                logger.d(' $cookieMap');
                Get.back(result: cookieMap);
              });
            }
          },
        ),
      ),
    );

    return cpf;
  }
}
