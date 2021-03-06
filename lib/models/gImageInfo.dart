import 'package:json_annotation/json_annotation.dart';

part 'gImageInfo.g.dart';

@JsonSerializable()
class GImageInfo {
  GImageInfo();

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

  factory GImageInfo.fromJson(Map<String, dynamic> json) =>
      _$GImageInfoFromJson(json);
  Map<String, dynamic> toJson() => _$GImageInfoToJson(this);
}
