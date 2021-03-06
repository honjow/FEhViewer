import 'package:fehviewer/common/controller/advance_search_controller.dart';
import 'package:fehviewer/models/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

const double kHeight = 220.0;
const double kAdvanceHeight = 500.0;

class GalleryFilterController extends GetxController {
  final TextEditingController statrPageCtrl = TextEditingController();
  final TextEditingController endPageCtrl = TextEditingController();

  final AdvanceSearchController _advanceSearchController = Get.find();

  @override
  void onInit() {
    super.onInit();

    statrPageCtrl.text = _advanceSearchController.advanceSearch.value.startPage;
    endPageCtrl.text = _advanceSearchController.advanceSearch.value.endPage;

    statrPageCtrl.addListener(() {
      _advanceSearchController.advanceSearch.update((AdvanceSearch val) {
        val.startPage = statrPageCtrl.text.trim();
      });
    });
    endPageCtrl.addListener(() {
      _advanceSearchController.advanceSearch.update((AdvanceSearch val) {
        val.endPage = endPageCtrl.text.trim();
      });
    });
  }
}
