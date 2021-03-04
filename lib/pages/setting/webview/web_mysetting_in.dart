import 'dart:io' as io;

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide WebView;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// iOS使用
class InWebMySetting extends StatelessWidget {
  final CookieManager _cookieManager = CookieManager.instance();

  Future<void> _setCookie() async {
    final List<io.Cookie> cookies =
        await Global.cookieJar.loadForRequest(Uri.parse(Api.getBaseUrl()));

    for (final io.Cookie cookie in cookies) {
      _cookieManager.setCookie(
          url: Uri.parse(Api.getBaseUrl()),
          name: cookie.name,
          value: cookie.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    InAppWebViewController _controller;

    final CupertinoPageScaffold cpf = CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(end: 6),
        middle: Text(S.of(context).ehentai_settings),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              child: const Icon(
                FontAwesomeIcons.redo,
                size: 20,
              ),
              onPressed: () async {
                _controller.reload();
              },
            ),
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              child: const Icon(
                FontAwesomeIcons.checkCircle,
                size: 24,
              ),
              onPressed: () async {
                // 保存配置
                _controller.evaluateJavascript(
                    source:
                        'document.querySelector("#apply > input[type=submit]").click();');
                // 写入cookie到dio
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: InAppWebView(
          // initialUrl: '${Api.getBaseUrl()}/uconfig.php',
          initialUrlRequest:
              URLRequest(url: Uri.parse('${Api.getBaseUrl()}/uconfig.php')),
          onWebViewCreated: (InAppWebViewController controller) {
            _controller = controller;
          },
          onLoadStart: (InAppWebViewController controller, Uri url) {
            logger.d('Page started loading: $url');

            if (!url.toString().endsWith('/uconfig.php')) {
              logger.d('阻止打开 $url');
              controller.stopLoading();
            }
          },
          onLoadStop: (InAppWebViewController controller, Uri url) async {
            logger.d('Page Finished loading: $url');
            // 写入cookie到dio
            _cookieManager.getCookies(url: url).then((value) {
              // List<Cookie> _cookies = value.forEach((key, value) { });
              final List<io.Cookie> _cookies = value
                  .map((Cookie e) =>
                      io.Cookie(e.name, e.value)..domain = e.domain)
                  .toList();

              logger.d('${_cookies.map((e) => e.toString()).join('\n')} ');

              Global.cookieJar.delete(Uri.parse(Api.getBaseUrl()), true);
              Global.cookieJar
                  .saveFromResponse(Uri.parse(Api.getBaseUrl()), _cookies);
            });
          },
        ),
      ),
    );

    return FutureBuilder<void>(
        future: _setCookie(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CupertinoActivityIndicator());
          }
          return cpf;
        });
  }
}
