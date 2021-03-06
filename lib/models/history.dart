import 'package:json_annotation/json_annotation.dart';

import 'galleryItem.dart';

part 'history.g.dart';

@JsonSerializable()
class History {
  History();

  List<GalleryItem> history;

  factory History.fromJson(Map<String, dynamic> json) =>
      _$HistoryFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryToJson(this);
}
