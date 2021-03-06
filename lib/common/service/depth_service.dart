import 'package:get/get.dart';

String get pageCtrlDepth => Get.find<DepthService>().pageCtrlDepth.toString();
String get searchPageCtrlDepth =>
    Get.find<DepthService>().searchPageCtrlDepth.toString();

class DepthService extends GetxService {
  /// [pageCtrlDepth] 画廊页面的路由深度
  /// 用作控制器的唯一标识
  /// 画廊页会在路由中同时存在多个但是不会平行
  /// 所以使用该变量可获取当前深度的控制器实例
  int pageCtrlDepth = 0;

  // 路由入栈时 深度+1
  void pushPageCtrl() {
    pageCtrlDepth++;
    // logger.d('pushPageCtrl to $pageCtrlDepth');
  }

  // 出栈 深度-1 放在onClose事件中
  void popPageCtrl() {
    pageCtrlDepth--;
    // logger.d('popPageCtrl to $pageCtrlDepth');
  }

  /// [searchPageCtrlDepth] 搜索页深度
  /// 作为控制器唯一标识
  int searchPageCtrlDepth = 0;

  void pushSearchPageCtrl() {
    searchPageCtrlDepth++;
  }

  void popSearchPageCtrl() {
    searchPageCtrlDepth--;
  }
}
