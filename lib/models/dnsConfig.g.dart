// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dnsConfig.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DnsConfig _$DnsConfigFromJson(Map<String, dynamic> json) {
  return DnsConfig()
    ..enableDoH = json['enableDoH'] as bool
    ..enableCustomHosts = json['enableCustomHosts'] as bool
    ..enableDomainFronting = json['enableDomainFronting'] as bool
    ..hosts = (json['hosts'] as List)
        ?.map((e) =>
            e == null ? null : DnsCache.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..dohCache = (json['dohCache'] as List)
        ?.map((e) =>
            e == null ? null : DnsCache.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$DnsConfigToJson(DnsConfig instance) => <String, dynamic>{
      'enableDoH': instance.enableDoH,
      'enableCustomHosts': instance.enableCustomHosts,
      'enableDomainFronting': instance.enableDomainFronting,
      'hosts': instance.hosts,
      'dohCache': instance.dohCache,
    };
