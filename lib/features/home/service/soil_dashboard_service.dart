// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';

class SoilDashboardService {
  Future<List<Map<String, dynamic>>> userPlots(String userId) async {
    final now = DateTime.now();
    final todayStart =
        DateTime(now.year, now.month, now.day).toUtc().toIso8601String();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59)
        .toUtc()
        .toIso8601String();

    try {
      final userPlots = await supabase.from('user_plots').select('''
        plot_id,
        plot_name,
        soil_type,
        date_added,
        valve_tagging,
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

      final List<int> plotIds =
          userPlots.map<int>((plot) => plot['plot_id'] as int).toList();

      final irrigationLogs = await supabase
          .from('irrigation_log')
          .select('''
            irrigation_log_id,
            mac_address,
            time_started,
            time_stopped,
            plot_id
          ''')
          .inFilter('plot_id', plotIds)
          .gte('time_started', todayStart)
          .lt('time_started', todayEnd);

      print('Irrigation Logs: $irrigationLogs');

      final updatedPlots = userPlots.map((plot) {
        final plotId = plot['plot_id'];

        final plotLogs =
            irrigationLogs.where((log) => log['plot_id'] == plotId).toList();

        return {
          ...plot,
          'irrigation_log': plotLogs,
        };
      }).toList();

      print('Updated User Plots: $updatedPlots');
      return updatedPlots;
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
    ''').inFilter('plot_id', plotIds).order('read_time', ascending: true);

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

  List<Map<String, dynamic>> generateNutrientWarnings(
      List<Map<String, dynamic>> userPlots,
      List<Map<String, dynamic>> moistureData,
      List<Map<String, dynamic>> nutrientData) {
    List<Map<String, dynamic>> warningsList = [];

    for (var plot in userPlots) {
      final plotId = plot['plot_id'];
      final plotName = plot['plot_name'];
      final crop = plot['user_crops'];

      List<Map<String, String>> plotMessages = [];

      if (crop == null) {
        plotMessages.add({
          'type': 'Device Warning',
          'message': '• No crop assigned',
        });
      } else {
        final moistureMin = crop['moisture_min'];
        final moistureMax = crop['moisture_max'];
        final nitrogenMin = crop['nitrogen_min'];
        final nitrogenMax = crop['nitrogen_max'];
        final phosphorusMin = crop['phosphorus_min'];
        final phosphorusMax = crop['phosphorus_max'];
        final potassiumMin = crop['potassium_min'];
        final potassiumMax = crop['potassium_max'];

        var recentMoisture = moistureData
            .where((reading) => reading['plot_id'] == plotId)
            .toList()
            .lastOrNull;

        if (recentMoisture != null) {
          int moisture = recentMoisture['soil_moisture'];

          if (moisture < moistureMin) {
            plotMessages.add({
              "type": "Warning",
              "message": "• Soil moisture is too low ($moisture%)"
            });
            plotMessages.add({
              "type": "Suggestion",
              "message":
                  "What to do: Water the soil more often and use rice husks or mulch to keep moisture."
            });
          } else if (moisture > moistureMax) {
            plotMessages.add({
              "type": "Warning",
              "message": "• Soil moisture is too high ($moisture%)"
            });
            plotMessages.add({
              "type": "Suggestion",
              "message": "What to do: Make sure water can drain properly."
            });
          }
        }

        var recentReading = nutrientData
            .where((reading) => reading['plot_id'] == plotId)
            .toList()
            .lastOrNull;

        if (recentReading != null) {
          int nitrogen = recentReading['readed_nitrogen'];
          int phosphorus = recentReading['readed_phosphorus'];
          int potassium = recentReading['readed_potassium'];

          if (nitrogen < nitrogenMin) {
            plotMessages.add({
              "type": "Warning",
              "message": "• Nitrogen is too low ($nitrogen mg/L)"
            });
            plotMessages.add({
              "type": "Suggestion",
              "message":
                  "What to do: Apply fertilizers like compost, vermicast, or urea to improve soil health."
            });
          } else if (nitrogen > nitrogenMax) {
            plotMessages.add({
              "type": "Warning",
              "message": "• Nitrogen is too high ($nitrogen mg/L)"
            });
            plotMessages.add({
              "type": "Suggestion",
              "message":
                  "What to do: Use less nitrogen fertilizer and grow crops like corn or mung beans to absorb excess nitrogen."
            });
          }

          if (phosphorus < phosphorusMin) {
            plotMessages.add({
              "type": "Warning",
              "message": "Phosphorus is too low ($phosphorus mg/L)"
            });
            plotMessages.add({
              "type": "Suggestion",
              "message":
                  "What to do: Add phosphorus-rich fertilizers like bone meal, rock phosphate, or chicken manure."
            });
          } else if (phosphorus > phosphorusMax) {
            plotMessages.add({
              "type": "Warning",
              "message": "Phosphorus is too high ($phosphorus mg/L)"
            });
            plotMessages.add({
              "type": "Suggestion",
              "message":
                  "What to do: Use less phosphorus fertilizer and mix compost into the soil for better balance."
            });
          }

          if (potassium < potassiumMin) {
            plotMessages.add({
              "type": "Warning",
              "message": "• Potassium is too low ($potassium mg/L)"
            });
            plotMessages.add({
              "type": "Suggestion",
              "message":
                  "What to do: Use potassium fertilizers like wood ash, banana peel compost, or potassium sulfate."
            });
          } else if (potassium > potassiumMax) {
            plotMessages.add({
              "type": "Warning",
              "message": "• Potassium is too high ($potassium mg/L)"
            });
            plotMessages.add({
              "type": "Suggestion",
              "message":
                  "What to do: Water the soil more often to help wash out excess potassium."
            });
          }
        }
      }

      if (plot['soil_type'] == null ||
          plot['soil_type'].toString().trim().isEmpty) {
        plotMessages.add({
          'type': 'Device Warning',
          'message':
              '• No soil type assigned, assign a soil type to get better recommendations',
        });
      }

      if (plot['user_plot_sensors'] == null ||
          plot['user_plot_sensors'].isEmpty) {
        plotMessages.add({
          'type': 'Device Warning',
          'message':
              '• No moisture sensor found or connected, readings will be unavailable',
        });
        plotMessages.add({
          'type': 'Device Warning',
          'message':
              '• No nutrient sensor found or connected, readings will be unavailable',
        });
      }

      // Add to warnings list if there are messages
      if (plotMessages.isNotEmpty) {
        warningsList.add({
          'plot_id': plotId,
          'plot_name': plotName,
          'messages': plotMessages,
        });
      }
    }

    return warningsList;
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
      await supabase
          .from('user_crops')
          .update(updatedValues)
          .eq('plot_id', selectedPlotId);
    } catch (e) {
      print('Error updating threshold: $e');
      rethrow;
    }
  }

  Future<String> getMacAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mac_address') ?? '';
  }
}
