// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tabConfig.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TabConfig _$TabConfigFromJson(Map<String, dynamic> json) {
  return TabConfig()
    ..tabItemList = (json['tabItemList'] as List)
        ?.map((e) =>
            e == null ? null : TabItem.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$TabConfigToJson(TabConfig instance) => <String, dynamic>{
      'tabItemList': instance.tabItemList,
    };
