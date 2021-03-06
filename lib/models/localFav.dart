import 'package:json_annotation/json_annotation.dart';

import 'galleryItem.dart';

part 'localFav.g.dart';

@JsonSerializable()
class LocalFav {
  LocalFav();

  List<GalleryItem> gallerys;

  factory LocalFav.fromJson(Map<String, dynamic> json) =>
      _$LocalFavFromJson(json);
  Map<String, dynamic> toJson() => _$LocalFavToJson(this);
}
