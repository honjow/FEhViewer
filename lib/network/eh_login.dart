import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/user.dart';
import 'package:fehviewer/network/error.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/dio_util.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

class EhUserManager {
  factory EhUserManager() => _instance;

  EhUserManager._();

  static final EhUserManager _instance = EhUserManager._();

  Future<User> signIn(String username, String passwd) async {
    final HttpManager httpManager = HttpManager.getInstance(
        baseUrl: 'https://forums.e-hentai.org', cache: false);
    const String url = '/index.php?act=Login&CODE=01';
    const String referer =
        'https://forums.e-hentai.org/index.php?act=Login&CODE=00';
    const String origin = 'https://forums.e-hentai.org';

    final FormData formData = FormData.fromMap({
      'UserName': username,
      'PassWord': passwd,
      'submit': 'Log me in',
      'temporary_https': 'off',
      'CookieDate': '1',
    });

    final Options options =
        Options(headers: {'Referer': referer, 'Origin': origin});

    Response rult;
    try {
      rult = await httpManager.postForm(url, data: formData, options: options);
    } catch (e) {
      logger.v('$e');
    }

    //  登录异常处理
    final List<String> setcookie = rult.headers['set-cookie'];

    logger.d('set-cookie $setcookie');

    if (setcookie.length < 2) {
      throw EhError(type: EhErrorType.LOGIN);
    }

    final String cookieMemberId = setcookie.firstWhere(
        (String cookieValue) => cookieValue.contains('ipb_member_id'));
    final String cookiePassHash = setcookie.firstWhere(
        (String cookieValue) => cookieValue.contains('ipb_pass_hash'));
    loggerNoStack.d('$cookieMemberId\n$cookiePassHash');
    setcookie.add(cookieMemberId.replaceFirst('e-hentai.org', 'exhentai.org'));
    setcookie.add(cookiePassHash.replaceFirst('e-hentai.org', 'exhentai.org'));

    final List<Cookie> _cookies = setcookie.map((String cookieStr) {
      return Cookie.fromSetCookieValue(cookieStr);
    }).toList();

    loggerNoStack.d('$_cookies');

    final String _id = _cookies
        .firstWhere((Cookie cookie) => cookie.name == 'ipb_member_id')
        .value;
    if (_id == null || _id.isEmpty) {
      throw EhError(type: EhErrorType.LOGIN);
    }

    final PersistCookieJar cookieJar = await Api.cookieJar;

    // 设置EX的cookie
    cookieJar.saveFromResponse(Uri.parse(EHConst.EX_BASE_URL), _cookies);

    await _getExIgneous();

    //获取Ex cookies
    final List<Cookie> cookiesEx =
        await cookieJar.loadForRequest(Uri.parse(EHConst.EX_BASE_URL));

    logger.v('$cookiesEx');

    // 处理cookie 存入sp 方便里站图片请求时构建头 否则会403
    final Map<String, String> cookieMapEx = <String, String>{};
    cookiesEx.forEach((Cookie cookie) {
      cookieMapEx.putIfAbsent(cookie.name, () => cookie.value);
    });

    final Map<String, String> cookie = <String, String>{
      'ipb_member_id': cookieMapEx['ipb_member_id'],
      'ipb_pass_hash': cookieMapEx['ipb_pass_hash'],
      'igneous': cookieMapEx['igneous'],
    };

    String nickame = username.replaceFirstMapped(
        RegExp('(^.)'), (Match match) => match[1].toUpperCase());

    String _avatarUrl = '';
    try {
      final User userinfo = await _getUserInfo(cookie['ipb_member_id']);
      nickame = userinfo.username;
      _avatarUrl = userinfo.avatarUrl;
    } catch (_) {}

    final String cookieStr = _getCookieStringFromMap(cookie);
    logger.v(cookieStr);

    final User user = User()
      ..cookie = cookieStr
      ..avatarUrl = _avatarUrl
      ..username = nickame;

    return user;
  }

