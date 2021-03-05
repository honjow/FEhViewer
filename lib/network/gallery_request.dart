import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/controller/advance_search_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/parser/eh_parser.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/galleryItem.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery/controller/archiver_controller.dart';
import 'package:fehviewer/pages/gallery/controller/torrent_controller.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/utils/dio_util.dart';
import 'package:fehviewer/utils/https_proxy.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/time.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:html_unescape/html_unescape.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:tuple/tuple.dart';

import 'error.dart';

final Api api = Api();

// ignore: avoid_classes_with_only_static_members
class Api {
  Api() {
    final String _baseUrl = EHConst.getBaseSite(
        Get.find<EhConfigService>().isSiteEx.value ?? false);
    httpManager = HttpManager.getInstance(baseUrl: _baseUrl);
  }

  HttpManager httpManager;
  String _baseUrl;

  //改为使用 PersistCookieJar，在文档中有介绍，PersistCookieJar将cookie保留在文件中，
  // 因此，如果应用程序退出，则cookie始终存在，除非显式调用delete
  static PersistCookieJar _cookieJar;

  static Future<PersistCookieJar> get cookieJar async {
    // print(_cookieJar);
    if (_cookieJar == null) {
      print('获取的文件系统目录 appSupportPath： ' + Global.appSupportPath);
      _cookieJar =
          PersistCookieJar(storage: FileStorage(Global.appSupportPath));
    }
    return _cookieJar;
  }

  static HttpManager getHttpManager(
      {bool cache = true, String baseUrl, int connectTimeout}) {
    final String _baseUrl = EHConst.getBaseSite(
        Get.find<EhConfigService>().isSiteEx.value ?? false);
    return HttpManager(baseUrl ?? _baseUrl,
        cache: cache, connectTimeout: connectTimeout);
  }

  static dio.Options getCacheOptions(
      {bool forceRefresh = false, dio.Options options}) {
    return buildCacheOptions(
      const Duration(days: 5),
      maxStale: const Duration(days: 7),
      forceRefresh: forceRefresh,
      options: options,
    );
  }

  static String getBaseUrl({bool isSiteEx}) {
    return EHConst.getBaseSite(
        isSiteEx ?? Get.find<EhConfigService>().isSiteEx.value ?? false);
  }

  static String getSiteFlg() {
    return (Get.find<EhConfigService>().isSiteEx.value ?? false) ? 'EH' : 'EX';
  }

  /// 获取热门画廊列表
  static Future<Tuple2<List<GalleryItem>, int>> getPopular({
    int page,
    String fromGid,
    String serach,
    int cats,
    bool refresh = false,
    SearchType searchType = SearchType.normal,
    dio.CancelToken cancelToken,
    String favcat,
  }) async {
    // logger.d('getPopular');
    const String url = '/popular';

    await CustomHttpsProxy.instance.init();
    final dio.Options _cacheOptions = getCacheOptions(forceRefresh: refresh);

    final String response =
        await getHttpManager().get(url, options: _cacheOptions);
    // logger.d('$response');

    // 列表样式检查 不符合则重新设置
    final bool isDml = GalleryListParser.isGalleryListDmL(response);
    if (!isDml) {
      logger.d('reset inline_set');
      final String response = await getHttpManager().get(
        url,
        options: getCacheOptions(forceRefresh: true),
        params: <String, dynamic>{
          'inline_set': 'dm_l',
        },
        cancelToken: cancelToken,
      );
      return await GalleryListParser.parseGalleryList(response,
          refresh: refresh);
    } else {
      return await GalleryListParser.parseGalleryList(response,
          refresh: refresh);
    }
  }

