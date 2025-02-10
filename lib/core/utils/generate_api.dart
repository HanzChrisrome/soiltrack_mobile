import 'dart:convert';
import 'dart:math';

import 'package:soiltrack_mobile/core/config/supabase_config.dart';

class ApiKeyGenerator {
  Future<String> generate() async {
    String apiKey;
    Map<String, dynamic>? response;

    do {
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(256));
      apiKey = base64Url.encode(values);

      response = await supabase
          .from('iot_device')
          .select('device_id')
          .eq('api_key', apiKey)
          .maybeSingle();
    } while (response != null);

    return apiKey;
  }
}
