import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:soiltrack_mobile/core/model/moisture_model.dart';

class ApiService {
  static const String baseUrl = "https://soiltrack-server.onrender.com";

  static Future<MoistureModel?> fetchMoistureData() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/moisture"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("Moisture data: $data");
        return MoistureModel.fromJson(data);
      } else {
        print("Failed to load moisture data: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching moisture data: $e");
      return null;
    }
  }
}
