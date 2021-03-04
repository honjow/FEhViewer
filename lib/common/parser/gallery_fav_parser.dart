import 'package:dio/dio.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/dio_util.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

class GalleryFavParser {
  /// 收藏操作
  static Future<void> galleryAddfavorite(String gid, String token,
      {String favcat = 'favdel', String favnote}) async {
    final HttpManager httpManager = Api.getHttpManager(cache: false);

    final String url = '/gallerypopups.php?gid=$gid&t=$token&act=addfav';
    final String cookie = Global.profile?.user?.cookie ?? '';

    // final Options _cacheOptions =
    //     Api.getCacheOptions(forceRefresh: true).merge(headers: {
    //   'Cookie': cookie,
    // });

    final Options _cacheOptions = Api.getCacheOptions(forceRefresh: true)
      ..headers['Cookie'] = cookie;

    final FormData formData =
        FormData.fromMap({'favcat': favcat, 'update': '1'});

    final Response response = await httpManager.postForm(
      url,
      options: _cacheOptions,
      data: formData,
    );

    saveFavcat(gid, token);
  }

  static Future<List<Map<String, String>>> gallerySelfavcat(
      String gid, String token) async {
    final HttpManager httpManager = Api.getHttpManager(cache: false);
    // final HttpManager httpManager = HttpManager.getInstance(
    //     EHConst.getBaseSite(Global.profile.ehConfig.siteEx ?? false));

    final String url = '/gallerypopups.php?gid=$gid&t=$token&act=addfav';
    final String cookie = Global.profile?.user?.cookie ?? '';

    final Options options = Options(headers: {
      'Cookie': cookie,
    });

    // final Options _cacheOptions =
    //     Api.getCacheOptions(forceRefresh: true).merge(headers: {
    //   'Cookie': cookie,
    // });

    final Options _cacheOptions = Api.getCacheOptions(forceRefresh: true)
      ..headers['Cookie'] = cookie;

    final String response = await httpManager.get(
      url,
      options: _cacheOptions,
    );

    return parserAddFavPage(response);
  }

  static List<Map<String, String>> parserAddFavPage(String response) {
    // 解析响应信息dom
    final Document document = parse(response);

    print('frome parserAddFavPage');

    final List<Map<String, String>> favList = <Map<String, String>>[];

    List<Element> favcats =
        document.querySelectorAll('#galpop > div > div.nosel > div');
    for (final Element fav in favcats) {
      final List<Element> divs = fav.querySelectorAll('div');
      final String favId =
          divs[0].querySelector('input').attributes['value'].trim();
      final String favTitle = divs[2].text.trim();
//      logger.v('$favId  $favTitle');
      favList.add(<String, String>{'favId': favId, 'favTitle': favTitle});
    }

    return favList.sublist(0, 10);
  }

  static Future<List<Map<String, String>>> getFavcat(
      {String gid, String token, bool cache = true}) async {
    // profile为空或者cache标志否
    if (Global.profile.user.favcat == null ||
        Global.profile.user.favcat.isEmpty ||
        !cache) {
      if (gid != null && gid.isNotEmpty && token.isNotEmpty) {
        // logger.v('$gid  $token');
        Global.profile.user.favcat = await gallerySelfavcat(gid, token);
      }
    }

    final List<Map<String, String>> favcatList =
        EHUtils.getFavListFromProfile();
    return Future<List<Map<String, String>>>.value(favcatList);
  }

  static Future<void> saveFavcat(String gid, String token) async {
    Global.profile.user.favcat = await gallerySelfavcat(gid, token);
  }
}