  /// Watched
  static Future<Tuple2<List<GalleryItem>, int>> getWatched({
    int page,
    String fromGid,
    String serach,
    int cats,
    bool refresh = false,
    SearchType searchType = SearchType.normal,
    dio.CancelToken cancelToken,
    String favcat,
  }) async {
    // logger.d('getWatched');
    const String _url = '/watched';
    final dio.Options _cacheOptions = getCacheOptions(forceRefresh: refresh);

    final Map<String, dynamic> params = <String, dynamic>{
      'page': page,
      if (fromGid != null) 'from': fromGid,
      'f_cats': cats,
    };

    /// 复用筛选
    final AdvanceSearchController _searchController = Get.find();
    if (_searchController.enableAdvance ?? false) {
      params['advsearch'] = 1;
      params.addAll(_searchController.advanceSearchMap);
    }

    await CustomHttpsProxy.instance.init();
    final String response = await getHttpManager().get(
      _url,
      options: _cacheOptions,
      params: params,
    );

    // 列表样式检查 不符合则重新设置
    final bool isDml = GalleryListParser.isGalleryListDmL(response);
    if (!isDml) {
      params['inline_set'] = 'dm_l';
      final String response = await getHttpManager().get(
        _url,
        options: getCacheOptions(forceRefresh: true),
        params: params,
      );
      return await GalleryListParser.parseGalleryList(response,
          refresh: refresh);
    } else {
      return await GalleryListParser.parseGalleryList(response,
          refresh: refresh);
    }
  }

  /// 获取画廊列表
  static Future<Tuple2<List<GalleryItem>, int>> getGallery({
    int page,
    String fromGid,
    String serach,
    int cats,
    bool refresh = false,
    SearchType searchType = SearchType.normal,
    dio.CancelToken cancelToken,
    String favcat,
  }) async {
    final EhConfigService _ehConfigService = Get.find();
    final bool safeMode = _ehConfigService.isSafeMode.value;
    final AdvanceSearchController _searchController = Get.find();

    final List<Cookie> cookies =
        await Global.cookieJar.loadForRequest(Uri.parse(Api.getBaseUrl()));

    // logger.d('${cookies.map((e) => e).join('\n')}');

    // logger.d('${searchType}');

    final String url = searchType == SearchType.watched ? '/watched' : '/';

    final Map<String, dynamic> params = <String, dynamic>{
      'page': page ?? 0,
      // 'inline_set': 'dm_l',
      if (safeMode) 'f_cats': 767,
      // 换版本的时候才加上高达限制
      // if (safeMode) 'f_search': 'parody:gundam\$',
      if (!safeMode && cats != null) 'f_cats': cats,
      if (fromGid != null) 'from': fromGid,
      if (serach != null) 'f_search': serach,
    };

    /// 高级搜索处理
    if (_searchController.enableAdvance ?? false) {
      params['advsearch'] = 1;
      params.addAll(_searchController.advanceSearchMap);
    }

    final dio.Options _cacheOptions = getCacheOptions(forceRefresh: refresh);

    // logger.v(url);

    await CustomHttpsProxy.instance.init();
    final String response =
        await getHttpManager().get(url, options: _cacheOptions, params: params);

    // 列表样式检查 不符合则重新设置
    final bool isDml = GalleryListParser.isGalleryListDmL(response);
    if (!isDml) {
      logger.i(' inline_set dml');
      params['inline_set'] = 'dm_l';
      final String response = await getHttpManager()
          .get(url, options: _cacheOptions, params: params);
      return await GalleryListParser.parseGalleryList(response,
          refresh: refresh);
    } else {
      return await GalleryListParser.parseGalleryList(response,
          refresh: refresh);
    }
  }

