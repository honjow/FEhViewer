import 'dart:convert';

import 'package:FEhViewer/fehviewer/model/tagTranslat.dart';
import 'package:FEhViewer/http/dio_util.dart';
import 'package:FEhViewer/utils/dataBase.dart';
import 'package:FEhViewer/utils/storage.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:FEhViewer/values/storages.dart';
import 'package:flutter/cupertino.dart';

class EhTagDatabase {
  ///tag翻译
  static Future<String> generateTagTranslat() async {
    HttpManager httpManager = HttpManager.getInstance("https://api.github.com");

    const url = "/repos/EhTagTranslation/Database/releases/latest";

    var urlJson = await httpManager.get(url);

    // 获取发布时间 作为版本号
    var remoteVer = "";
    remoteVer = urlJson != null ? urlJson["published_at"] : '';
    debugPrint(remoteVer);

    var localVer = StorageUtil().getString(TAG_TRANSLAT_VER);
    debugPrint(localVer);

    // 测试
//    localVer = 'aaaaaaa';

    StorageUtil().setString(TAG_TRANSLAT_VER, remoteVer);

    var dbJson = jsonEncode(StorageUtil().getJSON(TAG_TRANSLAT));

    if (dbJson == null ||
        dbJson.isEmpty ||
        dbJson == "null" ||
        remoteVer != localVer) {
      debugPrint("TagTranslat更新");
      List assList = urlJson["assets"];

      Map assMap = new Map();
      assList.forEach((assets) {
        assMap[assets["name"]] = assets["browser_download_url"];
      });
      var dbUrl = assMap["db.text.json"];

      debugPrint(dbUrl);

      HttpManager httpDB = HttpManager.getInstance();
      dbJson = await httpDB.get(dbUrl);
      if (dbJson != null) {
        var dataAll = jsonDecode(dbJson.toString());
        var listDataP = dataAll["data"];
        StorageUtil().setJSON(TAG_TRANSLAT, jsonEncode(listDataP));

        await saveToDB(listDataP);
      }
      debugPrint("更新完成");
    } else {
      debugPrint("不需更新");
    }

    return remoteVer;
  }

  /// 保存到数据库
  ///
  static Future<void> saveToDB(List listDataP) async {
//    debugPrint('len p ${listDataP.length}');

    List<TagTranslat> tags = [];

    listDataP.forEach((objC) {
      debugPrint('${objC['namespace']}  ${objC['count']}');
      final _namespace = objC['namespace'];
      Map mapC = objC['data'];
      mapC.forEach((key, value) {
        final _key = key;
        final _name = value['name'] ?? '';
        final _intro = value['intro'] ?? '';
        final _links = value['links'] ?? '';
//        debugPrint('$_namespace $_key $_name $_intro $_links');

        tags.add(
            TagTranslat(_namespace, _key, _name, intro: _intro, links: _links));
      });
    });

    await DataBaseUtil.insertTagAll(tags);

    debugPrint('${tags.length}');
  }

  static Future<String> getTranTag(String tag) async {
    if (tag.contains(':')) {
//      debugPrint('$tag');
      RegExp rpfx = new RegExp(r"(\w:)(.+)");
      final rult = rpfx.firstMatch(tag);
      final pfx = rult.group(1) ?? '';
      final _nameSpase = EHConst.prefixToNameSpaceMap[pfx];
      final _tag = rult.group(2) ?? '';
      final _transTag =
          await DataBaseUtil.getTagTransStr(_tag, namespace: _nameSpase);

      return _transTag != null ? '$pfx$_transTag' : tag;
    } else {
      return await DataBaseUtil.getTagTransStr(tag);
    }
  }
}