import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/image_view/controller/view_controller.dart';
import 'package:fehviewer/pages/image_view/view/view_page.dart';
import 'package:fehviewer/pages/image_view/view/view_widget.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

import '../common.dart';

class ViewImage extends StatefulWidget {
  const ViewImage(
      {Key key,
      this.ser,
      this.fade = true,
      this.enableSlideOutPage = false,
      this.expand = false,
      this.imageHeight,
      this.imageWidth,
      this.retry = 4})
      : super(key: key);
  final int ser;
  final bool fade;
  final bool enableSlideOutPage;
  final bool expand;
  final double imageHeight;
  final double imageWidth;
  final int retry;

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage>
    with SingleTickerProviderStateMixin {
  Future<GalleryPreview> _imageFuture;
  AnimationController _animationController;

  final GalleryPageController _pageController = Get.find(tag: pageCtrlDepth);
  final ViewController _viewController = Get.find();
  final EhConfigService _ehConfigService = Get.find();
  final CancelToken _getMoreCancelToken = CancelToken();

  ViewController get controller => Get.find();

  /// 拉取图片信息
  Future<GalleryPreview> _fetchImage(
    int itemSer, {
    bool refresh = false,
    bool changeSource = false,
  }) async {
    final GalleryPreview tPreview = _pageController.previewMap[itemSer];
    if (tPreview == null) {
      logger.v('ser:$itemSer 所在页尚未获取， 开始获取');

      // 直接获取需要的
      await _pageController.loadPriviewsForSer(itemSer);

      // logger.v('获取缩略结束后 预载图片');
      GalleryPara.instance.precacheImages(
        Get.context,
        previewMap: _pageController.previewMap,
        itemSer: itemSer,
        max: _ehConfigService.preloadImage.value,
      );
    }

    final GalleryPreview preview = await _pageController.getImageInfo(
      widget.ser,
      cancelToken: _getMoreCancelToken,
      refresh: refresh,
      changeSource: changeSource,
    );
    return preview;
  }

  /// 重载图片数据，重构部件
  Future<void> _reloadImage({bool changeSource = true}) async {
    final GalleryPreview _currentPreview =
        _pageController.galleryItem.previewMap[widget.ser];
    // 清除CachedNetworkImage的缓存
    try {
      // CachedNetworkImage 清除指定缓存
      await CachedNetworkImage.evictFromCache(
          _currentPreview.largeImageUrl ?? '');
      // extended_image 清除指定缓存
      await clearDiskCachedImage(_currentPreview.largeImageUrl ?? '');
      clearMemoryImageCache();
    } catch (_) {}

    _currentPreview.largeImageUrl = null;

    setState(() {
      // 换源重载
      _imageFuture = _fetchImage(
        widget.ser,
        refresh: true,
        changeSource: changeSource,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _imageFuture = _fetchImage(widget.ser);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.fade ? 200 : 0),
    );

    _viewController.vState.fade = true;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewController.vState.needRebuild) {
      _imageFuture = _fetchImage(widget.ser);
      _viewController.vState.needRebuild = false;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () async {
        logger.d('long press');
        vibrateUtil.medium();
        final GalleryPreview _currentPreview =
            _pageController.previewMap[widget.ser];
        showImageSheet(context, _currentPreview?.largeImageUrl, _reloadImage,
            title: '${_pageController.title} [${_currentPreview.ser}]');
      },
      child: FutureBuilder<GalleryPreview>(
          future: _imageFuture,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return LoadingWidget(ser: widget.ser);
                break;
              case ConnectionState.done:
                if (snapshot.hasError) {
                  String _errInfo = '';
                  if (snapshot.error is DioError) {
                    final DioError dioErr = snapshot.error as DioError;
                    logger.e('${dioErr.error}');
                    _errInfo = dioErr.type.toString();
                  } else {
                    _errInfo = snapshot.error.toString();
                  }

                  if ((_pageController.errCountMap[widget.ser] ?? 0) <
                      widget.retry) {
                    Future.delayed(const Duration(milliseconds: 100))
                        .then((_) => _reloadImage(changeSource: true));
                    _pageController.errCountMap.update(
                        widget.ser, (int value) => value + 1,
                        ifAbsent: () => 1);

                    logger.v('${_pageController.errCountMap}');
                    logger.d(
                        '${widget.ser} 重试 第 ${_pageController.errCountMap[widget.ser]} 次');
                  }

                  return ErrorWidget(ser: widget.ser, errInfo: _errInfo);
                } else {
                  final GalleryPreview preview = snapshot.data;
                  Future.delayed(const Duration(milliseconds: 100)).then((_) {
                    try {
                      Get.find<ViewController>()
                          .update(['${GetIds.IMAGE_VIEW_SER}${widget.ser}']);
                    } catch (_) {}
                  });

                  // logger.v('${widget.ser} ${preview.largeImageUrl}');

                  Widget image = ImageExtend(
                    url: preview.largeImageUrl,
                    ser: widget.ser,
                    animationController: _animationController,
                    reloadImage: _reloadImage,
                    imageWidth: snapshot.data.largeImageWidth,
                    imageHeight: snapshot.data.largeImageHeight,
                    retry: widget.retry,
                  );

                  image = Stack(
                    alignment: Alignment.center,
                    fit: widget.expand ? StackFit.expand : StackFit.loose,
                    children: [
                      image,
                      if (Global.inDebugMode)
                        Positioned(
                          left: 4,
                          child: Text('${preview.ser}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color:
                                      CupertinoColors.secondarySystemBackground,
                                  shadows: <Shadow>[
                                    Shadow(
                                      color: Colors.black,
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    )
                                  ])),
                        ),
                    ],
                  );

                  return image;
                }
                break;
              default:
                return Container();
            }
          }),
    );
  }
}