  /// 获取收藏
  /// inline_set 不能和页码同时使用 会默认定向到第一页
  static Future<Tuple2<List<GalleryItem>, int>> getFavorite({
    String favcat,
    int page,
    String fromGid,
    String serach,
    int cats,
    bool refresh = false,
    SearchType searchType = SearchType.normal,
    dio.CancelToken cancelToken,
  }) async {
    final AdvanceSearchController _searchController = Get.find();

    const String url = '/favorites.php';

    final Map<String, dynamic> params = <String, dynamic>{
      'page': page ?? 0,
      if (favcat != null && favcat != 'a' && favcat.isNotEmpty)
        'favcat': favcat,
      if (serach != null) 'f_search': serach,
    };

    if (serach != null) {
      params.addAll(_searchController.favSearchMap);
    }

    final dio.Options _cacheOptions = getCacheOptions(forceRefresh: refresh);

    // logger.d('${params}');
    await CustomHttpsProxy.instance.init();
    String response =
        await getHttpManager().get(url, options: _cacheOptions, params: params);

    // 排序方式检查 不符合则设置 然后重新请求
    // 获取收藏排序设置
    final FavoriteOrder order = EnumToString.fromString(FavoriteOrder.values,
            Global?.profile?.ehConfig?.favoritesOrder ?? '') ??
        FavoriteOrder.fav;
    // 排序参数
    final String _order = EHConst.favoriteOrder[order] ?? EHConst.FAV_ORDER_FAV;
    final bool isOrderFav = GalleryListParser.isFavoriteOrder(response);
    if (isOrderFav ^ (order == FavoriteOrder.fav)) {
      // 重设排序方式
      logger.d('重设排序方式为 $_order');
      params['inline_set'] = _order;
      params.removeWhere((key, value) => key == 'page');
      response = await getHttpManager().get(url,
          options: getCacheOptions(forceRefresh: true), params: params);
    }

    // 列表样式检查 不符合则重新设置
    final bool isDml = GalleryListParser.isGalleryListDmL(response);
    if (isDml) {
      return await GalleryListParser.parseGalleryList(
        response,
        isFavorite: true,
        refresh: refresh,
      );
    } else {
      logger.d('列表样式重设 inline_set=dm_l');
      params['inline_set'] = 'dm_l';
      params.removeWhere((key, value) => key == 'page');
      final String response = await getHttpManager().get(url,
          options: getCacheOptions(forceRefresh: true), params: params);
      return await GalleryListParser.parseGalleryList(
        response,
        isFavorite: true,
        refresh: true,
      );
    }
  }

  /// 获取画廊详细信息
  /// ?inline_set=ts_m 小图,40一页
  /// ?inline_set=ts_l 大图,20一页
  /// hc=1 显示全部评论
  /// nw=always 不显示警告
  static Future<GalleryItem> getGalleryDetail({
    String inUrl,
    GalleryItem inGalleryItem,
    bool refresh = false,
    dio.CancelToken cancelToken,
  }) async {
    /// 使用 inline_set 和 nw 参数会重定向，导致请求时间过长 默认不使用
    /// final String url = inUrl + '?hc=1&inline_set=ts_l&nw=always';
    final String url = inUrl + '?hc=1';

    // 不显示警告的处理 cookie加上 nw=1
    // 在 url使用 nw=always 未解决 自动写入cookie 暂时搞不懂 先手动设置下
    final PersistCookieJar cookieJar = await Api.cookieJar;
    final List<Cookie> cookies =
        await cookieJar.loadForRequest(Uri.parse(Api.getBaseUrl()));
    cookies.add(Cookie('nw', '1'));
    cookieJar.saveFromResponse(Uri.parse(Api.getBaseUrl()), cookies);

    // logger.i('获取画廊 $url');
    time.showTime('获取画廊');
    await CustomHttpsProxy.instance.init();
    time.showTime('设置代理');
    final String response = await getHttpManager()
        .get(url, options: getCacheOptions(forceRefresh: refresh));
    time.showTime('获取到响应');

    // todo 画廊警告问题 使用 nw=always 未解决 待处理 怀疑和Session有关
    if ('$response'.contains(r'<strong>Offensive For Everyone</strong>')) {
      logger.v('Offensive For Everyone');
      showToast('Offensive For Everyone');
    }

    // 解析画廊数据
    final GalleryItem galleryItem =
        await GalleryDetailParser.parseGalleryDetail(response,
            inGalleryItem: inGalleryItem);

    // logger.v(galleryItem.toJson());

    return galleryItem;
  }

