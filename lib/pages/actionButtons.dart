import 'package:emotion_pulse/pages/led.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class ActionButtons extends StatefulWidget {
  const ActionButtons({super.key, required this.topic, required this.client});
  final List<String> topic;
  final MqttServerClient client;

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              final builder = MqttClientPayloadBuilder();
              builder.addString('GRABA');

              if (widget.client.connectionStatus?.state ==
                  MqttConnectionState.connected) {
                widget.client.publishMessage(
                    widget.topic[0], MqttQos.atMostOnce, builder.payload!);
              } else {
                print('No hay conexión con el broker');
              }
            },
            child: const Text('Grabar Audio',
                style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              shadowColor: Colors.cyanAccent.withOpacity(1),
              elevation: 10,
            ),
          ),
          const SizedBox(height: 16), // Espaciado entre botones
          ElevatedButton(
            onPressed: () {
              final builder = MqttClientPayloadBuilder();
              builder.addString('PLAY');

              if (widget.client.connectionStatus?.state ==
                  MqttConnectionState.connected) {
                widget.client.publishMessage(
                    widget.topic[1], MqttQos.atMostOnce, builder.payload!);
              } else {
                print('No hay conexión con el broker');
              }
            },
            child: const Text('Reproducir Audio',
                style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              shadowColor: Colors.greenAccent.withOpacity(1),
              elevation: 10,
            ),
          ),
          const SizedBox(height: 16), // Espaciado entre botones
          ElevatedButton(
            onPressed: () {
              final builder = MqttClientPayloadBuilder();
              builder.addString('SI');

              if (widget.client.connectionStatus?.state ==
                  MqttConnectionState.connected) {
                widget.client.publishMessage(
                    widget.topic[2], MqttQos.atMostOnce, builder.payload!);
              } else {
                print('No hay conexión con el broker');
              }
            },
            child: const Text('Pasos', style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shadowColor: Colors.pinkAccent.withOpacity(1),
              elevation: 10,
            ),
          ),
          const SizedBox(height: 16), // Espaciado entre botones
          CustomColorPicker(
            topic: widget.topic[3],
            client: widget.client,
          ),
        ],
      ),
    );
  }
}
