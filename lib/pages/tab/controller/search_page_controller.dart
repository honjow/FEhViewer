import 'dart:collection';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fehviewer/common/controller/quicksearch_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/entity/tag_translat.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/tab/view/quick_search_page.dart';
import 'package:fehviewer/store/gallery_store.dart';
import 'package:fehviewer/utils/db_util.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import 'enum.dart';
import 'favorite_controller.dart';
import 'tabview_controller.dart';

enum SearchType {
  normal,
  watched,
  favorite,
}

enum ListType {
  gallery,
  tag,
  init,
}

class SearchPageController extends TabViewController {
  SearchPageController(
      {SearchType searchType = SearchType.normal, this.initSearchText}) {
    this.searchType = searchType;
  }

  final String initSearchText;

  String searchText;
  bool _autoComplete = false;

  final String tabIndex = 'search_$searchPageCtrlDepth';
  final CustomPopupMenuController customPopupMenuController =
      CustomPopupMenuController();

  // 搜索输入框的控制器
  final TextEditingController searchTextController = TextEditingController();

  bool get showClearButton => searchTextController.text.isNotEmpty ?? false;

  final GStore _gStore = Get.find();

  // 搜索类型
  final Rx<SearchType> _searchType = SearchType.normal.obs;
  SearchType get searchType => _searchType.value ?? SearchType.normal;

  String get placeholderText {
    final BuildContext context = Get.context;
    logger.v('$searchType');
    switch (searchType) {
      case SearchType.favorite:
        return '${S.of(context).search} ${S.of(context).tab_favorite}';
        break;
      case SearchType.watched:
        return '${S.of(context).search} ${S.of(context).tab_watched}';
        break;
      case SearchType.normal:
      default:
        return '${S.of(context).search} ${S.of(context).tab_gallery}';
        break;
    }
  }

  set searchType(SearchType val) => _searchType.value = val;

  final Rx<ListType> _listType = ListType.init.obs;
  ListType get listType => _listType.value;
  set listType(ListType val) => _listType.value = val;

  final RxList<TagTranslat> qryTags = <TagTranslat>[].obs;
  String _currQry;

  FocusNode focusNode = FocusNode();

  String _search = '';

  DateTime _lastInputCompleteAt; //上次输入完成时间
  String _lastSearchText;

  /// 自动获取焦点
  bool autofocus = false;

  final EhConfigService _ehConfigService = Get.find();
  final QuickSearchController quickSearchController = Get.find();
  final FavoriteViewController _favoriteViewController = Get.find();

  /// 控制右侧按钮展开折叠
  bool get isSearchBarComp => _ehConfigService.isSearchBarComp.value;
  set isSearchBarComp(bool val) => _ehConfigService.isSearchBarComp.value = val;

  /// 执行搜索
  Future<void> _startSearch() async {
    final String _searchText = searchTextController.text.trim();
    logger.d('_searchText $_searchText');

    if (_searchText.isNotEmpty) {
      _search = _searchText;

      analytics.logSearch(searchTerm: _search);

      addHistory();

      change(state, status: RxStatus.loading());
      try {
        final List<GalleryItem> _list = await _fetchData(refresh: true);
        change(_list, status: RxStatus.success());
      } catch (err) {
        change(null, status: RxStatus.error(err.toString()));
      }
    } else {
      state?.clear();
      update();
    }
  }

  /// 点击键盘完成
  Future<void> onEditingComplete() async {
    listType = ListType.gallery;
    await _startSearch();
  }

  /// 延迟搜索
  Future<void> _delayedSearch() async {
    update([GetIds.SEARCH_CLEAR_BTN]);
    logger.d(' _delayedSearch');
    const Duration _duration = Duration(milliseconds: 800);
    _lastInputCompleteAt = DateTime.now();
    await Future<void>.delayed(_duration);
    if (_lastSearchText?.trim() != searchTextController.text.trim() &&
        DateTime.now().difference(_lastInputCompleteAt) >= _duration) {
      logger.d('_autoComplete $_autoComplete');
      if (searchTextController.text.trim().isEmpty) {
        listType = ListType.init;
        return;
      }

      if (_autoComplete) {
        listType = ListType.gallery;
        _autoComplete = false;
        return await _startSearch();
      }

      listType = ListType.tag;

      _lastSearchText = searchTextController.text.trim();

      _currQry = searchTextController.text.trim().split(RegExp(r'[ ;"]')).last;
      if (_currQry.isEmpty) {
        qryTags([]);
        return;
      }

      try {
        dbUtil
            .getTagTransFuzzy(_currQry, limit: 200)
            .then((List<TagTranslat> qryTags) {
          this.qryTags(qryTags);
        });
      } catch (_) {}

      logger.d('$_autoComplete');
      if (_autoComplete) {
        listType = ListType.gallery;
        await _startSearch();
      }
    }
  }

