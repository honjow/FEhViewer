import 'package:json_annotation/json_annotation.dart';

part 'ehConfig.g.dart';

@JsonSerializable()
class EhConfig {
  EhConfig();

  bool jpnTitle;
  bool tagTranslat;
  String tagTranslatVer;
  String favoritesOrder;
  bool siteEx;
  bool galleryImgBlur;
  bool favPicker;
  bool favLongTap;
  String lastFavcat;
  String lastShowFavcat;
  String lastShowFavTitle;
  String listMode;
  bool safeMode;
  int catFilter;
  int maxHistory;
  bool searchBarComp;
  bool pureDarkTheme;
  String viewModel;
  bool clipboardLink;
  bool commentTrans;
  int autoLockTimeOut;
  bool showPageInterval;
  String orientation;

  factory EhConfig.fromJson(Map<String, dynamic> json) =>
      _$EhConfigFromJson(json);
  Map<String, dynamic> toJson() => _$EhConfigToJson(this);
}
