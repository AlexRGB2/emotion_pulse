import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class PedometerChart extends StatefulWidget {
  const PedometerChart({super.key, required this.topic, required this.client});

  final String topic;
  final MqttServerClient client;

  @override
  State<PedometerChart> createState() => _PedometerChartState();
}

class _PedometerChartState extends State<PedometerChart> {
  int steps = 0;
  final supabase = Supabase.instance.client;
  late StreamSubscription<List<MqttReceivedMessage<MqttMessage>>> _subscription;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    subscribeToTopic(widget.topic);
  }

  void subscribeToTopic(String topic) {
    widget.client.subscribe(topic, MqttQos.atMostOnce);

    _subscription = widget.client.updates!
        .listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttReceivedMessage<MqttMessage> receivedMessage = c[0];
      if (receivedMessage.topic == topic) {
        final MqttPublishMessage message =
            receivedMessage.payload as MqttPublishMessage;
        final String payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        _onMessageReceived(payload);
      }
    });
  }

  Future<void> _onMessageReceived(String message) async {
    final int newSteps = int.parse(message);

    if (mounted && !_isDisposed) {
      setState(() {
        steps = newSteps;
      });
    }

    await supabase
        .from('datossensores')
        .insert({'sensor_id': 1, 'valor': steps.toString()}).onError(
      (error, stackTrace) {
        print('Error inserting data: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
        enableLoadingAnimation: true,
        animationDuration: 3000,
        title: const GaugeTitle(
            text: 'Podómetro',
            textStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        axes: <RadialAxis>[
          RadialAxis(minimum: 0, maximum: 10000, ranges: <GaugeRange>[
            GaugeRange(startValue: 0, endValue: 3000, color: Colors.red),
            GaugeRange(startValue: 3000, endValue: 7000, color: Colors.orange),
            GaugeRange(startValue: 7000, endValue: 10000, color: Colors.green),
          ], pointers: <GaugePointer>[
            NeedlePointer(
              value: steps.toDouble(),
              enableAnimation: true,
            )
          ], annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Text('$steps pasos',
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold)),
                angle: 90,
                positionFactor: 0.5)
          ])
        ]);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription.cancel();
    super.dispose();
  }
}