  /// 获取画廊缩略图
  /// [inUrl] 画廊的地址
  /// [page] 缩略图页码
  static Future<List<GalleryPreview>> getGalleryPreview(
    String inUrl, {
    int page,
    bool refresh = false,
    dio.CancelToken cancelToken,
  }) async {
    //?inline_set=ts_m 小图,40一页
    //?inline_set=ts_l 大图,20一页
    //hc=1#comments 显示全部评论
    //nw=always 不显示警告

    // final HttpManager httpManager = HttpManager.getInstance();
    final String url = inUrl + '?p=$page';

    // logger.v(url);

    // 不显示警告的处理 cookie加上 nw=1
    // 在 url使用 nw=always 未解决 自动写入cookie 暂时搞不懂 先手动设置下
    // todo 待优化
    final PersistCookieJar cookieJar = await Api.cookieJar;
    final List<Cookie> cookies =
        await cookieJar.loadForRequest(Uri.parse(Api.getBaseUrl()));
    cookies.add(Cookie('nw', '1'));
    cookieJar.saveFromResponse(Uri.parse(Api.getBaseUrl()), cookies);

    await CustomHttpsProxy.instance.init();
    final String response = await getHttpManager().get(
      url,
      options: getCacheOptions(forceRefresh: refresh),
      cancelToken: cancelToken,
    );

    return GalleryDetailParser.parseGalleryPreviewFromHtml(response);
  }

  /// 由图片url获取解析图库 showkey
  /// [href] 画廊图片展示页面的地址
  static Future<String> getShowkey(
    String href, {
    bool refresh = false,
  }) async {
    final String url = href;

    await CustomHttpsProxy.instance.init();
    final String response = await getHttpManager()
        .get(url, options: getCacheOptions(forceRefresh: refresh));

    final RegExp regShowKey = RegExp(r'var showkey="([0-9a-z]+)";');

    final String showkey = regShowKey.firstMatch(response)?.group(1) ?? '';

//    logger.v('$showkey');

    return showkey;
  }

  // 获取TorrentToken
  static Future<String> getTorrentToken(
    String gid,
    String gtoken, {
    bool refresh = false,
  }) async {
    final String url = '${getBaseUrl()}/gallerytorrents.php';
    final String response = await getHttpManager().get(url,
        params: <String, dynamic>{
          'gid': gid,
          't': gtoken,
        },
        options: getCacheOptions(forceRefresh: refresh));
    // logger.d('$response');
    final RegExp rTorrentTk = RegExp(r'http://ehtracker.org/(\d{7})/announce');
    final String torrentToken = rTorrentTk.firstMatch(response)?.group(1) ?? '';
    return torrentToken;
  }

  // 获取 Torrent
  static Future<TorrentProvider> getTorrent(
    String url, {
    bool refresh = true,
  }) async {
    final String response = await getHttpManager()
        .get(url, options: getCacheOptions(forceRefresh: refresh));
    // logger.d('$response');

    return parseTorrent(response);
  }

  // 获取 Archiver
  static Future<ArchiverProvider> getArchiver(
    String url, {
    bool refresh = true,
  }) async {
    final String response = await getHttpManager()
        .get(url, options: getCacheOptions(forceRefresh: refresh));
    // logger.d('$response');

    return parseArchiver(response);
  }

  static Future<String> postArchiverRemoteDownload(
    String url,
    String resolution,
  ) async {
    final dio.Response response =
        await getHttpManager(cache: false).postForm(url,
            data: dio.FormData.fromMap({
              'hathdl_xres': resolution.trim(),
            }));
    return parseArchiverDownload(response.data);
  }

  static Future<String> postArchiverLocalDownload(
    String url, {
    String dltype,
    String dlcheck,
  }) async {
    final dio.Response response =
        await getHttpManager(cache: false).postForm(url,
            data: dio.FormData.fromMap({
              if (dltype != null) 'dltype': dltype.trim(),
              if (dlcheck != null) 'dlcheck': dlcheck.trim(),
            }));
    // logger.d('${response.data} ');
    final String _href = RegExp(r'document.location = "(.+)"')
        .firstMatch(response.data)
        .group(1);

    return '$_href?start=1';
  }

