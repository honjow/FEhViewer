import 'package:json_annotation/json_annotation.dart';

part 'advanceSearch.g.dart';

@JsonSerializable()
class AdvanceSearch {
  AdvanceSearch();

  bool searchGalleryName;
  bool searchGalleryTags;
  bool searchGalleryDesc;
  bool searchToreenFilenames;
  bool onlyShowWhithTorrents;
  bool searchLowPowerTags;
  bool searchDownvotedTags;
  bool searchExpunged;
  bool searchWithminRating;
  int minRating;
  bool searchBetweenpage;
  String startPage;
  String endPage;
  bool disableDFLanguage;
  bool disableDFUploader;
  bool disableDFTags;
  bool favSearchName;
  bool favSearchTags;
  bool favSearchNote;

  factory AdvanceSearch.fromJson(Map<String, dynamic> json) =>
      _$AdvanceSearchFromJson(json);
  Map<String, dynamic> toJson() => _$AdvanceSearchToJson(this);
}
