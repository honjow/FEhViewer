import 'package:json_annotation/json_annotation.dart';

part 'galleryTag.g.dart';

@JsonSerializable()
class GalleryTag {
  GalleryTag();

  String title;
  String type;
  String tagTranslat;
  String intro;
  int vote;

  factory GalleryTag.fromJson(Map<String, dynamic> json) =>
      _$GalleryTagFromJson(json);
  Map<String, dynamic> toJson() => _$GalleryTagToJson(this);
}
