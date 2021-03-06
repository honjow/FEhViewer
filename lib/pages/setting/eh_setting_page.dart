import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/webview/mytags_in.dart';
import 'package:fehviewer/pages/setting/webview/web_mysetting_in.dart';
import 'package:fehviewer/store/tag_database.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'setting_base.dart';

class EhSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cps = CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          middle: Text(S.of(context).eh),
        ),
        child: SafeArea(
          child: ListViewEhSetting(),
        ));

    return cps;
  }
}

class ListViewEhSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final EhConfigService _ehConfigService = Get.find();
    final UserController userController = Get.find();

    final bool _siteEx = _ehConfigService.isSiteEx.value;
    final bool _jpnTitle = _ehConfigService.isJpnTitle.value;
    final bool _tagTranslat = _ehConfigService.isTagTranslat.value;
    final bool _galleryImgBlur = _ehConfigService.isGalleryImgBlur.value;
    final bool _favLongTap = _ehConfigService.isFavLongTap.value;
    final bool _isLogin = userController.isLogin;
    final bool _isClipboar = _ehConfigService.isClipboardLink.value;

    Future<void> _handleSiteChanged(bool newValue) async {
      _ehConfigService.isSiteEx(newValue);
    }

    void _handleJpnTitleChanged(bool newValue) {
      _ehConfigService.isJpnTitle(newValue);
    }

    void _handleTagTranslatChanged(bool newValue) {
      _ehConfigService.isTagTranslat.value = newValue;
      if (newValue) {
        try {
          EhTagDatabase.generateTagTranslat();
        } catch (e) {
          debugPrint('更新翻译异常 $e');
        }
      }
    }

    void _handleGalleryListImgBlurChanged(bool newValue) {
      _ehConfigService.isGalleryImgBlur.value = newValue;
    }

    void _handleFavLongTapChanged(bool newValue) {
      _ehConfigService.isFavLongTap.value = newValue;
    }

    void _handleClipboarLinkTapChange(bool val) {
      _ehConfigService.isClipboardLink.value = val;
    }

    final List<Widget> _list = <Widget>[
      if (_isLogin)
        TextSwitchItem(
          S.of(context).galery_site,
          intValue: _siteEx,
          onChanged: _handleSiteChanged,
          desc: S.of(context).current_site('E-Hentai'),
          descOn: S.of(context).current_site('ExHentai'),
        ),
      if (_isLogin)
        const SelectorSettingItem(
          title: 'Cookie',
          selector: '',
          onTap: showUserCookie,
        ),
      if (_isLogin)
        SelectorSettingItem(
          title: S.of(context).ehentai_settings,
          selector: S.of(context).setting_on_website,
          onTap: () {
            if (GetPlatform.isAndroid) {
              // Get.to(() => WebMySettingAP());
              Get.to(() => InWebMySetting());
            } else if (GetPlatform.isIOS) {
              Get.to(() => InWebMySetting());
            } else {
              showToast('Not support');
            }
          },
        ),
      if (_isLogin)
        SelectorSettingItem(
          hideLine: true,
          title: S.of(context).ehentai_my_tags,
          selector: S.of(context).mytags_on_website,
          onTap: () {
            if (GetPlatform.isAndroid) {
              // Get.to(() => WebMyTagsAP());
              Get.to(() => InWebMyTags());
            } else if (GetPlatform.isIOS) {
              Get.to(() => InWebMyTags());
            } else {
              showToast('Not support');
            }
          },
        ),
      if (_isLogin) Container(height: 38),
      Obx(() => TextSwitchItem('显示标签中文翻译',
          intValue: _tagTranslat,
          onChanged: _handleTagTranslatChanged,
          desc: '当前版本:${_ehConfigService.tagTranslatVer.value ?? "无"}')),
      TextSwitchItem(
        S.of(context).show_jpn_title,
        intValue: _jpnTitle,
        onChanged: _handleJpnTitleChanged,
        // desc: '如果该画廊有日文标题则优先显示',
      ),
      TextSwitchItem(
        '画廊封面模糊',
        intValue: _galleryImgBlur,
        onChanged: _handleGalleryListImgBlurChanged,
        hideLine: true,
        // desc: '画廊列表封面模糊效果',
      ),
      Container(height: 38),
      TextSwitchItem(
        '默认收藏夹设置',
        intValue: _favLongTap,
        onChanged: _handleFavLongTapChanged,
        desc: '无默认,每次进行选择',
        descOn: '使用上次选择，长按选择其他',
      ),
      TextSwitchItem(
        '剪贴板链接检测',
        intValue: _isClipboar,
        onChanged: _handleClipboarLinkTapChange,
        desc: '关闭',
        descOn: '自动检测剪贴板画廊链接',
      ),
      TextSwitchItem(
        '评论机翻按钮',
        intValue: _ehConfigService.commentTrans.value,
        onChanged: (bool newValue) =>
            _ehConfigService.commentTrans.value = newValue,
        desc: '关闭',
        descOn: '用谷歌翻译将评论翻译为简体中文',
      ),
      _buildListModeItem(context),
      _buildHistoryMaxItem(context),
    ];

    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (BuildContext context, int index) {
        return _list[index];
      },
    );
  }
}

