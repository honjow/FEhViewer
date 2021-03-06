// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanceSearch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdvanceSearch _$AdvanceSearchFromJson(Map<String, dynamic> json) {
  return AdvanceSearch()
    ..searchGalleryName = json['searchGalleryName'] as bool
    ..searchGalleryTags = json['searchGalleryTags'] as bool
    ..searchGalleryDesc = json['searchGalleryDesc'] as bool
    ..searchToreenFilenames = json['searchToreenFilenames'] as bool
    ..onlyShowWhithTorrents = json['onlyShowWhithTorrents'] as bool
    ..searchLowPowerTags = json['searchLowPowerTags'] as bool
    ..searchDownvotedTags = json['searchDownvotedTags'] as bool
    ..searchExpunged = json['searchExpunged'] as bool
    ..searchWithminRating = json['searchWithminRating'] as bool
    ..minRating = json['minRating'] as int
    ..searchBetweenpage = json['searchBetweenpage'] as bool
    ..startPage = json['startPage'] as String
    ..endPage = json['endPage'] as String
    ..disableDFLanguage = json['disableDFLanguage'] as bool
    ..disableDFUploader = json['disableDFUploader'] as bool
    ..disableDFTags = json['disableDFTags'] as bool
    ..favSearchName = json['favSearchName'] as bool
    ..favSearchTags = json['favSearchTags'] as bool
    ..favSearchNote = json['favSearchNote'] as bool;
}

Map<String, dynamic> _$AdvanceSearchToJson(AdvanceSearch instance) =>
    <String, dynamic>{
      'searchGalleryName': instance.searchGalleryName,
      'searchGalleryTags': instance.searchGalleryTags,
      'searchGalleryDesc': instance.searchGalleryDesc,
      'searchToreenFilenames': instance.searchToreenFilenames,
      'onlyShowWhithTorrents': instance.onlyShowWhithTorrents,
      'searchLowPowerTags': instance.searchLowPowerTags,
      'searchDownvotedTags': instance.searchDownvotedTags,
      'searchExpunged': instance.searchExpunged,
      'searchWithminRating': instance.searchWithminRating,
      'minRating': instance.minRating,
      'searchBetweenpage': instance.searchBetweenpage,
      'startPage': instance.startPage,
      'endPage': instance.endPage,
      'disableDFLanguage': instance.disableDFLanguage,
      'disableDFUploader': instance.disableDFUploader,
      'disableDFTags': instance.disableDFTags,
      'favSearchName': instance.favSearchName,
      'favSearchTags': instance.favSearchTags,
      'favSearchNote': instance.favSearchNote,
    };
