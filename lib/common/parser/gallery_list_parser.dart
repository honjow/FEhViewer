import 'dart:io';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/error.dart';
import 'package:fehviewer/store/tag_database.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

class GalleryListParser {
  /// 检查返回结果是否是l视图
  static bool isGalleryListDmL(String response) {
    final dom.Document document = parse(response);
    final List<dom.Element> domList =
        document.querySelectorAll('#dms > div > select > option');

    for (final dom.Element elm in domList) {
      // logger.v('${elm.attributes["value"]} —— ${elm.attributes.keys}');
      final Map<dynamic, String> attributes = elm.attributes;
      if (attributes.keys.contains('selected')) {
        return attributes['value'] == 'l';
      } else {
        continue;
      }
    }
    return true;
  }

  ///  收藏夹 检查返回结果的排序方式
  static bool isFavoriteOrder(String response) {
    final dom.Document document = parse(response);

    final List<dom.Element> domList =
        document.querySelectorAll('body > div.ido > div');

    if (domList.length > 2) {
      final dom.Element orderElm = domList[2].querySelector('div > span');
      // logger.d('${orderElm.text}');
      return orderElm.text?.trim() == 'Favorited';
    }

    return false;
  }

  /// 列表数据处理
  static Future<Tuple2<List<GalleryItem>, int>> parseGalleryList(
    String response, {
    bool isFavorite = false,
    bool refresh = false,
  }) async {
    final dom.Document document = parse(response);

    // logger.v('${document.body.children.length}');
    if (document.body.children.isEmpty && response.contains('banned')) {
      logger.e('banned');
      showToast('$response');
      throw EhError(type: EhErrorType.BANNED, error: response);
    }

    final EhConfigService ehConfigService = Get.find();

    const String _gallerySelector =
        'body > div.ido > div:nth-child(2) > table > tbody > tr';
    const String _favSelector =
        'body > div.ido > form > table.itg.gltc > tbody > tr';

    final String _listSelector = isFavorite ? _favSelector : _gallerySelector;

    const String _galleryPageSelector =
        'body > div.ido > div:nth-child(2) > table.ptt > tbody > tr > td';
    const String _favPageSelector =
        'body > div.ido > form > table.ptt > tbody > tr > td';
    final String _pageSelector =
        isFavorite ? _favPageSelector : _galleryPageSelector;

    const _favoritesSelector = 'body > div.ido > div.nosel > div';

    if (isFavorite) {
      /// 收藏夹列表
      final List<dom.Element> favorites =
          document.querySelectorAll(_favoritesSelector);
      int _favId = 0;
      final List<Map<String, String>> favcatList = <Map<String, String>>[];
      for (final dom.Element elm in favorites) {
        final List<dom.Element> divs = elm.querySelectorAll('div');
        // logger.v('${divs}');
        if (divs.isNotEmpty && divs.length >= 3) {
          final Map<String, String> map = <String, String>{
            'favId': '$_favId',
            'favTitle': divs[2].text ?? ''
          };
          favcatList.add(map);
          _favId += 1;
        }
      }
      if (favcatList.isNotEmpty) {
        Global.profile.user.favcat = favcatList;
        Global.saveProfile();
        // logger.v('$favcatList');
      }
    }

    // 最大页数
    int _maxPage = 0;
    List<dom.Element> _pages = document.querySelectorAll(_pageSelector);
    if (_pages.length > 2) {
      final dom.Element _maxPageElem = _pages[_pages.length - 2];
      _maxPage = int.parse(_maxPageElem.text.trim());
//      logger.v('_maxPage $_maxPage');
    }

    // 画廊列表
    List<dom.Element> gallerys = document.querySelectorAll(_listSelector);
//    logger.v('gallerys ${gallerys.length}');

    final List<GalleryItem> _gallaryItems = [];
    for (final dom.Element tr in gallerys) {
      final String category =
          tr.querySelector('td.gl1c.glcat > div')?.text?.trim();

      // 表头或者广告
      if (category == null || category.isEmpty) {
        continue;
      }

      final String title =
          tr.querySelector('td.gl3c.glname > a > div.glink')?.text?.trim();

      final String url =
          tr.querySelector('td.gl3c.glname > a')?.attributes['href'] ?? '';
      final String _path = Uri.parse(url).path;
      // logger.d('url $url   path $_path');

      final RegExp urlRex = RegExp(r'/g/(\d+)/(\w+)/$');
      final RegExpMatch urlRult = urlRex.firstMatch(url);

      final String gid = urlRult.group(1);
      final String token = urlRult.group(2);

      // tags
      final List<dom.Element> tags = tr.querySelectorAll('div.gt');

      // tag
      final List<SimpleTag> simpleTags = <SimpleTag>[];
      final RegExp colorRex = RegExp(r'#(\w{6})');
      for (final dom.Element tag in tags) {
        final String tagText = tag.text.trim();
        final String translate =
            await EhTagDatabase.getTranTag(tagText) ?? tagText;

        final String style = tag.attributes['style'];
        String color = '';
        String backgroundColor = '';
        if (style != null) {
          final Iterable<RegExpMatch> matches = colorRex.allMatches(style);
          color = matches.elementAt(0)[0];
          backgroundColor = matches.elementAt(3)[0];
          // Global.logger
          //     .d('$translate ${matches.length} $color  $backgroundColor');
        }
        simpleTags.add(SimpleTag()
          ..text = tagText
          ..translat = translate
          ..color = color
          ..backgrondColor = backgroundColor);
      }

      /// 判断获取语言标识
      String _translated = '';
      try {
        if (simpleTags.isNotEmpty) {
          // logger.d('${simpleTags.map((e) => e.text).join(',')}');
          final _langTag = simpleTags.firstWhere(
              (element) => EHConst.iso936.keys.contains(element.text),
              orElse: () => null);

          _translated = EHUtils.getLangeage(_langTag?.text ?? '') ?? '';
        }
      } catch (e, stack) {
        logger.d('$e\n$stack');
      }

      // 封面图片
      final dom.Element img = tr.querySelector('td.gl2c > div > div > img');
      final String imgDataSrc = img.attributes['data-src'];
      final String imgSrc = img.attributes['src'];
      final String imgUrl = imgDataSrc ?? imgSrc ?? '';

      // 图片宽高
      final String imageStyle = img.attributes['style'];
      final RegExpMatch match =
          RegExp(r'height:(\d+)px;width:(\d+)px').firstMatch(imageStyle);
      final double imageHeight = double.parse(match[1]);
      final double imageWidth = double.parse(match[2]);

      // 评分星级计算
      final String ratPx = tr
          .querySelector('td.gl2c > div:nth-child(2) > div.ir')
          .attributes['style'];
      final RegExp pxA = RegExp(r'-?(\d+)px\s+-?(\d+)px');
      final RegExpMatch px = pxA.firstMatch(ratPx);

      final double ratingFB = (80.0 - double.parse(px.group(1))) / 16.0 -
          (px.group(2) == '21' ? 0.5 : 0.0);

      // logger.i('ratingFB $ratingFB');

      final String postTime =
          tr.querySelector('td.gl2c > div:nth-child(2) > div')?.text?.trim() ??
              '';
      final DateTime time =
          DateFormat('yyyy-MM-dd HH:mm').parseUtc(postTime).toLocal();

      final String postTimeLocal = DateFormat('yyyy-MM-dd HH:mm').format(time);

      // 收藏标志
      final String favTitle = tr
              .querySelector('td.gl2c > div:nth-child(2) > div')
              ?.attributes['title'] ??
          '';

      // 评分颜色
      final String _colorRating = tr
              .querySelector('td.gl2c')
              .children[2]
              .children[1]
              ?.attributes['class'] ??
          'ir';

      // 评分标志
      final String ir = tr
              .querySelector('td.gl2c > div:nth-child(2) > div:nth-child(1)')
              ?.attributes['class'] ??
          '';
      final bool isRatinged = ir.contains(RegExp(r'ir ir[a-z]'));

      // 收藏夹
      String favcat = '';
      if (favTitle.isNotEmpty) {
        final String favcatStyle = tr
            .querySelector('td.gl2c > div:nth-child(2) > div')
            ?.attributes['style'];
        final String favcatColor = RegExp(r'border-color:(#\w{3});')
                ?.firstMatch(favcatStyle)
                ?.group(1) ??
            '';
        favcat = EHConst.favCat[favcatColor] ?? '';
      }

      String _uplader = '';
      String _filecount = '';
      if (!isFavorite) {
        final dom.Element elmGl4c = tr.children[3];
        // 上传者
        _uplader = elmGl4c.children[0].text;

        // 文件数量
        _filecount =
            RegExp(r'\d+').firstMatch(elmGl4c.children[1].text).group(0);
      } else {
        final dom.Element elmGl2c = tr.children[1];
        _filecount = RegExp(r'\d+')
            .firstMatch(
                elmGl2c.children[1].children[1].children[1].children[1].text)
            .group(0);
      }

      void _addIiem() {
        _gallaryItems.add(GalleryItem()
          ..gid = gid
          ..token = token
          ..englishTitle = title
          ..imgUrl = imgUrl ?? ''
          ..imgHeight = imageHeight
          ..imgWidth = imageWidth
          ..url = _path
          ..category = category
          ..simpleTags = simpleTags
          ..postTime = postTimeLocal
          ..ratingFallBack = ratingFB
          ..colorRating = _colorRating
          ..isRatinged = isRatinged
          ..favTitle = favTitle
          ..favcat = favcat
          ..uploader = _uplader
          ..filecount = _filecount
          ..translated = _translated);
      }

      // safeMode检查
      if (Platform.isIOS && ehConfigService.isSafeMode.value) {
        if (category.trim() == 'Non-H') {
          _addIiem();
        }
      } else {
        _addIiem();
      }
    }

    // 通过api请求获取更多信息
    if (_gallaryItems.isNotEmpty) {
      // await Api.getMoreGalleryInfo(_gallaryItems, refresh: refresh);
    }

    return Tuple2(_gallaryItems, _maxPage);
  }
}
