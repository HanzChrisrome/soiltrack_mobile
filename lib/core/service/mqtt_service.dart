// ignore_for_file: avoid_print

import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Config {
  static const String mqttBroker =
      "492fff856e4e41edb7fdca124aca8f56.s1.eu.hivemq.cloud";
  static const String mqttUsername = "Chroime";
  static const String mqttPassword = "Secret12";
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
        print('⏳ Timeout: No response received on $topic');
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
}
