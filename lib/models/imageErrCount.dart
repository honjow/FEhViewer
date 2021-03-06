import 'package:json_annotation/json_annotation.dart';

part 'imageErrCount.g.dart';

@JsonSerializable()
class ImageErrCount {
  ImageErrCount();

  int ser;
  int errCount;

  factory ImageErrCount.fromJson(Map<String, dynamic> json) =>
      _$ImageErrCountFromJson(json);
  Map<String, dynamic> toJson() => _$ImageErrCountToJson(this);
}
