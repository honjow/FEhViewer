// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'galleryTag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryTag _$GalleryTagFromJson(Map<String, dynamic> json) {
  return GalleryTag()
    ..title = json['title'] as String
    ..type = json['type'] as String
    ..tagTranslat = json['tagTranslat'] as String
    ..intro = json['intro'] as String
    ..vote = json['vote'] as int;
}

Map<String, dynamic> _$GalleryTagToJson(GalleryTag instance) =>
    <String, dynamic>{
      'title': instance.title,
      'type': instance.type,
      'tagTranslat': instance.tagTranslat,
      'intro': instance.intro,
      'vote': instance.vote,
    };
