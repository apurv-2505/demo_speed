import 'package:http/http.dart' as http;
import '../models/api_call.dart';

class SpeedService {
  static Future<double> checkInternetSpeed() async {
    final startTime = DateTime.now();
    final response = await http
        .get(
          Uri.parse('https://httpbin.org/bytes/102400'),
          headers: {'Cache-Control': 'no-cache'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final endTime = DateTime.now();
      final durationMs = endTime.difference(startTime).inMilliseconds;
      final bytes = response.bodyBytes.length;

      // Calculate speed in Mbps (bits per second)
      final speedMbps = (bytes * 8 / 1000000) / (durationMs / 1000);
      return speedMbps;
    }

    throw Exception('Speed test failed with status: ${response.statusCode}');
  }

  static double convertToMbps(double value, SpeedUnit unit) {
    return unit == SpeedUnit.kbps ? value / 1000 : value;
  }

  static double convertFromMbps(double mbpsValue, SpeedUnit unit) {
    return unit == SpeedUnit.kbps ? mbpsValue * 1000 : mbpsValue;
  }

  static String formatSpeed(double mbpsValue, SpeedUnit unit) {
    final converted = convertFromMbps(mbpsValue, unit);
    return '${converted.toStringAsFixed(unit == SpeedUnit.kbps ? 0 : 2)} ${unit.name}';
  }
}
