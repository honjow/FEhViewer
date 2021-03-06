import 'package:json_annotation/json_annotation.dart';

import 'galleryComment.dart';
import 'galleryPreview.dart';
import 'galleryTorrent.dart';
import 'simpleTag.dart';
import 'tagGroup.dart';

part 'galleryInfo.g.dart';

@JsonSerializable()
class GalleryInfo {
  GalleryInfo();

  String gid;
  String token;
  String showKey;
  String url;
  String imgUrl;
  String imgUrlL;
  double imgHeight;
  double imgWidth;
  String japaneseTitle;
  String englishTitle;
  String category;
  String uploader;
  String posted;
  String language;
  String filecount;
  double rating;
  String ratingCount;
  String torrentcount;
  List<GalleryTorrent> torrents;
  int filesize;
  String filesizeText;
  String visible;
  String parent;
  double ratingFallBack;
  String numberOfReviews;
  String postTime;
  String favoritedCount;
  String favTitle;
  String favcat;
  bool localFav;
  List<SimpleTag> simpleTags;
  List<String> tagsFromApi;
  String translated;
  List<TagGroup> tagGroup;
  List<GalleryComment> galleryComment;
  List<GalleryPreview> galleryPreview;
  String apikey;
  String apiuid;
  bool isRatinged;
  String colorRating;
  String archiverLink;
  String torrentLink;

  factory GalleryInfo.fromJson(Map<String, dynamic> json) =>
      _$GalleryInfoFromJson(json);
  Map<String, dynamic> toJson() => _$GalleryInfoToJson(this);
}
