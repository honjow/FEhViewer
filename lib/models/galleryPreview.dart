import 'package:json_annotation/json_annotation.dart';

part 'galleryPreview.g.dart';

@JsonSerializable()
class GalleryPreview {
  GalleryPreview();

  bool isLarge;
  bool isCache;
  bool startPrecache;
  int ser;
  String href;
  String largeImageUrl;
  String imgUrl;
  double height;
  double width;
  double largeImageHeight;
  double largeImageWidth;
  double offSet;
  String sourceId;

  factory GalleryPreview.fromJson(Map<String, dynamic> json) =>
      _$GalleryPreviewFromJson(json);
  Map<String, dynamic> toJson() => _$GalleryPreviewToJson(this);
}
