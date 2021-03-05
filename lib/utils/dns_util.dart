import 'package:basic_utils/basic_utils.dart';

class DnsUtil {
  static Future<String> doh(String host,
      {DnsApiProvider dhoResolve = DnsApiProvider.CLOUDFLARE}) async {
    final List<RRecord> response =
        await DnsUtils.reverseDns(host, provider: dhoResolve);
    return (response..shuffle()).first.data;
  }
}
