import 'dart:io';
import 'dart:ui';

import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/user.dart';
import 'package:fehviewer/network/eh_login.dart';
import 'package:fehviewer/network/error.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_cookie_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FocusNode _nodePwd = FocusNode();

  //账号的控制器
  final TextEditingController _usernameController = TextEditingController();

  //密码的控制器
  final TextEditingController _passwdController = TextEditingController();

  final UserController userController = Get.find();

  bool _isLogin = false;
  bool _isWebLogin = false;

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(S.of(context).user_login),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 350),
                padding: const EdgeInsets.only(top: 50),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 38,
                      child: CupertinoTextField(
                        selectionHeightStyle: BoxHeightStyle.max,
                        style: const TextStyle(
                            textBaseline: TextBaseline.alphabetic),
                        controller: _usernameController,
                        placeholder: S.of(context).pls_i_username,
                        prefix: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 50),
                            child: Text(S.of(context).user_name)),
                        // prefixMode: OverlayVisibilityMode.never,
                        decoration: null,
                        // autofocus 自动获得焦点
//                    autofocus: true,
                        onEditingComplete: () {
                          // 点击键盘完成 焦点跳转密码输入框
                          FocusScope.of(context).requestFocus(_nodePwd);
                        },
                      ),
                    ),
                    Container(
                      height: 1,
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey4, context),
                    ),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.only(top: 10, bottom: 0),
                      child: CupertinoTextField(
                        style: const TextStyle(
                            textBaseline: TextBaseline.alphabetic),
                        controller: _passwdController,
                        placeholder: S.of(context).pls_i_passwd,
                        prefix: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 50),
                            child: Text(S.of(context).passwd)),
                        // prefixMode: OverlayVisibilityMode.never,
                        decoration: null,
                        obscureText: true,
                        focusNode: _nodePwd,
                        onEditingComplete: () {
                          // 点击键盘完成 帐号密码都非空的情况 直接登录
                          _login();
                        },
                      ),
                    ),
                    Container(
                      height: 1,
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey4, context),
                    ),
                    // 直接登录按钮
                    _buildLoginButton(),
                    // 网页登录按钮
                    _buildWebLoginButton(context),
                    // Cookie登录按钮
                    _buildCookieLoginButton(context),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildLoginButton() {
    return Container(
      height: 60,
      child: _isLogin
          ? Container(
//              padding: const EdgeInsets.all(8),
              child: const CupertinoActivityIndicator(
                radius: 14.0,
              ),
            )
          : CupertinoButton(
              child: Text(S.of(context).login),
//             color: CupertinoColors.activeBlue,
              onPressed: () {
                _login();
              },
            ),
    );
  }

  Widget _buildCookieLoginButton(BuildContext context) {
    return Container(
      height: 60,
      child: CupertinoButton(
        child: const Text('cookie 登录'),
        onPressed: () {
          Get.to(
            () => LoginCookiePage(),
            transition: Transition.cupertino,
          ).then((result) {
            if (result ?? false) {
              Get.back();
            }
          });
        },
      ),
    );
  }

  Widget _buildWebLoginButton(BuildContext context) {
    return Container(
      height: 60,
      child: _isWebLogin
          ? Container(
              child: const CupertinoActivityIndicator(
                radius: 14.0,
              ),
            )
          : CupertinoButton(
              child: Text(S.of(context).login_web),
              onPressed: () async {
                if (!Platform.isIOS && !Platform.isAndroid) {
                  showToast('平台尚未支持');
                  return;
                }

                final dynamic result = await Get.toNamed(
                  EHRoutes.webLogin,
                  preventDuplicates: false,
                );
                logger.i(' $result');
                if (result != null && result is Map) {
                  setState(() {
                    _isWebLogin = true;
                  });
                  try {
                    final User user = await EhUserManager().signInByWeb(result);
                    userController.user(user);
                    Get.back();
                  } catch (e, stack) {
                    showToast(e.toString());
                    logger.e('$e\n$stack');
                    setState(() {
                      _isWebLogin = false;
                    });
                  }
                }
              },
            ),
    );
  }

  /// 用户登录
  Future<void> _login() async {
    loggerNoStack.i({
      'username': _usernameController.text,
      'password': _passwdController.text
    });

    if (_usernameController.text.isEmpty || _passwdController.text.isEmpty) {
      showToast('username or password is empty');
      return;
    } else {
      setState(() {
        _isLogin = true;
      });
    }

    FocusScope.of(context).requestFocus(FocusNode());
    User user;
    try {
      user = await EhUserManager()
          .signIn(_usernameController.text, _passwdController.text);
      userController.user(user);
    } on EhError catch (e, stack) {
      logger.e('$e\n$stack');
      if (e.type == EhErrorType.LOGIN) {
        showToast('login fail');
      }
      // rethrow;
    } finally {
      setState(() {
        _isLogin = false;
      });
    }

    if (user != null) {
      Get.back();
    }
  }
}