  /// 通过api请求获取更多信息
  /// 例如
  /// 画廊评分
  /// 日语标题
  /// 等等
  static Future<List<GalleryItem>> getMoreGalleryInfo(
    List<GalleryItem> galleryItems, {
    bool refresh = false,
  }) async {
    // logger.i('api qry items ${galleryItems.length}');
    if (galleryItems.isEmpty) {
      return galleryItems;
    }

    // 通过api获取画廊详细信息
    final List<List<String>> _gidlist = <List<String>>[];

    galleryItems.forEach((GalleryItem galleryItem) {
      _gidlist.add([galleryItem.gid, galleryItem.token]);
    });

    // 25个一组分割
    List _group = EHUtils.splitList(_gidlist, 25);

    List rultList = [];

    // 查询 合并结果
    for (int i = 0; i < _group.length; i++) {
      Map reqMap = {'gidlist': _group[i], 'method': 'gdata'};
      final String reqJsonStr = jsonEncode(reqMap);

      // logger.d(reqJsonStr);

      await CustomHttpsProxy.instance.init();
      final rult = await getGalleryApi(reqJsonStr, refresh: refresh);

      // logger.d('$rult');

      final jsonObj = jsonDecode(rult.toString());
      final tempList = jsonObj['gmetadata'];
      rultList.addAll(tempList);
    }

    final HtmlUnescape unescape = HtmlUnescape();

    for (int i = 0; i < galleryItems.length; i++) {
      // 标题
      galleryItems[i].englishTitle = unescape.convert(rultList[i]['title']);

      // 日语标题
      galleryItems[i].japaneseTitle =
          unescape.convert(rultList[i]['title_jpn']);

      // 详细评分
      final rating = rultList[i]['rating'];
      galleryItems[i].rating = rating != null
          ? double.parse(rating)
          : galleryItems[i].ratingFallBack;

      // 封面图片
      final String thumb = rultList[i]['thumb'];
      galleryItems[i].imgUrlL = thumb;

      // 文件数量
      galleryItems[i].filecount = rultList[i]['filecount'] as String;

      // 上传者
      galleryItems[i].uploader = rultList[i]['uploader'] as String;
      galleryItems[i].category = rultList[i]['category'] as String;

      // 标签
      final List<String> tags = List<String>.from(
          rultList[i]['tags'].map((e) => e as String).toList());
      galleryItems[i].tagsFromApi = tags;

      // 大小
      galleryItems[i].filesize = rultList[i]['filesize'] as int;

      // 种子数量
      galleryItems[i].torrentcount = rultList[i]['torrentcount'] as String;

      // 种子列表
      final List<dynamic> torrents = rultList[i]['torrents'];
      galleryItems[i].torrents = <GalleryTorrent>[];
      torrents.forEach((element) {
        // final Map<String, dynamic> e = element as Map<String, dynamic>;
        galleryItems[i].torrents.add(GalleryTorrent.fromJson(element));
      });

      /// 判断获取语言标识
      if (tags.isNotEmpty) {
        galleryItems[i].translated = EHUtils.getLangeage(tags[0]) ?? '';
      }
    }

    return galleryItems;
  }

  /// 画廊评分
  static Future<Map<String, dynamic>> setRating({
    @required String apikey,
    @required String apiuid,
    @required String gid,
    @required String token,
    @required int rating,
  }) async {
    final Map reqMap = {
      'apikey': apikey,
      'method': 'rategallery',
      'apiuid': int.parse(apiuid),
      'gid': int.parse(gid),
      'token': token,
      'rating': rating,
    };
    final String reqJsonStr = jsonEncode(reqMap);
    logger.d('$reqJsonStr');
    await CustomHttpsProxy.instance.init();
    final rult = await getGalleryApi(reqJsonStr, refresh: true, cache: false);
    logger.d('$rult');
    final Map<String, dynamic> rultMap = jsonDecode(rult.toString());
    return rultMap;
  }

  static Future<CommitVoteRes> commitVote({
    @required String apikey,
    @required String apiuid,
    @required String gid,
    @required String token,
    @required String commentId,
    @required int vote,
  }) async {
    final Map reqMap = {
      'method': 'votecomment',
      'apikey': apikey,
      'apiuid': int.parse(apiuid),
      'gid': int.parse(gid),
      'token': token,
      'comment_id': int.parse(commentId),
      'comment_vote': vote,
    };
    final String reqJsonStr = jsonEncode(reqMap);
    // logger.d('$reqJsonStr');
    await CustomHttpsProxy.instance.init();
    final rult = await getGalleryApi(reqJsonStr, refresh: true, cache: false);
    // logger.d('$rult');
    // final jsonObj = jsonDecode(rult.toString());
    return CommitVoteRes.fromJson(jsonDecode(rult.toString()));
  }

