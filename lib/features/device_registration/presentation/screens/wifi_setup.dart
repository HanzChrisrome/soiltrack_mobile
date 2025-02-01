import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WifiSetupScreen extends StatefulWidget {
  const WifiSetupScreen({super.key});

  @override
  _WifiSetupScreenState createState() => _WifiSetupScreenState();
}

class _WifiSetupScreenState extends State<WifiSetupScreen> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> sendWifiCredentials() async {
    String ssid = _ssidController.text;
    String password = _passwordController.text;

    String esp32IP = 'http://192.168.4.1/setWiFi';

    // Prepare the body of the POST request
    Map<String, String> body = {
      'ssid': ssid,
      'password': password,
    };

    // Send the POST request to ESP32
    try {
      final response = await http.post(Uri.parse(esp32IP), body: body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wi-Fi credentials sent successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send credentials')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wi-Fi Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ssidController,
              decoration: InputDecoration(labelText: 'Wi-Fi SSID'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Wi-Fi Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendWifiCredentials,
              child: Text('Send Credentials to ESP32'),
            ),
          ],
        ),
      ),
    );
  }
}
