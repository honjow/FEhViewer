import 'package:json_annotation/json_annotation.dart';

part 'dnsCache.g.dart';

@JsonSerializable()
class DnsCache {
  DnsCache();

  String host;
  int lastResolve;
  int ttl;
  List<String> addrs;
  String addr;

  factory DnsCache.fromJson(Map<String, dynamic> json) =>
      _$DnsCacheFromJson(json);
  Map<String, dynamic> toJson() => _$DnsCacheToJson(this);
}
