import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/plot_card.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:http/http.dart' as http;

class SoilDashboard extends StatelessWidget {
  const SoilDashboard({super.key});

  Future<void> togglePump(String status) async {
    const String apiUrl = "https://soiltrack-server.onrender.com/toggle-pump";
    print("Toggling pump to $status");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"pumpStatus": status}),
      );

      if (response.statusCode == 200) {
        print("Pump toggled successfully");
      } else {
        print(response.body);
        print("Failed to toggle pump");
      }
    } catch (e) {
      print("Failed to toggle pump: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextGradient(text: 'Registered Plots', fontSize: 32),
                    const SizedBox(height: 20),
                    const PlotCard(),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => togglePump("ON"), // Toggle Pump ON
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                        ),
                        child: const Text(
                          'Turn Pump ON',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => togglePump("OFF"), // Toggle Pump OFF
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                        ),
                        child: const Text(
                          'Turn Pump OFF',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
