import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/base_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/const/storages.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EhConfigService extends ProfileService {
  RxBool isJpnTitle = false.obs;
  RxBool isTagTranslat = false.obs;
  RxBool isGalleryImgBlur = false.obs;
  RxBool isSiteEx = false.obs;
  RxBool isFavLongTap = false.obs;
  RxInt catFilter = 0.obs;
  Rx<ListModeEnum> listMode = ListModeEnum.list.obs;
  RxInt maxHistory = 100.obs;
  RxBool isSearchBarComp = true.obs;
  Rx<FavoriteOrder> favoriteOrder = FavoriteOrder.fav.obs;
  RxBool isSafeMode = false.obs;
  RxString tagTranslatVer = ''.obs;
  RxString lastFavcat = '0'.obs;
  RxBool isFavPicker = false.obs;
  RxBool isPureDarkTheme = false.obs;
  RxBool isClipboardLink = false.obs;
  RxBool commentTrans = false.obs;
  RxBool blurredInRecentTasks = true.obs;

  String _lastClipboardLink = '';

  String get lastShowFavcat => ehConfig.lastShowFavcat;

  set lastShowFavcat(String value) {
    ehConfig.lastShowFavcat = value;
    Global.saveProfile();
  }

  String get lastShowFavTitle => ehConfig.lastShowFavTitle;

  set lastShowFavTitle(String value) {
    ehConfig.lastShowFavTitle = value;
    Global.saveProfile();
  }

  /// 预载图片数量
  RxInt preloadImage = 5.obs;

  /// 阅读相关设置
  /// 阅读方向
  Rx<ViewMode> viewMode = ViewMode.LeftToRight.obs;

  /// 自动锁定时间
  RxInt autoLockTimeOut = (-1).obs;

  /// 屏幕方向
  Rx<ReadOrientation> orientation = ReadOrientation.system.obs;

  /// 显示页面间隔
  RxBool showPageInterval = true.obs;

  @override
  void onInit() {
    super.onInit();

    ehConfig = Global.profile.ehConfig;
    downloadConfig = Global.profile.downloadConfig;

    /// 预载图片数量
    preloadImage.value = downloadConfig.preloadImage ?? 5;
    everProfile(preloadImage, (value) => downloadConfig.preloadImage = value);

    /// 阅读方向
    viewMode.value =
        EnumToString.fromString(ViewMode.values, ehConfig?.viewModel ?? '') ??
            ViewMode.LeftToRight;
    everFromEunm(viewMode, (String value) => ehConfig.viewModel = value);

    //
    isSafeMode.value = ehConfig.safeMode ?? true;
    everProfile(isSafeMode, (value) {
      ehConfig.safeMode = value;
      Get.find<TabHomeController>().resetIndex();
    });

    isJpnTitle.value = ehConfig?.jpnTitle ?? false;
    everProfile(isJpnTitle, (value) => ehConfig.jpnTitle = value);

    isTagTranslat.value = ehConfig?.tagTranslat ?? false;
    everProfile(isTagTranslat, (value) => ehConfig.tagTranslat = value);

    isGalleryImgBlur.value = ehConfig?.galleryImgBlur ?? false;
    everProfile(isGalleryImgBlur, (value) => ehConfig.galleryImgBlur = value);

    isSiteEx.value = ehConfig?.siteEx ?? false;
    everProfile(isSiteEx, (value) => ehConfig.siteEx = value);

    isFavLongTap.value = ehConfig?.favLongTap ?? false;
    everProfile(isFavLongTap, (value) => ehConfig.favLongTap = value);

    catFilter.value = ehConfig.catFilter ?? 0;
    everProfile(catFilter, (value) => ehConfig.catFilter = value);

    listMode.value = EnumToString.fromString(
            ListModeEnum.values, ehConfig?.listMode ?? '') ??
        ListModeEnum.list;
    everFromEunm(listMode, (String value) => ehConfig.listMode = value);

    maxHistory.value = ehConfig.maxHistory ?? 100;
    everProfile(maxHistory, (value) => ehConfig.maxHistory = value);

    isSearchBarComp.value = ehConfig.searchBarComp ?? true;
    everProfile(isSearchBarComp, (value) => ehConfig.searchBarComp = value);

    favoriteOrder.value = EnumToString.fromString(
            FavoriteOrder.values, ehConfig?.favoritesOrder ?? '') ??
        FavoriteOrder.fav;
    everFromEunm(
        favoriteOrder, (String value) => ehConfig.favoritesOrder = value);

    tagTranslatVer.value = ehConfig.tagTranslatVer ?? '';
    everProfile(tagTranslatVer, (value) => ehConfig.tagTranslatVer = value);

    lastFavcat.value = ehConfig.lastFavcat ?? '0';
    everProfile(lastFavcat, (value) => ehConfig.lastFavcat);

    isFavPicker.value = ehConfig.favPicker ?? false;
    everProfile(isFavPicker, (value) => ehConfig.favPicker);

    isPureDarkTheme.value = ehConfig.pureDarkTheme ?? false;
    everProfile<bool>(
        isPureDarkTheme, (bool value) => ehConfig.pureDarkTheme = value);

    isClipboardLink.value = ehConfig.clipboardLink ?? false;
    everProfile<bool>(
        isClipboardLink, (bool value) => ehConfig.clipboardLink = value);

    commentTrans.value = ehConfig.commentTrans ?? false;
    everProfile<bool>(
        commentTrans, (bool value) => ehConfig.commentTrans = value);

    // blurredInRecentTasks
    blurredInRecentTasks.value =
        storageUtil.getBool(BLURRED_IN_RECENT_TASK) ?? true;
    everProfile<bool>(blurredInRecentTasks,
        (bool value) => storageUtil.setBool(BLURRED_IN_RECENT_TASK, value));

    // autoLockTimeOut
    autoLockTimeOut.value = ehConfig.autoLockTimeOut ?? -1;
    everProfile<int>(
        autoLockTimeOut, (int value) => ehConfig.autoLockTimeOut = value);

    // showPageInterval
    showPageInterval.value = ehConfig.showPageInterval ?? true;
    everProfile<bool>(
        showPageInterval, (bool value) => ehConfig.showPageInterval = value);

    // orientation
    orientation.value = EnumToString.fromString(
            ReadOrientation.values, ehConfig?.favoritesOrder ?? '') ??
        ReadOrientation.system;
    everFromEunm(orientation, (String value) => ehConfig.orientation = value);
  }

  /// 收藏排序
  Future<FavoriteOrder> showFavOrder() async {
    final BuildContext context = Get.context;
    final Map<FavoriteOrder, String> _orderMap = <FavoriteOrder, String>{
      FavoriteOrder.posted: S.of(context).favorites_order_Use_posted,
      FavoriteOrder.fav: S.of(context).favorites_order_Use_favorited,
    };

    List<Widget> _getOrderList(BuildContext context) {
      return List<Widget>.from(_orderMap.keys.map((FavoriteOrder element) {
        return CupertinoActionSheetAction(
            onPressed: () {
              Get.back(result: element);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (element == favoriteOrder.value)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(CupertinoIcons.checkmark),
                  ),
                Text(_orderMap[element]),
              ],
            ));
      }).toList());
    }

    final FavoriteOrder _result = await showCupertinoModalPopup<FavoriteOrder>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(S.of(context).favorites_order),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(S.of(context).cancel)),
            actions: <Widget>[
              ..._getOrderList(context),
            ],
          );
        });

    if (_result != null) {
      logger.v('to ${EnumToString.convertToString(_result)}');
      if (favoriteOrder.value != _result) {
        return favoriteOrder.value = _result;
      } else {
        return null;
      }
    }
    return _result;
  }

  Future<void> chkClipboardLink() async {
    if (!isClipboardLink.value) {
      return;
    }

    final currentRoute = Get.currentRoute;
    logger.d('currentRoute $currentRoute');

    final pageNames = <String>[
      '/${GalleryMainPage().runtimeType.toString()}',
      EHRoutes.galleryPage,
    ];

    logger.d('pageNames $pageNames');
    final bool _curGalleryPage = pageNames.contains(currentRoute);

    final String _text =
        (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    logger.d('Clipboard ' + _text);
    final RegExp _reg =
        RegExp(r'https?://e[-|x]hentai.org/g/\d+/[0-9a-f]{10}/?');
    final RegExpMatch _mach = _reg.firstMatch(_text);

    if (_mach == null && (_mach?.group(0)?.isEmpty ?? true)) {
      return;
    }

    if (_curGalleryPage && _lastClipboardLink == _mach.group(0)) {
      logger.v('剪贴板链接为当前展示的画廊 返回');
      return;
    }

    logger.d('${_mach.group(0)} ');
    _lastClipboardLink = _mach.group(0);
    _showClipboardLinkDialog(_mach.group(0));
  }

  Future<void> _showClipboardLinkDialog(String url) async {
    showCupertinoDialog(
        context: Get.context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('画廊跳转'),
            content: const Text('检测到剪贴板中包含画廊链接, 是否打开'),
            actions: [
              CupertinoDialogAction(
                child: Text(S.of(context).cancel),
                onPressed: () {
                  Get.back();
                },
              ),
              CupertinoDialogAction(
                child: Text(S.of(context).ok),
                onPressed: () {
                  Get.back();
                  NavigatorUtil.goGalleryPage(url: url);
                },
              ),
            ],
          );
        });
  }
}
