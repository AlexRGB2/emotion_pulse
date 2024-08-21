// ignore_for_file: avoid_print

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;
  final Function(String) onMessageReceived;
  final String topic;
  int maxReconnectAttempts = 10;
  int _reconnectAttempts = 0;

  MqttService(this.onMessageReceived, this.topic);

  void connect() async {
    client =
        MqttServerClient('broker.hivemq.com', '', maxConnectionAttempts: 10);
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.logging(on: true);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      _attemptReconnect();
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Connected');
      _reconnectAttempts = 0;
      _subscribeToTopic(topic);
    } else {
      disconnect();
    }
  }

  void _onDisconnected() {
    print('Disconnected');
  }

  void disconnect() {
    client.disconnect();
  }

  void _subscribeToTopic(String topic) {
    client.subscribe(topic, MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      onMessageReceived(payload);
    });
  }

  void _attemptReconnect() {
    if (_reconnectAttempts < maxReconnectAttempts) {
      _reconnectAttempts++;
      print(
          'Reconnecting... Attempt $_reconnectAttempts of $maxReconnectAttempts');
      Future.delayed(const Duration(seconds: 5), () {
        connect();
      });
    } else {
      print('Max reconnect attempts reached. Disconnecting...');
      disconnect();
    }
  }

  Future<void> publishMessageWithRetry(String topic, String message,
      {int retries = 3,
      Duration retryInterval = const Duration(seconds: 5)}) async {
    int attempt = 0;

    while (attempt < retries) {
      try {
        client.publishMessage(
          topic,
          MqttQos.atMostOnce,
          MqttClientPayloadBuilder().addString(message).payload!,
        );
        print('Message sent: $message');
        break;
      } catch (e) {
        attempt++;
        print('Failed to send message. Attempt $attempt of $retries');
        if (attempt < retries) {
          await Future.delayed(retryInterval);
        } else {
          print('Failed to send message after $retries attempts');
        }
      }
    }
  }
}