  /// 给画廊添加tag
  static Future<Map<String, dynamic>> tagGallery({
    @required String apikey,
    @required String apiuid,
    @required String gid,
    @required String token,
    String tags,
    int vote = 1,
  }) async {
    final Map reqMap = {
      'apikey': apikey,
      'method': 'taggallery',
      'apiuid': int.parse(apiuid),
      'gid': int.parse(gid),
      'token': token,
      'tags': tags,
      'vote': vote,
    };
    final String reqJsonStr = jsonEncode(reqMap);
    logger.d('$reqJsonStr');
    await CustomHttpsProxy.instance.init();
    final rult = await getGalleryApi(reqJsonStr, refresh: true, cache: false);
    logger.d('$rult');
    final Map<String, dynamic> rultMap = jsonDecode(rult.toString());
    return rultMap;
  }

  /// 发布评论
  static Future<bool> postComment({
    String gid,
    String token,
    String comment,
    String commentId,
    bool isEdit = false,
    GalleryItem inGalleryItem,
  }) async {
    final String url = '${getBaseUrl()}/g/$gid/$token';
    if (utf8.encode(comment).length < 10) {
      showToast('Your comment is too short.');
      throw EhError(
          type: EhErrorType.DEFAULT, error: 'Your comment is too short.');
    }

    try {
      final dio.Response response = await getHttpManager(cache: false).postForm(
        url,
        data: dio.FormData.fromMap({
          isEdit ? 'commenttext_edit' : 'commenttext_new': comment,
          if (isEdit) 'edit_comment': int.parse(commentId),
        }),
        options: dio.Options(
            followRedirects: false,
            validateStatus: (int status) {
              return status < 500;
            }),
      );

      logger.d('${response.statusCode}');
      return response.statusCode == 302;
    } catch (e, stack) {
      logger.e('$e\n$stack');
      rethrow;
    }
  }

  static Future<void> getMoreGalleryInfoOne(
    GalleryItem galleryItem, {
    bool refresh = false,
  }) async {
    final RegExp urlRex =
        RegExp(r'(http?s://e(-|x)hentai.org)?/g/(\d+)/(\w+)/?$');
    // logger.v(galleryItem.url);
    final RegExpMatch urlRult = urlRex.firstMatch(galleryItem.url);
    // logger.v(urlRult.groupCount);

    final String gid = urlRult.group(3);
    final String token = urlRult.group(4);

    galleryItem.gid = gid;
    galleryItem.token = token;

    final List<GalleryItem> reqGalleryItems = <GalleryItem>[galleryItem];

    await getMoreGalleryInfo(reqGalleryItems, refresh: refresh);
  }

  /// 获取api
  static Future getGalleryApi(
    String req, {
    bool refresh = false,
    bool cache = true,
  }) async {
    const String url = '/api.php';

    await CustomHttpsProxy.instance.init();
    final response = await getHttpManager(
      cache: cache,
      // baseUrl: EHConst.getBaseSite(),
    ).postForm(
      url,
      data: req,
      options: getCacheOptions(forceRefresh: refresh),
    );

    return response;
  }

  /// 分享图片
  static Future<void> shareImage(String imageUrl) async {
    final CachedNetworkImage image =
        CachedNetworkImage(imageUrl: imageUrl ?? '');
    final DefaultCacheManager manager =
        image.cacheManager ?? DefaultCacheManager();
    final Map<String, String> headers = image.httpHeaders;
    final File file = await manager.getSingleFile(
      image.imageUrl,
      headers: headers,
    );
    Share.shareFiles(<String>[file.path]);
  }

  static Future<void> shareImageExtended(String imageUrl) async {
    final File file = await getCachedImageFile(imageUrl);
    final String _name = imageUrl.substring(imageUrl.lastIndexOf('/') + 1);
    logger.v('_name $_name url $imageUrl');
    final File newFile = file.copySync(path.join(Global.tempPath, _name));
    Share.shareFiles(<String>[newFile.path], text: 'save image');
  }

