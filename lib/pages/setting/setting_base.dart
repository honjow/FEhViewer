import 'dart:io';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/dns_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const double kItemHeight = 50.0;

/// 选择类型的设置项
class SelectorSettingItem extends StatefulWidget {
  const SelectorSettingItem({
    Key key,
    this.onTap,
    @required this.title,
    @required this.selector,
    this.hideLine = false,
  }) : super(key: key);

  final String title;
  final String selector;
  final bool hideLine;

  // 点击回调
  final VoidCallback onTap;

  @override
  _SelectorSettingItemState createState() => _SelectorSettingItemState();
}

class _SelectorSettingItemState extends State<SelectorSettingItem> {
  Color _color;
  Color _pBackgroundColor;

  @override
  void initState() {
    super.initState();
    _color =
        CupertinoDynamicColor.resolve(ehTheme.itemBackgroundColor, Get.context);
    _pBackgroundColor = _color;
  }

  @override
  Widget build(BuildContext context) {
    final Color color =
        CupertinoDynamicColor.resolve(ehTheme.itemBackgroundColor, context);
    if (_pBackgroundColor.value != color.value) {
      _color = color;
      _pBackgroundColor = color;
    }

    final Container container = Container(
      color: _color,
      child: Column(
        children: <Widget>[
          Container(
            height: kItemHeight,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Row(
              children: <Widget>[
                Text(
                  widget.title,
                  style: const TextStyle(
                    height: 1.0,
                  ),
                ),
                const Spacer(),
                Text(
                  widget.selector ?? '',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey2,
                  ),
                ),
                const Icon(
                  CupertinoIcons.forward,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
          if (!widget.hideLine)
            Divider(
              indent: 20,
              height: 0.6,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey4, context),
            ),
        ],
      ),
    );

    return GestureDetector(
      child: container,
      // 不可见区域有效
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _updatePressedColor(),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 80), () {
          _updateNormalColor();
        });
      },
      onTapCancel: () => _updateNormalColor(),
    );
  }

  void _updateNormalColor() {
    setState(() {
      _color =
          CupertinoDynamicColor.resolve(ehTheme.itemBackgroundColor, context);
    });
  }

  void _updatePressedColor() {
    setState(() {
      _color =
          CupertinoDynamicColor.resolve(CupertinoColors.systemGrey4, context);
    });
  }
}

/// 开关类型
class TextSwitchItem extends StatefulWidget {
  const TextSwitchItem(
    this.title, {
    this.intValue,
    this.onChanged,
    this.desc,
    this.descOn,
    Key key,
    this.hideLine = false,
    this.icon,
    this.iconIndent = 0.0,
  }) : super(key: key);

  final bool intValue;
  final ValueChanged<bool> onChanged;
  final String title;
  final String desc;
  final String descOn;
  final bool hideLine;
  final Widget icon;
  final double iconIndent;

  @override
  _TextSwitchItemState createState() => _TextSwitchItemState();
}

class _TextSwitchItemState extends State<TextSwitchItem> {
  bool _switchValue;
  String _desc;

  void _handOnChanged() {
    widget.onChanged(_switchValue);
  }

  @override
  Widget build(BuildContext context) {
    _switchValue = _switchValue ?? widget.intValue ?? false;
    _desc = _switchValue ? widget.descOn : widget.desc;
    return Container(
      color:
          CupertinoDynamicColor.resolve(ehTheme.itemBackgroundColor, context),
      child: Column(
        children: <Widget>[
          Container(
            height: kItemHeight,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: <Widget>[
                if (widget.icon != null) widget.icon,
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: const TextStyle(
                          height: 1.0,
                        ),
                      ),
                      if (_desc != null || widget.desc != null)
                        Text(
                          _desc ?? widget.desc,
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: CupertinoColors.systemGrey),
                        ).paddingOnly(top: 2.0),
                    ]),
                Expanded(
                  child: Container(),
                ),
                if (widget.onChanged != null)
                  CupertinoSwitch(
                    onChanged: (bool value) {
                      setState(() {
                        _switchValue = value;
                        _desc = value ? widget.descOn : widget.desc;
                        _handOnChanged();
                      });
                    },
                    value: _switchValue,
                  ),
              ],
            ),
          ),
          if (!widget.hideLine)
            Divider(
              indent: 20 + widget.iconIndent,
              height: 0.6,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey4, context),
            ),
        ],
      ),
    );
  }
}

/// 普通文本类型
class TextItem extends StatefulWidget {
  const TextItem(
    this.title, {
    this.desc,
    this.onTap,
    Key key,
    this.height = kItemHeight,
    this.hideLine = false,
  }) : super(key: key);

  final String title;
  final String desc;
  final VoidCallback onTap;
  final double height;
  final bool hideLine;

  @override
  _TextItemState createState() => _TextItemState();
}

class _TextItemState extends State<TextItem> {
  Color _color;
  Color _pBackgroundColor;

