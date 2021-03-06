// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloadTaskInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadTaskInfo _$DownloadTaskInfoFromJson(Map<String, dynamic> json) {
  return DownloadTaskInfo()
    ..tag = json['tag'] as String
    ..gid = json['gid'] as String
    ..type = json['type'] as String
    ..title = json['title'] as String
    ..taskId = json['taskId'] as String
    ..dowmloadType = json['dowmloadType'] as String
    ..status = json['status'] as int
    ..progress = json['progress'] as int;
}

Map<String, dynamic> _$DownloadTaskInfoToJson(DownloadTaskInfo instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'gid': instance.gid,
      'type': instance.type,
      'title': instance.title,
      'taskId': instance.taskId,
      'dowmloadType': instance.dowmloadType,
      'status': instance.status,
      'progress': instance.progress,
    };
