// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';

class Config {
  static String get mqttBroker => dotenv.env['MQTT_BROKER'] ?? "";
  static String get mqttUsername => dotenv.env['MQTT_USERNAME'] ?? "";
  static String get mqttPassword => dotenv.env['MQTT_PASSWORD'] ?? "";
}

class MQTTService {
  final MqttServerClient _client =
      MqttServerClient(Config.mqttBroker, 'flutter_client');
  final Map<String, StreamController<String>> _topicListeners = {};

  Future<bool> connect() async {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      print('✅ Already connected to MQTT Broker');
      return true;
    }

    _client.port = 8883;
    _client.secure = true;
    _client.setProtocolV31();
    _client.keepAlivePeriod = 60;

    _client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .authenticateAs(Config.mqttUsername, Config.mqttPassword)
        .startClean();

    try {
      NotifierHelper.logMessage('🔌 Connecting to MQTT Broker...');
      await _client.connect();

      _client.updates!
          .listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        for (var message in messages) {
          final topic = message.topic;
          final payload = MqttPublishPayload.bytesToStringAsString(
              (message.payload as MqttPublishMessage).payload.message);

          if (_topicListeners.containsKey(topic)) {
            _topicListeners[topic]!.add(payload);
          }
        }
      });

      return true;
    } catch (error) {
      print('❌ Connection failed: $error');
      return false;
    }
  }

  void subscribe(String topic) {
    if (!_topicListeners.containsKey(topic)) {
      _topicListeners[topic] = StreamController<String>.broadcast();
    }
    _client.subscribe(topic, MqttQos.atMostOnce);
    print('📡 Subscribed to $topic');
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    print('📤 Sent message to $topic: $message');
  }

  Future<String> waitForResponse(String topic,
      {String? expectedMessage, int timeoutMs = 10000}) async {
    subscribe(topic);
    final completer = Completer<String>();

    final timer = Timer(Duration(milliseconds: timeoutMs), () {
      if (!completer.isCompleted) {
        completer.completeError('⏳ Timeout: No response received on $topic');
      }
    });

    _topicListeners[topic]!.stream.listen((message) {
      print("📩 Received message on $topic: $message");

      if (!completer.isCompleted) {
        if (expectedMessage == null || message == expectedMessage) {
          timer.cancel();
          completer.complete(message);
        } else {
          print(
              '⚠️ Ignoring message: "$message" (expected: "$expectedMessage")');
        }
      }
    });

    return completer.future;
  }

  Future<String> publishAndWaitForResponse(
      String requestTopic, String responseTopic, String message,
      {String? expectedResponse, int timeoutMs = 5000}) async {
    await connect();
    subscribe(responseTopic);
    publish(requestTopic, message);

    try {
      return await waitForResponse(responseTopic,
          expectedMessage: expectedResponse, timeoutMs: timeoutMs);
    } catch (e) {
      print('❌ Error: $e');
      return '';
    }
  }
}
