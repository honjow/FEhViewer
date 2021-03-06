// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tagGroup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagGroup _$TagGroupFromJson(Map<String, dynamic> json) {
  return TagGroup()
    ..tagType = json['tagType'] as String
    ..galleryTags = (json['galleryTags'] as List)
        ?.map((e) =>
            e == null ? null : GalleryTag.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$TagGroupToJson(TagGroup instance) => <String, dynamic>{
      'tagType': instance.tagType,
      'galleryTags': instance.galleryTags,
    };
