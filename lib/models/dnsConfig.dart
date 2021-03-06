import 'package:json_annotation/json_annotation.dart';

import 'dnsCache.dart';

part 'dnsConfig.g.dart';

@JsonSerializable()
class DnsConfig {
  DnsConfig();

  bool enableDoH;
  bool enableCustomHosts;
  bool enableDomainFronting;
  List<DnsCache> hosts;
  List<DnsCache> dohCache;

  factory DnsConfig.fromJson(Map<String, dynamic> json) =>
      _$DnsConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DnsConfigToJson(this);
}
