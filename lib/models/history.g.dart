// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

History _$HistoryFromJson(Map<String, dynamic> json) {
  return History()
    ..history = (json['history'] as List)
        ?.map((e) =>
            e == null ? null : GalleryItem.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$HistoryToJson(History instance) => <String, dynamic>{
      'history': instance.history,
    };
