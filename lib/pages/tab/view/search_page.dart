import 'dart:math';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/filter/filter.dart';
import 'package:fehviewer/pages/gallery/view/gallery_widget.dart';
import 'package:fehviewer/pages/tab/controller/enum.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/store/tag_database.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

const CupertinoDynamicColor _kClearButtonColor =
    CupertinoDynamicColor.withBrightness(
  color: Color(0xFF636366),
  darkColor: Color(0xFFAEAEB2),
);

enum SearchMenuEnum {
  filter,
  quickSearchList,
  addToQuickSearch,
}

class GallerySearchPage extends StatelessWidget {
  SearchPageController get controller => Get.find(tag: searchPageCtrlDepth);

  Widget get searchTextFieldNew => Obx(() => CupertinoSearchTextField(
        padding: const EdgeInsetsDirectional.fromSTEB(3, 6, 5, 6),
        style: const TextStyle(height: 1.25),
        placeholder: controller.placeholderText,
        placeholderStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          color: CupertinoColors.placeholderText,
          height: 1.25,
        ),
        controller: controller.searchTextController,
        suffixIcon: const Icon(LineIcons.timesCircle),
        onSubmitted: (_) => controller.onEditingComplete(),
        focusNode: controller.focusNode,
      ));

  Widget get searchTextField => Obx(() => CupertinoTextField(
        style: const TextStyle(height: 1.25),
        decoration: BoxDecoration(
          color: ehTheme.textFieldBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        ),
        placeholder: controller.placeholderText,
        placeholderStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          color: CupertinoColors.placeholderText,
          height: 1.25,
        ),
        // clearButtonMode: OverlayVisibilityMode.editing,
        prefix: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minSize: 0,
          child: const Icon(
            LineIcons.search,
            color: CupertinoColors.systemGrey,
          ),
          onPressed: () {},
        ),
        suffix: GetBuilder<SearchPageController>(
          id: GetIds.SEARCH_CLEAR_BTN,
          tag: searchPageCtrlDepth,
          builder: (SearchPageController controller) {
            return controller.showClearButton
                ? GestureDetector(
                    onTap: controller.clear,
                    child: Icon(
                      LineIcons.timesCircle,
                      size: 18.0,
                      color: CupertinoDynamicColor.resolve(
                          _kClearButtonColor, Get.context),
                    ).paddingSymmetric(horizontal: 6),
                  )
                : const SizedBox();
          },
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(0, 6, 5, 6),
        controller: controller.searchTextController,
        autofocus: controller.autofocus,
        textInputAction: TextInputAction.search,
        onEditingComplete: controller.onEditingComplete,
        focusNode: controller.focusNode,
      ));

  @override
  Widget build(BuildContext context) {
    final Widget cfp = CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(start: 0),
//        border: null,

        middle: searchTextFieldNew,
        // middle: searchTextField,
        transitionBetweenRoutes: false,
        leading: const SizedBox.shrink(),
        trailing: _buildTrailing(context),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // 触摸收起键盘
          FocusScope.of(context).requestFocus(FocusNode());
        },
        onPanDown: (DragDownDetails details) {
          // 滑动收起键盘
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: CustomScrollView(
          slivers: <Widget>[
            Obx(() => SliverSafeArea(
                  sliver: () {
                    switch (controller.listType) {
                      case ListType.gallery:
                        return _getGalleryList();
                      case ListType.tag:
                        return _getTagQryList();
                      case ListType.init:
                        return _getInitView();
                    }
                  }(),
                )),
            _endIndicator(),
          ],
        ),
      ),
    );

    return cfp;
  }

  // tag搜索结果页面
  Widget _getTagQryList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.addQryTag(index);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${controller.qryTags[index].namespace.shortName}:${controller.qryTags[index].key}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                    '${EHConst.translateTagType[controller.qryTags[index].namespace] ?? controller.qryTags[index].namespace}:${controller.qryTags[index].name}',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.secondaryLabel, Get.context),
                    )),
              ],
            ).paddingSymmetric(vertical: 4, horizontal: 20),
          );
        },
        childCount: controller.qryTags.length,
      ),
    );
  }

  // 初始化页面
  Widget _getInitView() {
    Future<String> _getTextTranslate(String text) async {
      final String tranText = await EhTagDatabase.getTranTagWithNameSpase(text);
      if (tranText != null && tranText.trim() != text) {
        return tranText;
      } else {
        return null;
      }
    }

    Widget _btn(String text) {
      return TagButton(
        text: text,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        onPressed: () {
          controller.appendTextToSearch(text);
        },
        onLongPress: () async {
          final String tranText = await _getTextTranslate(text);
          if (tranText != null) {
            vibrateUtil.medium();
            showCupertinoDialog(
                context: Get.overlayContext,
                barrierDismissible: true,
                builder: (_) {
                  return CupertinoAlertDialog(
                    content: Text(tranText),
                  );
                });
          }
        },
      );
    }

    return GetBuilder<SearchPageController>(
      tag: searchPageCtrlDepth,
      id: GetIds.SEARCH_INIT_VIEW,
      builder: (SearchPageController controller) {
        final List<Widget> _btnList = List<Widget>.from(
            controller.searchHistory.map((String text) => _btn(text)).toList());

        final Widget _searchHistory = SliverToBoxAdapter(
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.searchHistory.isNotEmpty)
                  Text(
                    S.of(Get.context).search_history,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                Container(
                  child: Wrap(
                    spacing: 8, //主轴上子控件的间距
                    runSpacing: 8, //交叉轴上子控件之间的间距
                    children: _btnList.sublist(
                        0, min<int>(20, _btnList.length)), //要显示的子控件集合
                  ),
                ).paddingSymmetric(vertical: 8.0),
                if (controller.searchHistory.isNotEmpty)
                  GestureDetector(
                    onTap: controller.clearHistory,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.delete,
                            size: 17,
                            color: Colors.red,
                          ),
                          Text(
                            S.of(Get.context).clear_search_history,
                            style: TextStyle(
                              fontSize: 15,
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.secondaryLabel, Get.context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        );
        return _searchHistory;
      },
    );
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
          controller.tabIndex,
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
              onTap: controller.refresh,
            ),
          ),
        );
      },
      onEmpty: SliverFillRemaining(
        child: Container(),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    Widget _buildListBtns() {
      return GestureDetector(
        onLongPress: () {
          controller.isSearchBarComp = true;
          vibrateUtil.heavy();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CupertinoButton(
              minSize: 40,
              padding: const EdgeInsets.only(left: 4),
              child: Text(S.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.all(0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.activeBlue, context),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
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
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                LineIcons.filter,
                size: 26,
              ),
              onPressed: () {
                showFilterSetting();
              },
            ),
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                LineIcons.plusCircle,
                size: 26,
              ),
              onPressed: () {
                controller.addToQuickSearch();
              },
            ),
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                LineIcons.listUl,
                size: 26,
              ),
              onPressed: () {
                controller.quickSearchList();
              },
            ),
          ],
        ),
      );
    }

    Widget _menuItem({IconData icon, String title, VoidCallback onTap}) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          vibrateUtil.light();
          controller.customPopupMenuController.hideMenu();
          onTap();
        },
        child: Container(
          padding:
              const EdgeInsets.only(left: 14, right: 18, top: 5, bottom: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 24,
                // color: CupertinoDynamicColor.resolve(
                //     CupertinoColors.secondaryLabel, Get.context),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    title ?? '',
                    style: TextStyle(
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.label, Get.context),
                      // fontWeight: FontWeight.w500,
                      // fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildMenu() {
      final Color _color =
          CupertinoDynamicColor.resolve(CupertinoColors.systemGrey6, context)
              .withOpacity(0.95);
      return CustomPopupMenu(
        child: Container(
          width: 40,
          padding: const EdgeInsets.only(right: 14, left: 4, bottom: 2),
          child: const Icon(
            // LineIcons.horizontalEllipsis,
            CupertinoIcons.ellipsis_circle,
            size: 26,
          ),
        ),
        arrowColor: _color,
        showArrow: false,
        menuBuilder: () {
          vibrateUtil.light();
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: _color,
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _menuItem(
                      icon: LineIcons.filter,
                      title: S.of(context).show_filter,
                      onTap: showFilterSetting,
                    ),
                    _menuItem(
                      icon: LineIcons.plusCircle,
                      title: S.of(context).add_quick_search,
                      onTap: controller.addToQuickSearch,
                    ),
                    _menuItem(
                      icon: LineIcons.listUl,
                      title: S.of(context).quick_search,
                      onTap: controller.quickSearchList,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        pressType: PressType.singleClick,
        controller: controller.customPopupMenuController,
      );
    }

    Widget _buildPopMenuBtn() {
      return GestureDetector(
        onLongPress: () {
          controller.isSearchBarComp = false;
          vibrateUtil.heavy();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CupertinoButton(
              minSize: 40,
              padding: const EdgeInsets.only(left: 4),
              child: Text(S.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.all(0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.activeBlue, context),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
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
            Card(
              margin: const EdgeInsets.all(0),
              child: _buildMenu(),
              color: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
          ],
        ),
      );
    }

    return Obx(() {
      final Size size = MediaQuery.of(context).size;
      final double width = size.width;
      final bool _isSearchBarComp = controller.isSearchBarComp;
      if (width > 450) {
        return _buildListBtns();
      } else {
        return AnimatedSwitcher(
            duration: const Duration(milliseconds: 0),
            child: _isSearchBarComp
                ? Container(key: UniqueKey(), child: _buildPopMenuBtn())
                : Container(key: UniqueKey(), child: _buildListBtns()));
      }
    });
  }
}
