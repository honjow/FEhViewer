// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'galleryCommentSpan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryCommentSpan _$GalleryCommentSpanFromJson(Map<String, dynamic> json) {
  return GalleryCommentSpan()
    ..type = json['type'] as String
    ..style = json['style'] as String
    ..text = json['text'] as String
    ..href = json['href'] as String
    ..imageUrl = json['imageUrl'] as String;
}

Map<String, dynamic> _$GalleryCommentSpanToJson(GalleryCommentSpan instance) =>
    <String, dynamic>{
      'type': instance.type,
      'style': instance.style,
      'text': instance.text,
      'href': instance.href,
      'imageUrl': instance.imageUrl,
    };
