// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tabItem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TabItem _$TabItemFromJson(Map<String, dynamic> json) {
  return TabItem()
    ..name = json['name'] as String
    ..enable = json['enable'] as bool;
}

Map<String, dynamic> _$TabItemToJson(TabItem instance) => <String, dynamic>{
      'name': instance.name,
      'enable': instance.enable,
    };
