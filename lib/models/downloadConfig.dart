import 'package:json_annotation/json_annotation.dart';

part 'downloadConfig.g.dart';

@JsonSerializable()
class DownloadConfig {
  DownloadConfig();

  int preloadImage;
  int multiDownload;
  String downloadLocatino;
  bool downloadOrigImage;

  factory DownloadConfig.fromJson(Map<String, dynamic> json) =>
      _$DownloadConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadConfigToJson(this);
}
