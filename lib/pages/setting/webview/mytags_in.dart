import 'dart:io' as io;

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide WebView;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InWebMyTags extends StatefulWidget {
  @override
  _InWebMyTagsState createState() => _InWebMyTagsState();
}

class _InWebMyTagsState extends State<InWebMyTags> {
  final CookieManager _cookieManager = CookieManager.instance();
  Future<void> _future;

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
  void initState() {
    super.initState();
    _future = _setCookie();
  }

  @override
  Widget build(BuildContext context) {
    InAppWebViewController _controller;

    final CupertinoPageScaffold cpf = CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(end: 6),
        middle: Text(S.of(context).ehentai_my_tags),
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
          ],
        ),
      ),
      child: SafeArea(
        child: InAppWebView(
          initialUrlRequest:
              URLRequest(url: Uri.parse('${Api.getBaseUrl()}/mytags')),
          onWebViewCreated: (InAppWebViewController controller) {
            _controller = controller;
          },
          onLoadStart: (InAppWebViewController controller, Uri url) {
            logger.d('Page started loading: $url');

            if (!url.toString().endsWith('/mytags')) {
              logger.d('阻止打开 $url');
              controller.stopLoading();
            }
          },
          onLoadStop: (InAppWebViewController controller, Uri url) async {
            logger.d('Page Finished loading: $url');
          },
        ),
      ),
    );

    return FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CupertinoActivityIndicator());
          }
          return cpf;
        });
  }
}
