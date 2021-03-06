import 'package:json_annotation/json_annotation.dart';

import 'tabItem.dart';

part 'tabConfig.g.dart';

@JsonSerializable()
class TabConfig {
  TabConfig();

  List<TabItem> tabItemList;

  factory TabConfig.fromJson(Map<String, dynamic> json) =>
      _$TabConfigFromJson(json);
  Map<String, dynamic> toJson() => _$TabConfigToJson(this);
}
