// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'galleryPreview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryPreview _$GalleryPreviewFromJson(Map<String, dynamic> json) {
  return GalleryPreview()
    ..isLarge = json['isLarge'] as bool
    ..isCache = json['isCache'] as bool
    ..startPrecache = json['startPrecache'] as bool
    ..ser = json['ser'] as int
    ..href = json['href'] as String
    ..largeImageUrl = json['largeImageUrl'] as String
    ..imgUrl = json['imgUrl'] as String
    ..height = (json['height'] as num)?.toDouble()
    ..width = (json['width'] as num)?.toDouble()
    ..largeImageHeight = (json['largeImageHeight'] as num)?.toDouble()
    ..largeImageWidth = (json['largeImageWidth'] as num)?.toDouble()
    ..offSet = (json['offSet'] as num)?.toDouble()
    ..sourceId = json['sourceId'] as String;
}

Map<String, dynamic> _$GalleryPreviewToJson(GalleryPreview instance) =>
    <String, dynamic>{
      'isLarge': instance.isLarge,
      'isCache': instance.isCache,
      'startPrecache': instance.startPrecache,
      'ser': instance.ser,
      'href': instance.href,
      'largeImageUrl': instance.largeImageUrl,
      'imgUrl': instance.imgUrl,
      'height': instance.height,
      'width': instance.width,
      'largeImageHeight': instance.largeImageHeight,
      'largeImageWidth': instance.largeImageWidth,
      'offSet': instance.offSet,
      'sourceId': instance.sourceId,
    };
