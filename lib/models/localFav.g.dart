// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localFav.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalFav _$LocalFavFromJson(Map<String, dynamic> json) {
  return LocalFav()
    ..gallerys = (json['gallerys'] as List)
        ?.map((e) =>
            e == null ? null : GalleryItem.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$LocalFavToJson(LocalFav instance) => <String, dynamic>{
      'gallerys': instance.gallerys,
    };
