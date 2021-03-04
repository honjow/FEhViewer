import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/colors.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/base_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'ehconfig_service.dart';

class ThemeService extends ProfileService {
  final EhConfigService _ehConfigService = Get.find();
  final Rx<ThemesModeEnum> _themeModel = ThemesModeEnum.system.obs;
  Rx<Brightness> platformBrightness =
      WidgetsBinding.instance.window.platformBrightness.obs;

  set themeModel(ThemesModeEnum value) {
    _themeModel.value = value;
  }

  ThemesModeEnum get themeModel {
    return _themeModel.value;
  }

  CupertinoThemeData get _getDarkTheme => _ehConfigService.isPureDarkTheme.value
      ? ThemeColors.darkPureTheme
      : ThemeColors.darkGrayTheme;

  CupertinoThemeData get themeData {
    switch (themeModel) {
      case ThemesModeEnum.system:
        return platformBrightness.value == Brightness.dark
            ? _getDarkTheme
            : ThemeColors.ligthTheme;
      case ThemesModeEnum.ligthMode:
        return ThemeColors.ligthTheme;
      case ThemesModeEnum.darkMode:
        return _getDarkTheme;
      default:
        return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _themeModel.value = EnumToString.fromString(
            ThemesModeEnum.values, Global.profile.theme ?? '') ??
        ThemesModeEnum.system;
    everFromEunm(_themeModel, (String value) {
      Global.profile.theme = value;
    });
  }
}

final EHTheme ehTheme = EHTheme();

class EHTheme {
  final ThemeService _themeService = Get.find();
  final EhConfigService _ehConfigService = Get.find();

  Color _getColorWithTheme(EhDynamicColor ehcolor) {
    final Color effDarkColor = _ehConfigService.isPureDarkTheme.value
        ? ehcolor.darkColor
        : ehcolor.darkGrayColor;

    switch (_themeService.themeModel) {
      case ThemesModeEnum.system:
        return _themeService.platformBrightness.value == Brightness.dark
            ? effDarkColor
            : ehcolor.color;
      case ThemesModeEnum.ligthMode:
        return ehcolor.color;
      case ThemesModeEnum.darkMode:
        return effDarkColor;
      default:
        return null;
    }
  }

  CupertinoThemeData get themeData => _themeService.themeData;

  /// 文本输入框的背景色
  Color get textFieldBackgroundColor =>
      _getColorWithTheme(EhDynamicColors.textFieldBackground);

  /// 评论输入框颜色
  Color get commentTextFieldBackgroundColor =>
      _getColorWithTheme(EhDynamicColors.commentTextFieldBackground);

  // 收藏备注输入框颜色
  Color get favnoteTextFieldBackgroundColor =>
      _getColorWithTheme(EhDynamicColors.favnoteTextFieldBackground);

  /// item 背景色
  Color get itemBackgroundColor =>
      _getColorWithTheme(EhDynamicColors.itemBackground);

  bool get _isSeldark => _themeService.themeModel == ThemesModeEnum.darkMode;
  bool get _isSelLigth => _themeService.themeModel == ThemesModeEnum.ligthMode;

  bool get isDarkMode {
    if (_isSelLigth) {
      return false;
    } else {
      return _isSeldark ||
          _themeService.platformBrightness.value == Brightness.dark;
    }
  }
}
