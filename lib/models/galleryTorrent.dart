import 'package:json_annotation/json_annotation.dart';

part 'galleryTorrent.g.dart';

@JsonSerializable()
class GalleryTorrent {
  GalleryTorrent();

  String hash;
  String added;
  String name;
  String tsize;
  String fsize;

  factory GalleryTorrent.fromJson(Map<String, dynamic> json) =>
      _$GalleryTorrentFromJson(json);
  Map<String, dynamic> toJson() => _$GalleryTorrentToJson(this);
}