/// 列表模式切换
Widget _buildListModeItem(BuildContext context) {
  final String _title = S.of(context).list_mode;
  final EhConfigService ehConfigService = Get.find();

  final Map<ListModeEnum, String> modeMap = <ListModeEnum, String>{
    ListModeEnum.list: S.of(context).listmode_medium,
    ListModeEnum.simpleList: S.of(context).listmode_small,
    ListModeEnum.waterfall: S.of(context).listmode_waterfall,
  };

  List<Widget> _getModeList(BuildContext context) {
    return List<Widget>.from(modeMap.keys.map((ListModeEnum element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text(modeMap[element]));
    }).toList());
  }

  Future<ListModeEnum> _showDialog(BuildContext context) {
    return showCupertinoModalPopup<ListModeEnum>(
        context: context,
        builder: (BuildContext context) {
          final CupertinoActionSheet dialog = CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(S.of(context).cancel)),
            actions: <Widget>[
              ..._getModeList(context),
            ],
          );
          return dialog;
        });
  }

  return Obx(() => SelectorSettingItem(
        title: _title,
        selector: modeMap[ehConfigService.listMode.value ?? ListModeEnum.list],
        onTap: () async {
          logger.v('tap ModeItem');
          final ListModeEnum _result = await _showDialog(context);
          if (_result != null) {
            // ignore: unnecessary_string_interpolations
            logger.v('${EnumToString.convertToString(_result)}');
            ehConfigService.listMode.value = _result;
          }
        },
      ));
}

/// 历史记录数量切换
Widget _buildHistoryMaxItem(BuildContext context) {
  final String _title = S.of(context).max_history;
  final EhConfigService ehConfigService = Get.find();

  String _getMaxNumText(int max) {
    if (max == 0) {
      return S.of(context).unlimited;
    } else {
      return '$max';
    }
  }

  List<Widget> _getModeList(BuildContext context) {
    return List<Widget>.from(EHConst.historyMax.map((int element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text(_getMaxNumText(element)));
    }).toList());
  }

  Future<int> _showActionSheet(BuildContext context) {
    return showCupertinoModalPopup<int>(
        context: context,
        builder: (BuildContext context) {
          final CupertinoActionSheet dialog = CupertinoActionSheet(
            // title: const Text('列表模式选择'),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(S.of(context).cancel)),
            actions: <Widget>[
              ..._getModeList(context),
            ],
          );
          return dialog;
        });
  }

  return Obx(() => SelectorSettingItem(
        title: _title,
        selector: _getMaxNumText(ehConfigService.maxHistory.value) ?? '',
        hideLine: true,
        onTap: () async {
          logger.v('tap ModeItem');
          final int _result = await _showActionSheet(context);
          if (_result != null) {
            ehConfigService.maxHistory.value = _result;
          }
        },
      ));
}
