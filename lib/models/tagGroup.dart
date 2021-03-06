import 'package:json_annotation/json_annotation.dart';

import 'galleryTag.dart';

part 'tagGroup.g.dart';

@JsonSerializable()
class TagGroup {
  TagGroup();

  String tagType;
  List<GalleryTag> galleryTags;

  factory TagGroup.fromJson(Map<String, dynamic> json) =>
      _$TagGroupFromJson(json);
  Map<String, dynamic> toJson() => _$TagGroupToJson(this);
}
