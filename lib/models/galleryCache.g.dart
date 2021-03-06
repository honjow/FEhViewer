// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'galleryCache.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryCache _$GalleryCacheFromJson(Map<String, dynamic> json) {
  return GalleryCache()
    ..gid = json['gid'] as String
    ..lastIndex = json['lastIndex'] as int
    ..lastOffset = (json['lastOffset'] as num)?.toDouble()
    ..columnModeVal = json['columnModeVal'] as String;
}

Map<String, dynamic> _$GalleryCacheToJson(GalleryCache instance) =>
    <String, dynamic>{
      'gid': instance.gid,
      'lastIndex': instance.lastIndex,
      'lastOffset': instance.lastOffset,
      'columnModeVal': instance.columnModeVal,
    };
