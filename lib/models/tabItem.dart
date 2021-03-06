import 'package:json_annotation/json_annotation.dart';

part 'tabItem.g.dart';

@JsonSerializable()
class TabItem {
  TabItem();

  String name;
  bool enable;

  factory TabItem.fromJson(Map<String, dynamic> json) =>
      _$TabItemFromJson(json);
  Map<String, dynamic> toJson() => _$TabItemToJson(this);
}
