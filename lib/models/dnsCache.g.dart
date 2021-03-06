// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dnsCache.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DnsCache _$DnsCacheFromJson(Map<String, dynamic> json) {
  return DnsCache()
    ..host = json['host'] as String
    ..lastResolve = json['lastResolve'] as int
    ..ttl = json['ttl'] as int
    ..addrs = (json['addrs'] as List)?.map((e) => e as String)?.toList()
    ..addr = json['addr'] as String;
}

Map<String, dynamic> _$DnsCacheToJson(DnsCache instance) => <String, dynamic>{
      'host': instance.host,
      'lastResolve': instance.lastResolve,
      'ttl': instance.ttl,
      'addrs': instance.addrs,
      'addr': instance.addr,
    };
