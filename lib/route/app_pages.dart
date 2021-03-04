import 'package:fehviewer/common/controller/cache_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/pages/gallery/bindings/gallery_page_binding.dart';
import 'package:fehviewer/pages/gallery/controller/taginfo_controller.dart';
import 'package:fehviewer/pages/gallery/view/add_tags_page.dart';
import 'package:fehviewer/pages/gallery/view/comment_page.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/pages/image_view/controller/view_controller.dart';
import 'package:fehviewer/pages/image_view/view/view_page.dart';
import 'package:fehviewer/pages/login/login_page.dart';
import 'package:fehviewer/pages/login/web_login_in.dart';
import 'package:fehviewer/pages/setting/about_page.dart';
import 'package:fehviewer/pages/setting/advanced_setting_page.dart';
import 'package:fehviewer/pages/setting/controller/tab_setting_controller.dart';
import 'package:fehviewer/pages/setting/download_setting_page.dart';
import 'package:fehviewer/pages/setting/eh_setting_page.dart';
import 'package:fehviewer/pages/setting/security_setting_page.dart';
import 'package:fehviewer/pages/setting/tab_setting.dart';
import 'package:fehviewer/pages/setting/view_setting_page.dart';
import 'package:fehviewer/pages/tab/bindings/splash_binding.dart';
import 'package:fehviewer/pages/tab/bindings/tabhome_binding.dart';
import 'package:fehviewer/pages/tab/view/download_page.dart';
import 'package:fehviewer/pages/tab/view/favorite_page.dart';
import 'package:fehviewer/pages/tab/view/favorite_sel_page.dart';
import 'package:fehviewer/pages/tab/view/history_page.dart';
import 'package:fehviewer/pages/tab/view/home_page.dart';
import 'package:fehviewer/pages/tab/view/popular_page.dart';
import 'package:fehviewer/pages/tab/view/splash_page.dart';
import 'package:fehviewer/pages/tab/view/unlock_page.dart';
import 'package:fehviewer/pages/tab/view/watched_page.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'routes.dart';

const Duration kUnLockPageTransitionDuration = Duration(milliseconds: 200);

// ignore: avoid_classes_with_only_static_members
class AppPages {
  static final List<GetPage> routes = <GetPage>[
    GetPage(
      name: EHRoutes.root,
      page: () => SplashPage(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: EHRoutes.unlockPage,
      page: () => const UnLockPage(),
      transition: Transition.noTransition,
      transitionDuration: kUnLockPageTransitionDuration,
    ),
    GetPage(
      name: EHRoutes.home,
      page: () => HomePage(),
      binding: TabHomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: EHRoutes.selFavorie,
      page: () => FavoriteSelectorPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.ehSetting,
      page: () => EhSettingPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.advancedSetting,
      page: () => AdvancedSettingPage(),
      transition: Transition.cupertino,
      binding: BindingsBuilder(() => Get.lazyPut(() => CacheController())),
    ),
    GetPage(
      name: EHRoutes.about,
      page: () => AboutPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.downloadSetting,
      page: () => DownloadSettingPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.securitySetting,
      page: () => SecuritySettingPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.viewSeting,
      page: () => ViewSettingPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.login,
      page: () => LoginPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.webLogin,
      page: () => WebLoginViewIn(),
    ),
    GetPage(
      name: EHRoutes.galleryComment,
      page: () => CupertinoScaffold(body: CommentPage()),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.addTag,
      page: () => AddTagPage(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => TagInfoController(), tag: pageCtrlDepth),
      ),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.pageSetting,
      page: () => TabSettingPage(),
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => TabSettingController(),
        ),
      ),
    ),
    GetPage(
      name: EHRoutes.history,
      page: () => const HistoryTab(tabTag: EHRoutes.history),
    ),
    GetPage(
      name: EHRoutes.watched,
      page: () => const WatchedListTab(tabIndex: EHRoutes.watched),
    ),
    GetPage(
      name: EHRoutes.favorite,
      page: () => const FavoriteTab(tabTag: EHRoutes.favorite),
    ),
    GetPage(
      name: EHRoutes.popular,
      page: () => const PopularListTab(tabTag: EHRoutes.popular),
    ),
    GetPage(
      name: EHRoutes.download,
      page: () => const DownloadTab(tabIndex: EHRoutes.download),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.galleryView,
      page: () => const GalleryViewPage(),
      binding: BindingsBuilder<dynamic>(() {
        Get.lazyPut(() => ViewController());
      }),
    ),

    // 使用命名路由跳转 EHRoutes.galleryPage 的话
    // 有多个page时，关闭页面的时候 会全部close
    // 先停用
    GetPage(
      name: EHRoutes.galleryPage,
      page: () => GalleryMainPage(),
      binding: GalleryBinding(),
    ),
  ];
}
