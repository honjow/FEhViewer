// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'galleryTorrent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryTorrent _$GalleryTorrentFromJson(Map<String, dynamic> json) {
  return GalleryTorrent()
    ..hash = json['hash'] as String
    ..added = json['added'] as String
    ..name = json['name'] as String
    ..tsize = json['tsize'] as String
    ..fsize = json['fsize'] as String;
}

Map<String, dynamic> _$GalleryTorrentToJson(GalleryTorrent instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'added': instance.added,
      'name': instance.name,
      'tsize': instance.tsize,
      'fsize': instance.fsize,
    };
