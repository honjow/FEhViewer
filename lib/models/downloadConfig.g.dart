// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloadConfig.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadConfig _$DownloadConfigFromJson(Map<String, dynamic> json) {
  return DownloadConfig()
    ..preloadImage = json['preloadImage'] as int
    ..multiDownload = json['multiDownload'] as int
    ..downloadLocatino = json['downloadLocatino'] as String
    ..downloadOrigImage = json['downloadOrigImage'] as bool;
}

Map<String, dynamic> _$DownloadConfigToJson(DownloadConfig instance) =>
    <String, dynamic>{
      'preloadImage': instance.preloadImage,
      'multiDownload': instance.multiDownload,
      'downloadLocatino': instance.downloadLocatino,
      'downloadOrigImage': instance.downloadOrigImage,
    };
