import 'package:fehviewer/common/controller/base_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

class UserController extends ProfileController {
  bool get isLogin => user().username != null;
  Rx<User> user = User().obs;

  final EhConfigService _ehConfigService = Get.find();

  void _logOut() {
    user(User());
    final WebviewCookieManager cookieManager = WebviewCookieManager();
    cookieManager.clearCookies();
  }

  @override
  void onInit() {
    super.onInit();
    user(Global.profile.user ?? User());
    everProfile<User>(user, (User value) => Global.profile.user = value);
  }

  Future<void> showLogOutDialog(BuildContext context) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('注销用户'),
          content: const Text('确定注销?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(S.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(S.of(context).ok),
              onPressed: () async {
                (await Api.cookieJar).deleteAll();
                // userController.user(User());
                _logOut();
                _ehConfigService.isSiteEx.value = false;
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}
