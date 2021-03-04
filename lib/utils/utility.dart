import 'dart:io';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EHUtils {
  static Uint8List stringToUint8List(String source) {
    /*print('${source.length}: "$source" (${source.runes.length})');

    // String (Dart uses UTF-16) to bytes
    final List<int> list = <int>[];
    // ignore: avoid_function_literals_in_foreach_calls
    source.runes.forEach((int rune) {
      if (rune >= 0x10000) {
        rune -= 0x10000;
        final int firstWord = (rune >> 10) + 0xD800;
        list.add(firstWord >> 8);
        list.add(firstWord & 0xFF);
        final int secondWord = (rune & 0x3FF) + 0xDC00;
        list.add(secondWord >> 8);
        list.add(secondWord & 0xFF);
      } else {
        list.add(rune >> 8);
        list.add(rune & 0xFF);
      }
    });
    return Uint8List.fromList(list);*/
    final List<int> list = source.codeUnits;
    final Uint8List bytes = Uint8List.fromList(list);
    // final String string = String.fromCharCodes(bytes);
    return bytes;
  }

  static String stringToHex(String source) {
    final List<int> list = source.codeUnits;
    final Uint8List bytes = Uint8List.fromList(list);
    return formatBytesAsHexString(bytes);
  }

  /// Converts binary data to a hexdecimal representation.
  static String formatBytesAsHexString(Uint8List bytes) {
    final StringBuffer result = StringBuffer();
    for (int i = 0; i < bytes.lengthInBytes; i++) {
      final int part = bytes[i];
      result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
    }
    return result.toString();
  }

  /// Converts a hexdecimal representation to binary data.
  static Uint8List createUint8ListFromHexString(String hex) {
    final Uint8List result = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < hex.length; i += 2) {
      final String num = hex.substring(i, i + 2);
      final int byte = int.parse(num, radix: 16);
      result[i ~/ 2] = byte;
    }
    return result;
  }

  bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true); //如果debug模式下会触发赋值
    return inDebugMode;
  }

  static String getLangeage(String value) {
    for (final String key in EHConst.iso936.keys) {
      if (key.toUpperCase().trim() == value.toUpperCase().trim()) {
        return EHConst.iso936[key];
      }
    }
    return '';
  }

  /// list 分割
  static List<List<T>> splitList<T>(List<T> list, int len) {
    if (len <= 1) {
      return [list];
    }

    final List<List<T>> result = [];
    int index = 1;

    while (true) {
      if (index * len < list.length) {
        final List<T> temp = list.skip((index - 1) * len).take(len).toList();
        result.add(temp);
        index++;
        continue;
      }
      final List<T> temp = list.skip((index - 1) * len).toList();
      result.add(temp);
      break;
    }
    return result;
  }

  // 位图转map
  static Map<String, bool> convNumToCatMap(int catNum) {
    final List<String> catList = EHConst.catList;
    final Map catsNumMaps = EHConst.cats;
    final Map<String, bool> catMap = <String, bool>{};
    for (int i = 0; i < catList.length; i++) {
      final String catName = catList[i];
      final int curCatNum = catsNumMaps[catName];
      if (catNum & curCatNum != curCatNum) {
        catMap[catName] = true;
      } else {
        catMap[catName] = false;
      }
    }
    return catMap;
  }

  static int convCatMapToNum(Map<String, bool> catMap) {
    int totCatNum = 0;
    final Map catsNumMaps = EHConst.cats;
    catMap.forEach((String key, bool value) {
      if (!value) {
        totCatNum += catsNumMaps[key];
      }
    });
    return totCatNum;
  }

  static List<Map<String, String>> getFavListFromProfile() {
    final List<Map<String, String>> favcatList = <Map<String, String>>[];
    if (Global.profile.user.favcat != null) {
      for (final dynamic mapObj in Global.profile.user.favcat) {
        // logger.v('$mapObj');
        final Map<String, String> map = <String, String>{
          'favId': mapObj['favId'],
          'favTitle': mapObj['favTitle']
        };
        favcatList.add(map);
      }
    }

    return favcatList;
  }
}

class ColorsUtil {
  /// 十六进制颜色，
  /// hex, 十六进制值，例如：0xffffff,
  /// alpha, 透明度 [0.0,1.0]
  static Color hexColor(int hex, {double alpha = 1}) {
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    return Color.fromRGBO((hex & 0xFF0000) >> 16, (hex & 0x00FF00) >> 8,
        (hex & 0x0000FF) >> 0, alpha);
  }

  static Color hexStringToColor(String hexString, {double alpha = 1}) {
    // 如果传入的十六进制颜色值不符合要求，返回默认值
    if (hexString == null ||
        hexString.length != 7 ||
        int.tryParse(hexString.substring(1, 7), radix: 16) == null) {
      // s = '#999999';
      return null;
    }

    final int _hex =
        int.parse(hexString.substring(1, 7), radix: 16) + 0xFF000000;

    return hexColor(_hex, alpha: alpha);
  }

  static Color getTagColor(String hexColor) {
    if (hexColor != null && hexColor.isNotEmpty) {
      // logger.d(' $hexColor');
      return hexStringToColor(hexColor);
    }
    return null;
  }
}

class WidgetUtil {
  static Rect getWidgetGlobalRect(GlobalKey key) {
    final RenderBox renderBox = key.currentContext.findRenderObject();
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
        offset.dx, offset.dy, renderBox.size.width, renderBox.size.height);
  }
}

class CookieUtil {
  static Future<void> resetExCookieFromEh() async {
    final PersistCookieJar cookieJar = await Api.cookieJar;
    final List<Cookie> cookiesEh =
        await cookieJar.loadForRequest(Uri.parse(EHConst.EH_BASE_URL));
    final Cookie _memberId = Cookie.fromSetCookieValue(cookiesEh
        .firstWhere((Cookie cookie) => cookie.name == 'ipb_member_id')
        .toString()
        .replaceAll('.e-hentai.org', '.exhentai.org'));
    final Cookie _passHash = Cookie.fromSetCookieValue(cookiesEh
        .firstWhere((Cookie cookie) => cookie.name == 'ipb_pass_hash')
        .toString()
        .replaceAll('.e-hentai.org', '.exhentai.org'));

    cookieJar.delete(Uri.parse(EHConst.EX_BASE_URL));
    cookieJar.saveFromResponse(
        Uri.parse(EHConst.EX_BASE_URL), <Cookie>[_memberId, _passHash]);

    logger.d('cookiesEh\n' + cookiesEh.join('\n'));
  }

  static Future<void> fixEhCookie() async {
    final PersistCookieJar cookieJar = await Api.cookieJar;
    final List<Cookie> cookiesEh =
        await cookieJar.loadForRequest(Uri.parse(EHConst.EH_BASE_URL));
    final Cookie _memberId = cookiesEh
        .firstWhere((Cookie cookie) => cookie.name == 'ipb_member_id')
          ..domain = '.e-hentai.org';
    final Cookie _passHash = cookiesEh
        .firstWhere((Cookie cookie) => cookie.name == 'ipb_pass_hash')
          ..domain = '.e-hentai.org';

    cookieJar.saveFromResponse(
        Uri.parse(EHConst.EH_BASE_URL), <Cookie>[_memberId, _passHash]);

    logger.d('cookiesEh\n' + cookiesEh.join('\n'));
  }
}

enum DohResolve {
  google,
  cloudflare,
}
