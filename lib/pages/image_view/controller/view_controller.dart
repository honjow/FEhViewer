import 'dart:async';

import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:orientation/orientation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'view_state.dart';

const double kBottomBarHeight = 44.0;
const double kTopBarHeight = 40.0;

class ViewController extends GetxController {
  ViewController();

  // 状态
  final ViewState vState = ViewState();

  /// 切换单页双页模式
  void switchColumnMode() {
    vibrateUtil.light();
    logger.v('切换单页双页模式');
    switch (vState.columnMode) {
      case ColumnMode.single:
        logger.d('单页 => 双页1. itemIndex:${vState.itemIndex},');
        vState.columnMode = ColumnMode.odd;
        pageController.jumpToPage(vState.pageIndex);
        break;
      case ColumnMode.odd:
        logger.d('双页1 => 双页2, itemIndex:${vState.itemIndex}');
        vState.columnMode = ColumnMode.even;
        vState.needRebuild = true;
        pageController.jumpToPage(vState.pageIndex);
        break;
      case ColumnMode.even:
        logger.d('双页2 => 单页, itemIndex:${vState.itemIndex}');
        vState.columnMode = ColumnMode.single;
        Future.delayed(Duration.zero).then((_) {
          final int _toIndex = vState.pageIndex;
          pageController.jumpToPage(_toIndex);
          logger.d('pageIndex $_toIndex');
          vState.itemIndex = _toIndex;
          vState.sliderValue = _toIndex.toDouble();
        });

        break;
    }
  }

  PageController pageController;
  PageController _pageControllerNotInv;
  PageController _pageControllerInv;

  final EhConfigService _ehConfigService = Get.find();
  final GalleryPageController _galleryPageController =
      Get.find(tag: pageCtrlDepth);

  int lastPreviewLen;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  DeviceOrientation _deviceOrientation;
  StreamSubscription<DeviceOrientation> subscription;

  @override
  void onInit() {
    super.onInit();
    // logger.d('ViewController onInit() start');

    if (GetPlatform.isIOS)
      Future.delayed(const Duration(milliseconds: 200))
          .then((_) => SystemChrome.setEnabledSystemUIOverlays([]));

    // logger.d('初始化page页码 ${vState.pageIndex}');
    final int _initialPage = vState.pageIndex;

    // 横屏模式pageview控制器初始化
    pageController =
        PageController(initialPage: _initialPage, viewportFraction: 1.0);

    // 竖屏模式初始页码
    if (vState.viewMode == ViewMode.topToBottom) {
      // logger.v('竖屏模式初始页码: ${vState.itemIndex}');
      Future.delayed(const Duration(milliseconds: 200)).then(
          (value) => itemScrollController.jumpTo(index: vState.itemIndex));
    }

    /// 初始预载
    /// 后续的预载触发放在翻页事件中
    final int _preload = _ehConfigService.preloadImage.value;
    if (vState.viewMode != ViewMode.topToBottom) {
      // 预载
      logger.v('初始预载');
      GalleryPara.instance.precacheImages(
        Get.context,
        previewMap: vState.previewMap,
        itemSer: vState.itemIndex,
        max: _preload,
      );
    }

    vState.sliderValue = vState.itemIndex / 1.0;

    // subscription = OrientationHelper.onOrientationChange.listen((value) {
    //   // If the widget was removed from the tree while the asynchronous platform
    //   // message was in flight, we want to discard the reply rather than calling
    //   // setState to update our non-existent appearance.
    //
    //   // setState(() {
    //   //   _deviceOrientation = value;
    //   // });
    //
    //   _deviceOrientation = value;
    //
    //   OrientationHelper.forceOrientation(value);
    // });
    // OrientationPlugin.forceOrientation(DeviceOrientation.landscapeLeft);
    final _orientation = _ehConfigService.orientation.value;
    if (_orientation != ReadOrientation.system ||
        _orientation != ReadOrientation.auto) {
      OrientationPlugin.setPreferredOrientations(
          [orientationMap[_orientation]]);
      OrientationPlugin.forceOrientation(orientationMap[_orientation]);
    }

    // logger.d('onInit() end');
  }

  @override
  void onClose() {
    pageController.dispose();
    vState.getMoreCancelToken.cancel();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    // 恢复系统旋转设置
    OrientationPlugin.setPreferredOrientations(DeviceOrientation.values);
    OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
    super.onClose();
  }

  /// SliderChangedEnd
  Future<void> handOnSliderChangedEnd(double value) async {
    vState.itemIndex = value.round();
    logger.d('slider to _itemIndex ${vState.itemIndex}');

    if (vState.viewMode != ViewMode.topToBottom) {
      // await _galleryPageController.fetchPreviewUntilIndex(
      //     Get.context, vState.itemIndex);
      // await Future.delayed(const Duration(milliseconds: 200));
      pageController.jumpToPage(vState.pageIndex);
    } else {
      // await _galleryPageController.fetchPreviewUntilIndex(
      //     Get.context, vState.itemIndex);
      // await Future.delayed(const Duration(milliseconds: 200));
      itemScrollController.jumpTo(index: vState.itemIndex);
    }

    await Future.delayed(const Duration(milliseconds: 200));
    update([GetIds.IMAGE_VIEW_SLIDER]);
  }

  void handOnSliderChanged(double value) {
    vState.sliderValue = value;
    update([GetIds.IMAGE_VIEW_SLIDER]);
  }

