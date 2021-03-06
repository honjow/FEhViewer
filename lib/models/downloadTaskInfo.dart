import 'package:json_annotation/json_annotation.dart';

part 'downloadTaskInfo.g.dart';

@JsonSerializable()
class DownloadTaskInfo {
  DownloadTaskInfo();

  String tag;
  String gid;
  String type;
  String title;
  String taskId;
  String dowmloadType;
  int status;
  int progress;

  factory DownloadTaskInfo.fromJson(Map<String, dynamic> json) =>
      _$DownloadTaskInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadTaskInfoToJson(this);
}
