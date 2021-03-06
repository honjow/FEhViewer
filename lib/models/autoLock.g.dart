// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autoLock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AutoLock _$AutoLockFromJson(Map<String, dynamic> json) {
  return AutoLock()
    ..lastLeaveTime = json['lastLeaveTime'] as int
    ..isLocking = json['isLocking'] as bool;
}

Map<String, dynamic> _$AutoLockToJson(AutoLock instance) => <String, dynamic>{
      'lastLeaveTime': instance.lastLeaveTime,
      'isLocking': instance.isLocking,
    };
