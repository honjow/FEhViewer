// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ehConfig.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EhConfig _$EhConfigFromJson(Map<String, dynamic> json) {
  return EhConfig()
    ..jpnTitle = json['jpnTitle'] as bool
    ..tagTranslat = json['tagTranslat'] as bool
    ..tagTranslatVer = json['tagTranslatVer'] as String
    ..favoritesOrder = json['favoritesOrder'] as String
    ..siteEx = json['siteEx'] as bool
    ..galleryImgBlur = json['galleryImgBlur'] as bool
    ..favPicker = json['favPicker'] as bool
    ..favLongTap = json['favLongTap'] as bool
    ..lastFavcat = json['lastFavcat'] as String
    ..lastShowFavcat = json['lastShowFavcat'] as String
    ..lastShowFavTitle = json['lastShowFavTitle'] as String
    ..listMode = json['listMode'] as String
    ..safeMode = json['safeMode'] as bool
    ..catFilter = json['catFilter'] as int
    ..maxHistory = json['maxHistory'] as int
    ..searchBarComp = json['searchBarComp'] as bool
    ..pureDarkTheme = json['pureDarkTheme'] as bool
    ..viewModel = json['viewModel'] as String
    ..clipboardLink = json['clipboardLink'] as bool
    ..commentTrans = json['commentTrans'] as bool
    ..autoLockTimeOut = json['autoLockTimeOut'] as int
    ..showPageInterval = json['showPageInterval'] as bool
    ..orientation = json['orientation'] as String;
}

Map<String, dynamic> _$EhConfigToJson(EhConfig instance) => <String, dynamic>{
      'jpnTitle': instance.jpnTitle,
      'tagTranslat': instance.tagTranslat,
      'tagTranslatVer': instance.tagTranslatVer,
      'favoritesOrder': instance.favoritesOrder,
      'siteEx': instance.siteEx,
      'galleryImgBlur': instance.galleryImgBlur,
      'favPicker': instance.favPicker,
      'favLongTap': instance.favLongTap,
      'lastFavcat': instance.lastFavcat,
      'lastShowFavcat': instance.lastShowFavcat,
      'lastShowFavTitle': instance.lastShowFavTitle,
      'listMode': instance.listMode,
      'safeMode': instance.safeMode,
      'catFilter': instance.catFilter,
      'maxHistory': instance.maxHistory,
      'searchBarComp': instance.searchBarComp,
      'pureDarkTheme': instance.pureDarkTheme,
      'viewModel': instance.viewModel,
      'clipboardLink': instance.clipboardLink,
      'commentTrans': instance.commentTrans,
      'autoLockTimeOut': instance.autoLockTimeOut,
      'showPageInterval': instance.showPageInterval,
      'orientation': instance.orientation,
    };
