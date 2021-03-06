import 'package:json_annotation/json_annotation.dart';

import 'galleryCommentSpan.dart';

part 'galleryComment.g.dart';

@JsonSerializable()
class GalleryComment {
  GalleryComment();

  String name;
  String time;
  List<GalleryCommentSpan> span;
  String score;
  int vote;
  String id;
  bool canEdit;
  bool canVote;

  factory GalleryComment.fromJson(Map<String, dynamic> json) =>
      _$GalleryCommentFromJson(json);
  Map<String, dynamic> toJson() => _$GalleryCommentToJson(this);
}
