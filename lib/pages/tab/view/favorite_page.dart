import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/entity/favorite.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/tab/controller/enum.dart';
import 'package:fehviewer/pages/tab/controller/favorite_controller.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

class FavoriteTab extends GetView<FavoriteViewController> {
  const FavoriteTab({Key key, this.tabTag, this.scrollController})
      : super(key: key);
  final String tabTag;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    // logger.d(' FavoriteTab BuildContext');
    final UserController userController = Get.find();
    return CupertinoPageScaffold(
      child: Obx(() {
        if (userController.isLogin) {
          if (controller.title.value == null ||
              controller.title.value.isEmpty) {
            controller.title.value = S.of(context).all_Favorites;
          }
          return _buildNetworkFavView(context);
        } else {
          return _buildLocalFavView();
        }
      }),
    );
  }

  Widget _buildNetworkFavView(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          transitionBetweenRoutes: false,
          padding: const EdgeInsetsDirectional.only(end: 4),
          largeTitle: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.title.value,
              ),
              Obx(() {
                if (controller.isBackgroundRefresh)
                  return const CupertinoActivityIndicator(
                    radius: 10,
                  ).paddingSymmetric(horizontal: 8);
                else
                  return const SizedBox();
              }),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 搜索按钮
              CupertinoButton(
                minSize: 40,
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  LineIcons.search,
                  size: 26,
                ),
                onPressed: () {
                  final bool fromTabItem =
                      Get.find<TabHomeController>().tabMap[tabTag] ?? false;
                  NavigatorUtil.showSearch(
                      searchType: SearchType.favorite,
                      fromTabItem: fromTabItem);
                },
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(0.0),
                minSize: 36,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      LineIcons.sortAmountDown,
                      size: 26,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        controller.orderText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                onPressed: controller.setOrder,
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(0),
                minSize: 36,
                // child: ClipRRect(
                //   borderRadius: BorderRadius.circular(8),
                //   child: Container(
                //     padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                //     color: CupertinoDynamicColor.resolve(
                //         CupertinoColors.activeBlue, context),
                //     child: Obx(() => Text(
                //           '${controller.curPage.value + 1}',
                //           style: TextStyle(
                //               color: CupertinoDynamicColor.resolve(
                //                   CupertinoColors.secondarySystemBackground,
                //                   context)),
                //         )),
                //   ),
                // ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.activeBlue, context),
                        width: 1.5,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: Obx(() => Text(
                        '${controller.curPage.value + 1}',
                        style: TextStyle(
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.activeBlue, context)),
                      )),
                ),
                onPressed: () {
                  controller.jumpToPage();
                },
              ),
              _buildFavcatButton(context),
            ],
          ),
        ),
        CupertinoSliverRefreshControl(
          onRefresh: controller.onRefresh,
        ),
        SliverSafeArea(
          top: false,
          sliver: _getGalleryList(),
        ),
        _endIndicator(),
      ],
    );
  }

  Widget _buildLocalFavView() {
    return CustomScrollView(slivers: <Widget>[
      CupertinoSliverNavigationBar(
        largeTitle: Text(S.of(Get.context).local_favorite),
        transitionBetweenRoutes: false,
      ),
      CupertinoSliverRefreshControl(
        onRefresh: () async {
          await controller.reloadData();
        },
      ),
      // todo 可能要设置刷新？
      SliverSafeArea(
        top: false,
        sliver: _getGalleryList(),
      ),
      _endIndicator(),
    ]);
  }

  Widget _endIndicator() {
    return SliverToBoxAdapter(
      child: Obx(() => Container(
            padding: const EdgeInsets.only(top: 50, bottom: 100),
            child: () {
              switch (controller.pageState) {
                case PageState.None:
                  return Container();
                case PageState.Loading:
                  return const CupertinoActivityIndicator(
                    radius: 14,
                  );
                case PageState.LoadingException:
                case PageState.LoadingError:
                  return GestureDetector(
                    onTap: controller.loadDataMore,
                    child: Column(
                      children: <Widget>[
                        const Icon(
                          Icons.error,
                          size: 40,
                          color: CupertinoColors.systemRed,
                        ),
                        Text(
                          S.of(Get.context).list_load_more_fail,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                default:
                  return Container();
              }
            }(),
          )),
    );
  }

  Widget _getGalleryList() {
    return controller.obx(
        (List<GalleryItem> state) {
          return getGalleryList(
            state,
            tabTag,
            maxPage: controller.maxPage,
            curPage: controller.curPage.value,
            loadMord: controller.loadDataMore,
          );
        },
        onLoading: SliverFillRemaining(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 50),
            child: const CupertinoActivityIndicator(
              radius: 14.0,
            ),
          ),
        ),
        onError: (err) {
          logger.e(' $err');
          return SliverFillRemaining(
            child: Container(
              padding: const EdgeInsets.only(bottom: 50),
              child: GalleryErrorPage(
                onTap: controller.reLoadDataFirst,
              ),
            ),
          );
        });
  }

  /// 切换收藏夹
  Widget _buildFavcatButton(BuildContext context) {
    final EhConfigService ehConfigService = Get.find();
    return CupertinoButton(
      minSize: 40,
      padding: const EdgeInsets.only(right: 8),
      child: const Icon(
        LineIcons.star,
        size: 26,
      ),
      onPressed: () async {
        // 跳转收藏夹选择页
        Get.toNamed(EHRoutes.selFavorie).then((result) async {
          if (result.runtimeType == FavcatItemBean) {
            final FavcatItemBean fav = result;
            if (controller.curFavcat != fav.favId) {
              loggerNoStack.v('set fav to ${fav.title}');
              controller.title(fav.title);
              controller.enableDelayedLoad = false;
              controller.curFavcat = fav.favId;
              ehConfigService.lastShowFavcat = controller.curFavcat;
              ehConfigService.lastShowFavTitle = fav.title;
              controller.reLoadDataFirst();
            } else {
              loggerNoStack.v('未修改favcat');
            }
          }
        });
      },
    );
  }
}
