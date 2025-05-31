import 'package:soiltrack_mobile/core/config/supabase_config.dart';

class DeviceService {
  Future<Map<String, dynamic>?> getUserDevice(String userId) async {
    return await supabase
        .from('iot_device')
        .select('mac_address')
        .eq('user_id', userId)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> getDeviceByMac(String macAddress) async {
    return await supabase
        .from('iot_device')
        .select()
        .eq('mac_address', macAddress)
        .maybeSingle();
  }
}