class ImageExtend extends StatelessWidget {
  ImageExtend({
    Key key,
    this.url,
    this.ser,
    this.animationController,
    this.reloadImage,
    this.imageHeight,
    this.imageWidth,
    this.retry = 5,
  }) : super(key: key);

  final String url;
  final int ser;
  final AnimationController animationController;
  final VoidCallback reloadImage;
  final double imageHeight;
  final double imageWidth;
  final int retry;

  final GalleryPageController _pageController = Get.find(tag: pageCtrlDepth);

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      url ?? '',
      fit: BoxFit.contain,
      handleLoadingProgress: true,
      clearMemoryCacheIfFailed: true,
      cache: true,
      timeLimit: const Duration(seconds: 10),
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            animationController.reset();
            final loadingProgress = state.loadingProgress;
            final progress = loadingProgress?.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes
                : null;

            // logger.v('$progress');
            // logger.v('$imageHeight $imageWidth');

            // 下载进度回调
            return UnconstrainedBox(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: context.mediaQueryShortestSide,
                  minWidth: context.width / 2 - kPageViewPadding,
                ),
                alignment: Alignment.center,
                // margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 70,
                      width: 70,
                      child: LiquidCircularProgressIndicator(
                        value: progress ?? 0.0,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(255, 163, 199, 100)),
                        backgroundColor: const Color.fromARGB(255, 50, 50, 50),
                        // borderColor: Colors.teal[900],
                        // borderWidth: 2.0,
                        direction: Axis.vertical,
                        center: progress != null
                            ? Text(
                                '${(progress ?? 0) * 100 ~/ 1}%',
                                style: TextStyle(
                                  color: progress < 0.5
                                      ? CupertinoColors.white
                                      : CupertinoColors.black,
                                  fontSize: 12,
                                  height: 1,
                                ),
                              )
                            : Container(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        '$ser',
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey6,
                          height: 1,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
            break;

          ///if you don't want override completed widget
          ///please return null or state.completedWidget
          //return null;
          //return state.completedWidget;
          case LoadState.completed:
            animationController.forward();
            return FadeTransition(
              opacity: animationController,
              child: ExtendedRawImage(
                fit: BoxFit.contain,
                image: state.extendedImageInfo?.image,
              ),
            );

            break;
          case LoadState.failed:
            logger.d('Failed $url');
            animationController.reset();

            if ((_pageController.errCountMap[ser] ?? 0) < retry) {
              Future.delayed(const Duration(milliseconds: 100))
                  .then((_) => reloadImage());
              _pageController.errCountMap
                  .update(ser, (int value) => value + 1, ifAbsent: () => 1);
              logger.d('${ser} 重试 第 ${_pageController.errCountMap[ser]} 次');
            }

            return Container(
              alignment: Alignment.center,
              constraints: BoxConstraints(
                maxHeight: context.width * 0.8,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error,
                      size: 50,
                      color: Colors.red,
                    ),
                    const Text(
                      'Load image failed',
                      style: TextStyle(
                          fontSize: 10,
                          color: CupertinoColors.secondarySystemBackground),
                    ),
                    Text(
                      '${ser + 1}',
                      style: const TextStyle(
                          color: CupertinoColors.secondarySystemBackground),
                    ),
                  ],
                ),
                onTap: () {
                  // state.reLoadImage();
                  reloadImage();
                },
              ),
            );
            break;
          default:
            return null;
        }
      },
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key key, this.ser}) : super(key: key);
  final int ser;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: context.mediaQueryShortestSide,
          minWidth: context.width / 2 - kPageViewPadding,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '$ser',
              style: const TextStyle(
                fontSize: 50,
                color: CupertinoColors.systemGrey6,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const CupertinoActivityIndicator(),
                const SizedBox(width: 5),
                Text(
                  '${S.of(context).loading}...',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  const ErrorWidget({Key key, this.ser, this.errInfo}) : super(key: key);
  final int ser;
  final String errInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      constraints: BoxConstraints(
        maxHeight: context.width * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error,
            size: 50,
            color: Colors.red,
          ),
          Text(
            errInfo,
            style: const TextStyle(
                fontSize: 10, color: CupertinoColors.secondarySystemBackground),
          ),
          Text(
            '$ser',
            style: const TextStyle(
                color: CupertinoColors.secondarySystemBackground),
          ),
        ],
      ),
    );
  }
}

double initScale({Size imageSize, Size size, double initialScale}) {
  final double n1 = imageSize.height / imageSize.width;
  final double n2 = size.height / size.width;
  if (n1 > n2) {
    final FittedSizes fittedSizes =
        applyBoxFit(BoxFit.contain, imageSize, size);
    //final Size sourceSize = fittedSizes.source;
    final Size destinationSize = fittedSizes.destination;
    return size.width / destinationSize.width;
  } else if (n1 / n2 < 1 / 4) {
    final FittedSizes fittedSizes =
        applyBoxFit(BoxFit.contain, imageSize, size);
    //final Size sourceSize = fittedSizes.source;
    final Size destinationSize = fittedSizes.destination;
    return size.height / destinationSize.height;
  }

  return initialScale;
}
