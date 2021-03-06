import 'package:json_annotation/json_annotation.dart';

import 'advanceSearch.dart';
import 'autoLock.dart';
import 'cacheConfig.dart';
import 'dnsConfig.dart';
import 'downloadConfig.dart';
import 'ehConfig.dart';
import 'galleryItem.dart';
import 'localFav.dart';
import 'user.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  Profile();

  User user;
  CacheConfig cache;
  EhConfig ehConfig;
  String lastLogin;
  String locale;
  String theme;
  List<String> searchText;
  List<GalleryItem> history;
  LocalFav localFav;
  bool enableAdvanceSearch;
  AdvanceSearch advanceSearch;
  DnsConfig dnsConfig;
  DownloadConfig downloadConfig;
  AutoLock autoLock;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
