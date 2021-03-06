import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';

enum EditState {
  newComment,
  editComment,
}

class CommentController extends GetxController
    with StateMixin<List<GalleryComment>>, WidgetsBindingObserver {
  CommentController();

  GalleryPageController get pageController => Get.find(tag: pageCtrlDepth);
  final TextEditingController commentTextController = TextEditingController();

  GalleryItem get _item => pageController.galleryItem;
  String comment;
  String oriComment;
  String commentId;
  FocusNode focusNode = FocusNode();
  ScrollController scrollController = ScrollController();

  final WidgetsBinding _widgetsBinding = WidgetsBinding.instance;
  double _preBottomInset = 0;
  double _bottomInset = 0;
  bool _didChangeMetrics = false;

  final Rx<EditState> _editState = EditState.newComment.obs;
  EditState get editState => _editState.value;
  set editState(EditState val) => _editState.value = val;

  bool get isEditStat => _editState.value == EditState.editComment;

  @override
  void onInit() {
    super.onInit();
    // logger.d('CommentController onInit');

    _loadComment();

    _bottomInset = _mediaQueryBottomInset();
    _preBottomInset = _bottomInset;
    _widgetsBinding.addObserver(this);
  }

  Future<void> _loadComment() async {
    await Future.delayed(const Duration(milliseconds: 200));
    change(pageController.galleryItem.galleryComment,
        status: RxStatus.success());
  }

  @override
  void didChangeMetrics() {
    _didChangeMetrics = true;
    super.didChangeMetrics();
    _widgetsBinding.addPostFrameCallback((Duration timeStamp) {
      _bottomInset = _mediaQueryBottomInset();
      if (_preBottomInset != _bottomInset) {
        final double _offset = _bottomInset - _preBottomInset;
        _preBottomInset = _bottomInset;
      }
    });
  }

  @override
  void onClose() {
    _tgr.forEach((element) => element.dispose());
    scrollController.dispose();
    _widgetsBinding.removeObserver(this);
    super.onClose();
  }

  final List<TapGestureRecognizer> _tgr = [];
  TapGestureRecognizer genTapGestureRecognizer() {
    _tgr.add(TapGestureRecognizer());
    return _tgr.last;
  }

  double _mediaQueryBottomInset() {
    return MediaQueryData.fromWindow(_widgetsBinding.window).viewInsets.bottom;
  }

  Future<void> commitVoteUp(String _id) async {
    logger.d('commit up id $_id');
    state.firstWhere((element) => element.id == _id.toString()).vote = 1;
    update(['$_id']);
    final CommitVoteRes rult = await Api.commitVote(
      apikey: _item.apikey,
      apiuid: _item.apiuid,
      gid: _item.gid,
      token: _item.token,
      commentId: _id,
      vote: 1,
    );
    _paraRes(rult);
    if (rult.commentVote != 0) {
      showToast(S.of(Get.context).vote_up_successfully);
    }
  }

  Future<void> commitVoteDown(String _id) async {
    logger.d('commit down id $_id');
    state.firstWhere((element) => element.id == _id.toString()).vote = -1;
    update(['$_id']);
    final CommitVoteRes rult = await Api.commitVote(
      apikey: _item.apikey,
      apiuid: _item.apiuid,
      gid: _item.gid,
      token: _item.token,
      commentId: _id,
      vote: -1,
    );
    _paraRes(rult);
    if (rult.commentVote != 0) {
      showToast(S.of(Get.context).vote_down_successfully);
    }
  }

  void _paraRes(CommitVoteRes rult) {
    logger.d('${rult.toJson()}');
    state.firstWhere((element) => element.id == rult.commentId.toString())
      ..vote = rult.commentVote
      ..score = '${rult.commentScore}';
    update(['${rult.commentId}']);
  }

  Future<void> _postComment(String comment,
      {bool isEdit = false, String commentId}) async {
    final bool rult = await Api.postComment(
      gid: pageController.gid,
      token: pageController.galleryItem.token,
      comment: comment,
      commentId: commentId,
      isEdit: isEdit,
    );

    if (rult) {
      await pageController.handOnRefresh();
    }
  }

  Future<void> pressSend() async {
    comment = commentTextController.text;
    logger.d('comment: $comment');
    FocusScope.of(Get.context).requestFocus(FocusNode());

    showLoadingDialog(Get.context, () async {
      await _postComment(
        comment,
        isEdit: editState == EditState.editComment,
        commentId: commentId,
      );
      pressCancle();
    });
  }

  void pressCancle() {
    oriComment = '';
    commentTextController.clear();
    editState = EditState.newComment;
    // FocusScope.of(Get.context).requestFocus(FocusNode());
  }

  void editComment({String id, String oriComment}) {
    comment = oriComment;
    commentId = id;
    this.oriComment = oriComment;
    commentTextController.value = TextEditingValue(
      text: comment,
      selection: TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream, offset: comment.length)),
    );
    editState = EditState.editComment;
    FocusScope.of(Get.context).requestFocus(focusNode);
    // _scrollToBottom();
  }

  // 滚动到列表底部
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 400), () {
      logger.d('${scrollController.position.maxScrollExtent}');
      // scrollController.jumpTo(scrollController.position.maxScrollExtent);
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 400),
        curve: Curves.linear,
      );
    });
  }

  void _scrollView() {
    _bottomInset = _mediaQueryBottomInset();
    if (_preBottomInset != _bottomInset) {
      final double _offset = _bottomInset - _preBottomInset;
      _preBottomInset = _bottomInset;
      logger.d(' ${_bottomInset} $_offset  ${scrollController.offset}');

      final double _viewHeigth = Get.context.height -
          Get.context.mediaQueryViewPadding.top -
          Get.context.mediaQueryViewPadding.bottom -
          60 -
          44;

      logger.d('_viewHeigth $_viewHeigth,  ${Get.context.height} '
          ' ${Get.context.mediaQueryViewPadding.top}  '
          '${Get.context.mediaQueryViewPadding.bottom}');

      if (scrollController.position.maxScrollExtent > _viewHeigth) {
        if (scrollController.offset > _bottomInset && _offset < 0) {
          scrollController.animateTo(
            scrollController.offset + _offset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        } else if (_offset > 0) {
          scrollController.animateTo(
            scrollController.offset + _offset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        }
      } else {
        final double _o =
            _viewHeigth - scrollController.position.maxScrollExtent;
        logger.d('_o $_o');
      }
    }
  }
}

/// 显示等待
Future<void> showLoadingDialog(BuildContext context, Function function) async {
  return showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) {
      Future<void>.delayed(const Duration(milliseconds: 0))
          .then((_) => function())
          .whenComplete(() => Get.back());

      return Center(
        child: CupertinoPopupSurface(
          child: Container(
              height: 80,
              width: 80,
              alignment: Alignment.center,
              child: const CupertinoActivityIndicator(
                radius: 20,
              )),
        ),
      );
    },
  );
}