  // 页码切换时的回调
  void handOnPageChanged(int pageIndex) {
    // 根据columnMode的不同设置不同的itemIndex值
    switch (vState.columnMode) {
      case ColumnMode.single:
        vState.itemIndex = pageIndex;
        break;
      case ColumnMode.odd:
        vState.itemIndex = pageIndex * 2;
        break;
      case ColumnMode.even:
        final int index = pageIndex * 2 - 1;
        vState.itemIndex = index > 0 ? index : 0;
        break;
    }

    // logger.d(
    //     '页码切换时的回调 handOnPageChanged  pageIndex:$pageIndex itemIndex${vState.itemIndex}');

    // 预载图片
    // logger.v('页码切换时的回调 预载图片');
    GalleryPara.instance.precacheImages(
      Get.context,
      previewMap: _galleryPageController.previewMap,
      itemSer: vState.itemIndex,
      max: _ehConfigService.preloadImage.value,
    );
    // logger.d('itemIndex $itemIndex  ${itemIndex.toDouble()}');
    if (vState.itemIndex >= vState.filecount - 1) {
      vState.sliderValue = (vState.filecount - 1).toDouble();
    } else if (vState.itemIndex < 0) {
      vState.sliderValue = 1.0;
    } else {
      vState.sliderValue = vState.itemIndex.toDouble();
    }

    // logger.d('handOnPageChanged  end');
  }

  // 点击中间
  Future<void> handOnTapCent() async {
    if (GetPlatform.isIOS) {
      // 会rebuild GalleryViewPage
      if (!vState.showBar) {
        await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        vState.showBar = !vState.showBar;
      } else {
        vState.showBar = !vState.showBar;
        await Future.delayed(Duration(milliseconds: 200));
        SystemChrome.setEnabledSystemUIOverlays([]);
      }
    } else {
      vState.showBar = !vState.showBar;
    }
  }

  // 点击周围
  void handOnPanDown(DragDownDetails details) {
    final Rect _centRect = WidgetUtil.getWidgetGlobalRect(vState.centkey);

    final double _dx = details.globalPosition.dx;
    final double _dy = details.globalPosition.dy;
    // logger.d(
    //     'onPanDown ${details.globalPosition}  $_centRect');
    if ((_dx < _centRect.left || _dx > _centRect.right) &&
        (_dy < _centRect.top || _dy > _centRect.bottom)) {
      // logger.d('onPanDown hide bar');
      vState.showBar = false;
    }
  }

  void onDidFinishLayout(int firstIndex, int lastIndex) {
    // logger.d('firstIndex: $firstIndex, lastIndex: $lastIndex');
    final int index = (lastIndex + firstIndex) ~/ 2;
    // logger.d('$index ');
    if (index != vState.itemIndex) {
      Future.delayed(const Duration(milliseconds: 300)).then((_) {
        vState.itemIndex = index;
        vState.sliderValue = vState.itemIndex / 1.0;
      });
    }
    // currentIndex = index;
  }

  /// 竖屏阅读下页码变化的监听
  void handItemPositionsChange(Iterable<ItemPosition> positions) {
    int min;
    int max;
    if (positions.isNotEmpty) {
      // Determine the first visible item by finding the item with the
      // smallest trailing edge that is greater than 0.  i.e. the first
      // item whose trailing edge in visible in the viewport.
      min = positions
          .where((ItemPosition position) => position.itemTrailingEdge > 0)
          .reduce((ItemPosition min, ItemPosition position) =>
              position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
          .index;
      // Determine the last visible item by finding the item with the
      // greatest leading edge that is less than 1.  i.e. the last
      // item whose leading edge in visible in the viewport.
      max = positions
          .where((ItemPosition position) => position.itemLeadingEdge < 1)
          .reduce((ItemPosition max, ItemPosition position) =>
              position.itemLeadingEdge > max.itemLeadingEdge ? position : max)
          .index;

      final int index = (min + max) ~/ 2;

      // logger.d('${positions.elementAt(index).itemLeadingEdge} ');
      if (index != vState.itemIndex) {
        Future.delayed(const Duration(milliseconds: 300)).then((value) {
          vState.itemIndex = index;
          vState.sliderValue = vState.itemIndex / 1.0;
          update([GetIds.IMAGE_VIEW_SLIDER]);
        });
      }
    }
    // logger.i('First Item: ${min ?? ''}\nLast Item: ${max ?? ''}');
  }

  /// 检查模式 及处理
  void checkViewModel() {
    // logger.d('checkViewModel start');
    if (vState.viewMode != vState.lastViewMode) {
      if (vState.viewMode == ViewMode.topToBottom) {
        Future.delayed(const Duration(milliseconds: 100)).then((_) {
          itemScrollController.jumpTo(index: vState.itemIndex);
        });
      } else {
        Future.delayed(const Duration(milliseconds: 100)).then((_) {
          pageController.jumpToPage(vState.pageIndex);
        });
      }
      vState.lastViewMode = vState.viewMode;
    }
    // logger.d('checkViewModel end');
  }

  // 点击左半边
  void tapLeft() {
    vState.fade = false;
    if (vState.viewMode == ViewMode.LeftToRight) {
      if (vState.pageIndex > 0) {
        pageController.jumpToPage(vState.pageIndex - 1);
      }
    } else if (vState.viewMode == ViewMode.rightToLeft) {
      pageController.jumpToPage(vState.pageIndex + 1);
    }
  }

  // 点击右半边
  void tapRight() {
    vState.fade = false;
    if (vState.viewMode == ViewMode.LeftToRight) {
      pageController.jumpToPage(vState.pageIndex + 1);
    } else if (vState.viewMode == ViewMode.rightToLeft) {
      if (vState.pageIndex > 0) {
        pageController.jumpToPage(vState.pageIndex - 1);
      }
    }
  }
}
