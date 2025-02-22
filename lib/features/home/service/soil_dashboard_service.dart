import 'package:soiltrack_mobile/core/config/supabase_config.dart';

class SoilDashboardService {
  Future<List<Map<String, dynamic>>> userPlots(String userId) async {
    try {
      final userPlots = await supabase.from('user_plots').select('''
        plot_id,
        plot_name,
        soil_type,
        user_crop_id,
        date_added,
        user_crops (
            crop_name,
            category,
            moisture_min,
            moisture_max,
            nitrogen_min,
            nitrogen_max,
            phosphorus_min,
            phosphorus_max,
            potassium_min,
            potassium_max
        ),
        soil_moisture_sensor_id,
        soil_moisture_sensors (
            soil_moisture_sensor_id,
            soil_moisture_name,
            soil_moisture_status,
            is_assigned
        ),
        soil_nutrient_sensor_id,
        soil_nutrient_sensors (
            soil_nutrient_sensor_id,
            soil_nutrient_name,
            soil_nutrient_status,
            is_assigned
        )
    ''').eq('user_id', userId).order('date_added', ascending: true);

      return userPlots;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> userPlotData(List<String> plotIds) async {
    try {
      final userPlotsData =
          await supabase.from('soil_moisture_readings').select('''
        plot_id,
        soil_moisture_sensor_id,
        soil_moisture,
        read_time
    ''').inFilter('plot_id', plotIds).order('read_time', ascending: false);

      return userPlotsData;
    } catch (e) {
      rethrow;
    }
  }
}
