// ignore_for_file: avoid_print

import 'package:soiltrack_mobile/core/config/supabase_config.dart';

class SoilDashboardService {
  Future<List<Map<String, dynamic>>> userPlots(String userId) async {
    try {
      final userPlots = await supabase.from('user_plots').select('''
        plot_id,
        plot_name,
        soil_type,
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
        user_plot_sensors (
            sensor_id,
            soil_sensors (
                sensor_name,
                sensor_status,
                sensor_type,
                sensor_category
            )
        )
    ''').eq('user_id', userId).order('date_added', ascending: true);

      return userPlots;
    } catch (e) {
      print('Error fetching user plots: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> userPlotMoistureData(
      List<String> plotIds) async {
    try {
      final userPlotsData = await supabase.from('moisture_readings').select('''
        plot_id,
        sensor_id,
        soil_moisture,
        read_time
    ''').inFilter('plot_id', plotIds).order('read_time', ascending: false);

      return userPlotsData;
    } catch (e) {
      print('Error fetching user plot data: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> userPlotNutrientData(
      List<String> plotIds) async {
    try {
      final userPlotsData = await supabase.from('nutrient_readings').select('''
        plot_id,
        sensor_id,
        read_time,
        readed_nitrogen,
        readed_phosphorus, 
        readed_potassium
    ''').inFilter('plot_id', plotIds).order('read_time', ascending: true);

      return userPlotsData;
    } catch (e) {
      print('Error fetching user plot nutrient data: $e');
      rethrow;
    }
  }

  Map<String, List<String>> generateNutrientWarnings(
      List<Map<String, dynamic>> userPlots,
      List<Map<String, dynamic>> nutrientData) {
    Map<String, List<String>> warningsByPlot = {};

    for (var plot in userPlots) {
      String plotId = plot['plot_id'].toString();
      var crop = plot['user_crops'];

      if (crop == null) continue;

      int nitrogenMin = crop['nitrogen_min'];
      int nitrogenMax = crop['nitrogen_max'];
      int phosphorusMin = crop['phosphorus_min'];
      int phosphorusMax = crop['phosphorus_max'];
      int potassiumMin = crop['potassium_min'];
      int potassiumMax = crop['potassium_max'];

      var recentReading = nutrientData
          .where((reading) => reading['plot_id'] == plot['plot_id'])
          .toList()
          .lastOrNull;

      if (recentReading == null) continue;

      int nitrogen = recentReading['readed_nitrogen'];
      int phosphorus = recentReading['readed_phosphorus'];
      int potassium = recentReading['readed_potassium'];

      List<String> warnings = [];

      if (nitrogen < nitrogenMin) {
        warnings.add("Nitrogen is too low ($nitrogen mg/L)");
      } else if (nitrogen > nitrogenMax) {
        warnings.add("Nitrogen is too high ($nitrogen mg/L)");
      }

      if (phosphorus < phosphorusMin) {
        warnings.add("Phosphorus is too low ($phosphorus mg/L)");
      } else if (phosphorus > phosphorusMax) {
        warnings.add("Phosphorus is too high ($phosphorus mg/L)");
      }

      if (potassium < potassiumMin) {
        warnings.add("Potassium is too low ($potassium mg/L)");
      } else if (potassium > potassiumMax) {
        warnings.add("Potassium is too high ($potassium mg/L)");
      }

      if (warnings.isNotEmpty) {
        warningsByPlot[plotId] = warnings;
      }
    }

    return warningsByPlot;
  }

  Future<void> cropId(String selectedCrop) async {
    try {
      final getCropId = await supabase
          .from('crops')
          .select('crop_id')
          .eq('crop_name', selectedCrop)
          .single();

      return getCropId['crop_id'];
    } catch (e) {
      print('Error saving new crop: $e');
      rethrow;
    }
  }

  Future<void> editPlotName(String newPlotName, int selectedPlotId) async {
    try {
      await supabase.from('user_plots').update({
        'plot_name': newPlotName,
      }).eq('plot_id', selectedPlotId);
    } catch (e) {
      print('Error updating plot name: $e');
      rethrow;
    }
  }

  Future<void> saveNewThreshold(
      int selectedPlotId, Map<String, int> updatedValues) async {
    try {
      final userCropId = await supabase
          .from('user_plots')
          .select('user_crop_id')
          .eq('plot_id', selectedPlotId)
          .single();

      await supabase
          .from('user_crops')
          .update(updatedValues)
          .eq('user_crop_id', userCropId['user_crop_id']);
    } catch (e) {
      print('Error updating threshold: $e');
      rethrow;
    }
  }
}