  /// 通过网页登录的处理
  /// 处理cookie
  /// 以及获取名字等
  Future<User> signInByWeb(Map cookieMap) async {
    // key value去空格
    cookieMap = cookieMap.map((key, value) {
      return MapEntry(key.toString().trim(), value.toString().trim());
    });

    final List<Cookie> cookies = [
      Cookie('ipb_member_id', cookieMap['ipb_member_id']),
      Cookie('ipb_pass_hash', cookieMap['ipb_pass_hash']),
      Cookie('nw', '1'),
    ];

    final PersistCookieJar cookieJar = await Api.cookieJar;

    // 设置EH的cookie
    cookieJar.saveFromResponse(Uri.parse(EHConst.EH_BASE_URL), cookies);

    // 设置EX的cookie
    cookieJar.saveFromResponse(Uri.parse(EHConst.EX_BASE_URL), cookies);
    await _getExIgneous();

    final User userinfo = await _getUserInfo(cookieMap['ipb_member_id']);

    //获取Ex cookies
    final List<Cookie> cookiesEx =
        await cookieJar.loadForRequest(Uri.parse(EHConst.EX_BASE_URL));
    // 处理cookie 存入sp 方便里站图片请求时构建头 否则会403
    final Map<String, String> cookieMapEx = <String, String>{};

    for (final Cookie cookie in cookiesEx) {
      cookieMapEx.putIfAbsent(cookie.name, () => cookie.value);
    }

    final Map<String, String> cookie = {
      'ipb_member_id': cookieMapEx['ipb_member_id'],
      'ipb_pass_hash': cookieMapEx['ipb_pass_hash'],
      'igneous': cookieMapEx['igneous'],
    };

    final String cookieStr = _getCookieStringFromMap(cookie);
    logger.v(cookieStr);

    final User user = User()
      ..cookie = cookieStr
      ..avatarUrl = userinfo.avatarUrl
      ..username = userinfo.username;

    return user;
  }

  /// 通过Cookie登录
  /// 以及获取用户名
  Future<User> signInByCookie(
    String id,
    String hash, {
    String igneous,
  }) async {
    final List<Cookie> cookies = <Cookie>[
      Cookie('ipb_member_id', id),
      Cookie('ipb_pass_hash', hash),
      Cookie('nw', '1'),
    ];

    final PersistCookieJar cookieJar = await Api.cookieJar;

    // 设置EH的cookie
    cookieJar.saveFromResponse(Uri.parse(EHConst.EH_BASE_URL), cookies);

    // 设置EX的cookie
    cookieJar.saveFromResponse(Uri.parse(EHConst.EX_BASE_URL), cookies);
    await _getExIgneous();

    final User userinfo = await _getUserInfo(id);

    //获取Ex cookies
    final List<Cookie> cookiesEx =
        await cookieJar.loadForRequest(Uri.parse(EHConst.EX_BASE_URL));

    // 手动指定igneous的情况
    cookiesEx.firstWhere((element) => element.name == 'igneous').value =
        igneous;

    // 处理cookie 存入sp 方便里站图片请求时构建头 否则会403
    final Map<String, String> cookieMapEx = <String, String>{};

    for (final Cookie cookie in cookiesEx) {
      cookieMapEx.putIfAbsent(cookie.name, () => cookie.value);
    }

    final Map<String, String> cookie = {
      'ipb_member_id': cookieMapEx['ipb_member_id'],
      'ipb_pass_hash': cookieMapEx['ipb_pass_hash'],
      'igneous': igneous.isNotEmpty ? igneous : cookieMapEx['igneous'],
    };

    final String cookieStr = _getCookieStringFromMap(cookie);
    logger.v(cookieStr);

    final User user = User()
      ..cookie = cookieStr
      ..avatarUrl = userinfo.avatarUrl
      ..username = userinfo.username;

    return user;
  }

  /// 获取用户信息等
  Future<User> _getUserInfo(String id) async {
    final HttpManager httpManager = HttpManager.getInstance(
        baseUrl: 'https://forums.e-hentai.org', cache: false);
    final String url = '/index.php?showuser=$id';

    final String response = await httpManager.get(url);

    // logger.v('$response');

    // final RegExp regExp = RegExp(r'Viewing Profile: (.+?)</div');
    // final String username = regExp.firstMatch('$response').group(1);

    final Document document = parse(response);

    final Element profilenameElm = document.querySelector('#profilename');
    final String username = profilenameElm.text;

    final Element avatarElm =
        profilenameElm.nextElementSibling.nextElementSibling;

    String _avatarUrl = '';
    if (avatarElm.children.isNotEmpty) {
      final Element imageElm = avatarElm.children.first;
      _avatarUrl = imageElm.attributes['src'];
      if (!_avatarUrl.startsWith('http')) {
        _avatarUrl = 'https://forums.e-hentai.org/$_avatarUrl';
      }
    }

    logger.v('username $username   ${avatarElm.outerHtml}');

    return User()
      ..username = username
      ..avatarUrl = _avatarUrl;
  }

  /// 获取里站cookie
  Future<void> _getExIgneous() async {
    final HttpManager httpManager =
        HttpManager.getInstance(baseUrl: EHConst.EX_BASE_URL, cache: false);
    const String url = '/uconfig.php';

    final Response<dynamic> response = await httpManager.getAll(url);
    // logger.d('${response}');
    return response;
  }

  static String _getCookieStringFromMap(Map cookie) {
    final List texts = [];
    cookie.forEach((key, value) {
      texts.add('$key=$value');
    });
    return texts.join('; ');
  }
}
