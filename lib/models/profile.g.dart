// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return Profile()
    ..user = json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>)
    ..cache = json['cache'] == null
        ? null
        : CacheConfig.fromJson(json['cache'] as Map<String, dynamic>)
    ..ehConfig = json['ehConfig'] == null
        ? null
        : EhConfig.fromJson(json['ehConfig'] as Map<String, dynamic>)
    ..lastLogin = json['lastLogin'] as String
    ..locale = json['locale'] as String
    ..theme = json['theme'] as String
    ..searchText =
        (json['searchText'] as List)?.map((e) => e as String)?.toList()
    ..history = (json['history'] as List)
        ?.map((e) =>
            e == null ? null : GalleryItem.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..localFav = json['localFav'] == null
        ? null
        : LocalFav.fromJson(json['localFav'] as Map<String, dynamic>)
    ..enableAdvanceSearch = json['enableAdvanceSearch'] as bool
    ..advanceSearch = json['advanceSearch'] == null
        ? null
        : AdvanceSearch.fromJson(json['advanceSearch'] as Map<String, dynamic>)
    ..dnsConfig = json['dnsConfig'] == null
        ? null
        : DnsConfig.fromJson(json['dnsConfig'] as Map<String, dynamic>)
    ..downloadConfig = json['downloadConfig'] == null
        ? null
        : DownloadConfig.fromJson(
            json['downloadConfig'] as Map<String, dynamic>)
    ..autoLock = json['autoLock'] == null
        ? null
        : AutoLock.fromJson(json['autoLock'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'user': instance.user,
      'cache': instance.cache,
      'ehConfig': instance.ehConfig,
      'lastLogin': instance.lastLogin,
      'locale': instance.locale,
      'theme': instance.theme,
      'searchText': instance.searchText,
      'history': instance.history,
      'localFav': instance.localFav,
      'enableAdvanceSearch': instance.enableAdvanceSearch,
      'advanceSearch': instance.advanceSearch,
      'dnsConfig': instance.dnsConfig,
      'downloadConfig': instance.downloadConfig,
      'autoLock': instance.autoLock,
    };