  /// 保存图片到相册
  /// 默认为下载网络图片，如需下载资源图片，需要指定 [isAsset] 为 `true`。
  static Future<bool> saveImage(BuildContext context, String imageUrl,
      {bool isAsset = false}) async {
    /// 跳转权限设置
    Future<void> _jumpToAppSettings(context) async {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Container(
              child: const Text(
                  'You have disabled the necessary permissions for the application:'
                  '\nRead and write phone storage, is it allowed in the settings?'),
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
                  // 跳转
                  openAppSettings();
                },
              ),
            ],
          );
        },
      );
    }

    if (Platform.isIOS) {
      logger.v('check ios photos Permission');
      final PermissionStatus statusPhotos = await Permission.photos.status;
      final PermissionStatus statusPhotosAdd =
          await Permission.photosAddOnly.status;

      logger.d('statusPhotos $statusPhotos , photosAddOnly $statusPhotosAdd');

      if (statusPhotos.isPermanentlyDenied &&
          statusPhotosAdd.isPermanentlyDenied) {
        _jumpToAppSettings(context);
        return false;
      } else {
        final requestAddOnly = await Permission.photosAddOnly.request();
        final requestAll = await Permission.photos.request();

        if (requestAddOnly.isGranted ||
            requestAddOnly.isLimited ||
            requestAll.isGranted ||
            requestAll.isLimited) {
          // return _saveImage(imageUrl);
          return _saveImageExtended(imageUrl);
          // Either the permission was already granted before or the user just granted it.
        } else {
          throw 'Unable to save pictures, please authorize first~';
        }
      }
    } else {
      final PermissionStatus status = await Permission.storage.status;
      logger.v(status);
      if (await Permission.storage.status.isPermanentlyDenied) {
        if (await Permission.storage.request().isGranted) {
          // _saveImage(imageUrl);
          return _saveImageExtended(imageUrl);
        } else {
          await _jumpToAppSettings(context);
          return false;
        }
      } else {
        if (await Permission.storage.request().isGranted) {
          // Either the permission was already granted before or the user just granted it.
          // return _saveImage(imageUrl);
          return _saveImageExtended(imageUrl);
        } else {
          throw 'Unable to save pictures, please authorize first~';
        }
      }
    }
    return false;
  }

  static Future<bool> _saveImage(String imageUrl,
      {bool isAsset = false}) async {
    try {
      if (imageUrl == null) {
        throw 'Save failed, picture does not exist!';
      }

      /// 保存的图片数据
      Uint8List imageBytes;

      if (isAsset == true) {
        /// 保存资源图片
        final ByteData bytes = await rootBundle.load(imageUrl);
        imageBytes = bytes.buffer.asUint8List();
      } else {
        /// 保存网络图片
        logger.d('保存网络图片');
        final CachedNetworkImage image =
            CachedNetworkImage(imageUrl: imageUrl ?? '');
        final DefaultCacheManager manager =
            image.cacheManager ?? DefaultCacheManager();
        final Map<String, String> headers = image.httpHeaders;
        final File file = await manager.getSingleFile(
          image.imageUrl,
          headers: headers,
        );
        imageBytes = await file.readAsBytes();
      }

      /// 保存图片
      final result = await ImageGallerySaver.saveImage(imageBytes);

      if (result == null || result == '') {
        throw 'Save image fail';
      }

      logger.i('保存成功');
      return true;
    } catch (e) {
      logger.e(e.toString());
      rethrow;
    }
  }

  static Future<bool> _saveImageExtended(String imageUrl,
      {bool isAsset = false}) async {
    try {
      if (imageUrl == null) {
        throw 'Save failed, picture does not exist!';
      }

      /// 保存的图片数据
      Uint8List imageBytes;
      File file;

      if (isAsset == true) {
        /// 保存资源图片
        final ByteData bytes = await rootBundle.load(imageUrl);
        imageBytes = bytes.buffer.asUint8List();
      } else {
        /// 保存网络图片
        logger.d('保存网络图片');
        file = await getCachedImageFile(imageUrl);

        logger.v('file path ${file.path}');

        imageBytes = await file.readAsBytes();
      }

      /// 保存图片
      // final result = await ImageGallerySaver.saveImage(
      //   imageBytes,
      //   quality: 100,
      //   name: _name,
      // );

      final _name = imageUrl.substring(imageUrl.lastIndexOf('/') + 1);
      logger.v('_name $_name url $imageUrl');
      final File newFile = file.copySync(path.join(Global.tempPath, _name));
      logger.v('${newFile.path} ${file.lengthSync()} ${newFile.lengthSync()}');

      final result = await ImageGallerySaver.saveFile(newFile.path);

      if (result == null || result == '') {
        throw 'Save image fail';
      }

      logger.i('保存成功');
      return true;
    } catch (e, stack) {
      logger.e('$e\n$stack');
      rethrow;
    }
  }

  /// 由api获取画廊图片的信息
  /// [href] 爬取的页面地址 用来解析gid 和 imgkey
  /// [showKey] api必须
  /// [index] 索引 从 1 开始
  static Future<GalleryPreview> paraImageLageInfoFromApi(
    String href,
    String showKey, {
    int index,
  }) async {
    const String url = '/api.php';

    final String cookie = Global.profile?.user?.cookie ?? '';

    final dio.Options options = dio.Options(headers: {
      'Cookie': cookie,
    });

//    logger.v('href = $href');

    final RegExp regExp =
        RegExp(r'https://e[-x]hentai.org/s/([0-9a-z]+)/(\d+)-(\d+)');
    final RegExpMatch regRult = regExp.firstMatch(href);
    final int gid = int.parse(regRult.group(2));
    final String imgkey = regRult.group(1);
    final int page = int.parse(regRult.group(3));

    final Map<String, Object> reqMap = {
      'method': 'showpage',
      'gid': gid,
      'page': page,
      'imgkey': imgkey,
      'showkey': showKey,
    };
    final String reqJsonStr = jsonEncode(reqMap);

    // logger.d('$reqJsonStr');

    final dio.Options _cacheOptinos = buildCacheOptions(
      const Duration(days: 1),
      maxStale: const Duration(minutes: 1),
      options: options,
      subKey: reqJsonStr,
    );

    await CustomHttpsProxy.instance.init();
    final dio.Response<dynamic> response = await Api.getHttpManager().postForm(
      url,
      options: _cacheOptinos,
      data: reqJsonStr,
    );

    // logger.d('$response');

    final dynamic rultJson = jsonDecode('$response');

    final RegExp regImageUrl = RegExp('<img[^>]*src=\"([^\"]+)\" style');
    final String imageUrl = regImageUrl.firstMatch(rultJson['i3']).group(1);
    final double width = double.parse(rultJson['x'].toString());
    final double height = double.parse(rultJson['y'].toString());

//    logger.v('$imageUrl');

    final GalleryPreview _rePreview = GalleryPreview()
      ..largeImageUrl = imageUrl
      ..ser = index + 1
      ..largeImageWidth = width
      ..largeImageHeight = height;
    // logger.v('${_rePreview.toJson()}');

    return _rePreview;
  }

  /// 获取画廊图片的信息
  /// [href] 爬取的页面地址 用来解析gid 和 imgkey
  /// [ser] 序号
  static Future<GalleryPreview> ftchImageInfo(
    String href, {
    int ser,
    bool refresh,
    String sourceId,
  }) async {
    final String url = href;

    // logger.d('$reqJsonStr');

    final dio.Options _cacheOptinos = buildCacheOptions(
      const Duration(days: 1),
      maxStale: const Duration(minutes: 1),
    );

    final Map<String, dynamic> _params = {
      if (sourceId != null && sourceId.trim().isNotEmpty) 'nl': sourceId,
    };

    await CustomHttpsProxy.instance.init();
    final String response = await Api.getHttpManager(connectTimeout: 5000).get(
      url,
      options: getCacheOptions(
        forceRefresh: refresh,
        options: dio.Options(receiveTimeout: 8000),
      ),
      params: _params,
    );

    // logger.d('$response ');

    return paraImage(response)..ser = ser;
  }

  static Future<void> download(String url, String path) async {
    await CustomHttpsProxy.instance.init();
    Api.getHttpManager().downLoadFile(url, path);
  }
}
