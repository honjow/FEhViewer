import 'package:fehviewer/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../controller/splash_controller.dart';

/// 闪屏页
class SplashPage extends GetView<SplashController> {
  @override
  Widget build(BuildContext context) {
    final Widget container = (controller.sharedText != null &&
            controller.sharedText.isNotEmpty)
        ? Container(
            child:
                const Center(child: CupertinoActivityIndicator(radius: 20.0)),
          )
        : Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    LineIcons.cat,
                    // FontAwesomeIcons.heading,
                    size: 150.0,
                    color: Colors.grey,
                  ),
                  // Text(
                  //   S.of(context).welcome_text,
                  //   style: const TextStyle(color: Colors.grey),
                  // ),
                  Text(
                    S.of(context).app_title,
                    style: const TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
          );

    return CupertinoPageScaffold(
      child: container,
    );
  }
}