  /// 加载更多
  @override
  Future<void> loadDataMore({bool cleanSearch = false}) async {
    if (pageState == PageState.Loading) {
      return;
    }

    if (cleanSearch) {
      _search = '';
    }

    final int _catNum = _ehConfigService.catFilter.value;

    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));

    try {
      pageState = PageState.Loading;

      final String fromGid = state.last.gid;
      final Tuple2<List<GalleryItem>, int> tuple =
          searchType != SearchType.favorite
              ? await Api.getGallery(
                  page: curPage.value + 1,
                  fromGid: fromGid,
                  cats: _catNum,
                  serach: _search,
                  searchType: searchType,
                  refresh: true,
                )
              : await Api.getFavorite(
                  page: curPage.value + 1,
                  favcat: _favoriteViewController.curFavcat,
                  serach: _search,
                  refresh: true,
                );
      final List<GalleryItem> gallerItemBeans = tuple.item1;

      state.addAll(gallerItemBeans);

      maxPage = tuple.item2;
      curPage += 1;
      pageState = PageState.None;
      update();
    } catch (e, stack) {
      pageState = PageState.LoadingException;
      rethrow;
    }
  }

  /// 获取数据
  Future<List<GalleryItem>> _fetchData({bool refresh = false}) async {
    final int _catNum = _ehConfigService.catFilter.value;

    // logger.v('_loadDataFirst');

    final Tuple2<List<GalleryItem>, int> tuple =
        searchType != SearchType.favorite
            ? await Api.getGallery(
                cats: _catNum,
                serach: _search,
                refresh: refresh,
                searchType: searchType,
              )
            : await Api.getFavorite(
                favcat: _favoriteViewController.curFavcat,
                serach: _search,
                refresh: refresh,
              );
    final List<GalleryItem> gallerItemBeans = tuple.item1;
    maxPage = tuple.item2;
    return gallerItemBeans;
  }

  /// 从指定页数开始
  @override
  Future<void> loadFromPage(int page) async {
    logger.v('jump to page =>  $page');

    final int _catNum = _ehConfigService.catFilter.value;

    change(state, status: RxStatus.loading());
    final Tuple2<List<GalleryItem>, int> tuple =
        searchType != SearchType.favorite
            ? await Api.getGallery(
                page: page,
                cats: _catNum,
                serach: _search,
                refresh: true,
                searchType: searchType,
              )
            : await Api.getFavorite(
                page: page,
                favcat: _favoriteViewController.curFavcat,
                serach: _search,
                refresh: true,
              );
    curPage.value = page;
    change(tuple.item1, status: RxStatus.success());
  }

  List<String> searchHistory = <String>[].obs;
  void addHistory() {
    searchHistory.insert(0, searchTextController.text.trim());
    searchHistory = LinkedHashSet<String>.from(searchHistory).toList();
    if (searchHistory.length > 100) {
      searchHistory.removeRange(100, searchHistory.length);
    }
    _gStore.searchHistory = searchHistory;
  }

  void clearHistory() {
    searchHistory.clear();
    update([GetIds.SEARCH_INIT_VIEW]);
    _gStore.searchHistory = searchHistory;
  }

  @override
  void onInit() {
    fetchNormal = Api.getGallery;
    searchHistory = _gStore.searchHistory;
    _autoComplete = initSearchText?.trim()?.isNotEmpty ?? false;
    super.onInit();
  }

  @override
  Future<void> firstLoad() async {
    searchTextController.addListener(_delayedSearch);
    if (initSearchText != null && initSearchText.trim().isNotEmpty) {
      logger.d('$searchText');
      searchTextController.text = initSearchText.trim();
      autofocus = false;
    } else {
      // autofocus = true;
    }
    change(<GalleryItem>[], status: RxStatus.empty());
  }

  @override
  void onClose() {
    searchTextController.dispose();
    Get.find<DepthService>().popSearchPageCtrl();
    super.onClose();
  }

  /// 添加当前搜索框内容到快速搜索
  void addToQuickSearch() {
    final String _text = searchTextController.text;
    if (_text.isNotEmpty) {
      quickSearchController.addText(_text);
    }
  }

  /// 打开快速搜索列表
  void quickSearchList() {
    Get.to<String>(
      QuickSearchListPage(),
      transition: Transition.cupertino,
    ).then((String value) {
      // return searchTextController.text = value;
      // final String _text = value ?? '';
      if (value == null) {
        return;
      }
      searchTextController.value = TextEditingValue(
        text: '$value ',
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream, offset: '$value '.length)),
      );

      FocusScope.of(Get.context).requestFocus(focusNode);
    });
  }

  void addQryTag(int index) {
    final TagTranslat _qry = qryTags[index];
    final String _add = _qry.key.contains(' ')
        ? '${_qry.namespace.trim().shortName}:"${_qry.key}\$"'
        : '${_qry.namespace.trim().shortName}:${_qry.key}\$';
    logger.i('_add $_add ');

    final String _lastSearchText = this._lastSearchText ?? '';
    final String _newSearch =
        _lastSearchText.replaceAll(RegExp('$_currQry\$'), _add);
    logger.i(
        '_lastSearchText $_lastSearchText \n_currQry $_currQry\n_newSearch $_newSearch ');

    _autoComplete = false;
    searchTextController.value = TextEditingValue(
      text: '$_newSearch ',
      selection: TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream, offset: '$_newSearch '.length)),
    );

    FocusScope.of(Get.context).requestFocus(focusNode);
  }

  void appendTextToSearch(String text) {
    final String _lastSearchText = searchTextController.text ?? '';
    final String _newSearch = '$_lastSearchText $text';
    _autoComplete = false;
    searchTextController.value = TextEditingValue(
      text: '$_newSearch ',
      selection: TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream, offset: '$_newSearch '.length)),
    );

    FocusScope.of(Get.context).requestFocus(focusNode);
  }

  void clear() {
    vibrateUtil.light();
    searchTextController.clear();
  }
}

extension ExSearch on String {
  String get shortName {
    if (this != 'misc') {
      return substring(0, 1);
    } else {
      return this;
    }
  }
}
