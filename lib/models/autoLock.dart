import 'package:json_annotation/json_annotation.dart';

part 'autoLock.g.dart';

@JsonSerializable()
class AutoLock {
  AutoLock();

  int lastLeaveTime;
  bool isLocking;

  factory AutoLock.fromJson(Map<String, dynamic> json) =>
      _$AutoLockFromJson(json);
  Map<String, dynamic> toJson() => _$AutoLockToJson(this);
}