  @override
  void initState() {
    super.initState();
    _color =
        CupertinoDynamicColor.resolve(ehTheme.itemBackgroundColor, Get.context);
    _pBackgroundColor = _color;
  }

  @override
  Widget build(BuildContext context) {
    final Color color =
        CupertinoDynamicColor.resolve(ehTheme.itemBackgroundColor, context);
    if (_pBackgroundColor.value != color.value) {
      _color = color;
      _pBackgroundColor = color;
    }

    final Widget item = Container(
      color: _color,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.title,
                    style: const TextStyle(
                      height: 1.0,
                    ),
                  ),
                  Text(
                    widget.desc,
                    style: const TextStyle(
                        fontSize: 12.5, color: CupertinoColors.systemGrey),
                  ).paddingOnly(top: 2.0),
                ]),
          ),
          if (!widget.hideLine)
            Divider(
              indent: 20,
              height: 0.5,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey4, context),
            ),
        ],
      ),
    );

    return GestureDetector(
      child: item,
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      onTapDown: (_) => _updatePressedColor(),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _updateNormalColor();
        });
      },
      onTapCancel: () => _updateNormalColor(),
    );
  }

  void _updateNormalColor() {
    setState(() {
      _color = CupertinoDynamicColor.resolve(
          ehTheme.itemBackgroundColor, Get.context);
    });
  }

  void _updatePressedColor() {
    setState(() {
      _color =
          CupertinoDynamicColor.resolve(CupertinoColors.systemGrey4, context);
    });
  }
}

Future<void> showCustomHostEditer(BuildContext context, {int index}) async {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _addrController = TextEditingController();
  final DnsService dnsConfigController = Get.find();
  final FocusNode _nodeAddr = FocusNode();
  return showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) {
      final bool _isAddNew = index == null;
      if (!_isAddNew) {
        _hostController.text = dnsConfigController.hosts[index].host;
        _addrController.text = dnsConfigController.hosts[index].addr;
      }

      return CupertinoAlertDialog(
        content: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CupertinoTextField(
                decoration: BoxDecoration(
                  color: ehTheme.textFieldBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                enabled: _isAddNew,
                clearButtonMode: _isAddNew
                    ? OverlayVisibilityMode.editing
                    : OverlayVisibilityMode.never,
                controller: _hostController,
                placeholder: 'Host',
                autofocus: _isAddNew,
                onEditingComplete: () {
                  // 点击键盘完成
                  FocusScope.of(context).requestFocus(_nodeAddr);
                },
              ),
              Container(
                height: 10,
              ),
              CupertinoTextField(
                decoration: BoxDecoration(
                  color: ehTheme.textFieldBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                clearButtonMode: OverlayVisibilityMode.editing,
                controller: _addrController,
                placeholder: 'Addr',
                focusNode: _nodeAddr,
                autofocus: !_isAddNew,
                onEditingComplete: () {
                  // 点击键盘完成
                  if (dnsConfigController.addCustomHost(
                      _hostController.text.trim(), _addrController.text.trim()))
                    Get.back();
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(S.of(context).cancel),
            onPressed: () {
              Get.back();
            },
          ),
          CupertinoDialogAction(
            child: Text(S.of(context).ok),
            onPressed: () {
              if (dnsConfigController.addCustomHost(
                  _hostController.text.trim(), _addrController.text.trim()))
                Get.back();
            },
          ),
        ],
      );
    },
  );
}

Future<void> showUserCookie() async {
  final List<String> _c = Global.profile.user.cookie.split(';');

  final List<Cookie> _cookies =
      _c.map((e) => Cookie.fromSetCookieValue(e)).toList();

  final String _cookieString =
      _cookies.map((e) => '${e.name}: ${e.value}').join('\n');
  logger.d('$_cookieString ');

  return showCupertinoDialog<void>(
    context: Get.context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text('Cookie'),
        content: Container(
          child: Column(
            children: [
              Text(
                S.of(context).KEEP_IT_SAFE,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ).paddingOnly(bottom: 4),
              // Text(
              //   _cookieString,
              //   textAlign: TextAlign.justify,
              //   style: const TextStyle(
              //     fontSize: 14,
              //   ),
              // ),
              CupertinoFormSection.insetGrouped(
                margin: const EdgeInsetsDirectional.fromSTEB(0, 0.0, 0, 5.0),
                backgroundColor: null,
                children: _cookies
                    .map((e) => CupertinoTextFormFieldRow(
                          prefix: Text(
                            e.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: const TextStyle(fontSize: 14),
                          initialValue: e.value,
                          readOnly: true,
                          maxLines: 2,
                          minLines: 1,
                          textAlign: TextAlign.right,
                        ))
                    .toList(),
              ),
            ],
          ).paddingSymmetric(vertical: 8),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(S.of(context).cancel),
            onPressed: () {
              Get.back();
            },
          ),
          CupertinoDialogAction(
            child: Text(S.of(context).copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _cookieString));
              Get.back();
              showToast(S.of(context).copied_to_clipboard);
            },
          ),
        ],
      );
    },
  );
}
