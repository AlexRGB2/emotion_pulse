// ignore_for_file: avoid_print

import 'dart:async';
import 'package:emotion_pulse/pages/heartbeatsensor.dart';
import 'package:emotion_pulse/pages/linechart.dart';
import 'package:emotion_pulse/pages/map.dart';
import 'package:emotion_pulse/pages/podometer.dart';
import 'package:emotion_pulse/pages/actionButtons.dart';
import 'package:emotion_pulse/pages/temperature.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  runApp(AppInitializer());
}

class AppInitializer extends StatefulWidget {
  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  MqttServerClient? _mqttClient;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Supabase.initialize(
      url: 'https://dfspaxkvnqlfeogzltbq.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRmc3BheGt2bnFsZmVvZ3psdGJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQxMDQ5ODEsImV4cCI6MjAzOTY4MDk4MX0.4Cc3yE1iAiBmthJFjM5peJ__RftmrU4sTwpVYdDil14',
    );

    final client = MqttServerClient.withPort('broker.hivemq.com', '', 1883);
    client.keepAlivePeriod = 20;
    client.logging(on: true);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('emotionpulse1523')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client.autoReconnect = true;
    client.connectionMessage = connMessage;

    try {
      await client.connect(null, null);

      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        print('MQTT Client Connected');
        setState(() {
          _mqttClient = client;
          _isLoading = false;
        });
      } else {
        print('Connection failed, retrying in 5 seconds...');
        Future.delayed(const Duration(seconds: 5), _initializeApp);
      }
    } catch (e) {
      print('Connection failed: $e, retrying in 5 seconds...');
      Future.delayed(const Duration(seconds: 5), _initializeApp);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else {
      return MainApp(client: _mqttClient!);
    }
  }
}

class MainApp extends StatelessWidget {
  final MqttServerClient client;

  const MainApp({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('EmotionPulse'),
          backgroundColor: Colors.deepPurple[300],
        ),
        body: GridView.count(
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 20.0,
          crossAxisCount: 2,
          children: <Widget>[
            // Latidos del corazón
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: HeartbeatSensor(
                      client: client,
                      topic: 'emotionpulse/heartbeat',
                    ),
                  ),
                ),
              ),
            ),
            // Historico de latidos
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CustomLineChart(
                      sensorId: 3,
                      intervalo: 10,
                      gradiente: LinearGradient(
                        colors: [
                          Color(0xfffc466b),
                          Color(0xffffa8a8),
                          Color(0xffff9e9e)
                        ],
                        stops: [0.25, 0.75, 0.87],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
// Gauge de Temperatura
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TemperatureChart(
                      topic: 'emotionpulse/temperature',
                      client: client,
                    ),
                  ),
                ),
              ),
            ),
            // Historico de Temperatura
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CustomLineChart(
                      sensorId: 2,
                      intervalo: 1,
                      gradiente: LinearGradient(
                        colors: [Color(0xff9796f0), Color(0xfffbc7d4)],
                        stops: [0, 1],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Podometro
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: PedometerChart(
                      topic: 'emotionpulse/pedometer',
                      client: client,
                    ),
                  ),
                ),
              ),
            ),
            // Historico de Pasos
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CustomLineChart(
                      sensorId: 1,
                      intervalo: 1000,
                      gradiente: LinearGradient(
                        colors: [
                          Color(0xff5433ff),
                          Color(0xff20bdff),
                          Color(0xffa5fecb)
                        ],
                        stops: [0, 0.5, 1],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Mapa
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: MyMap(
                      latitude: 21.1675710,
                      longitude: -100.9294100,
                    ),
                  ),
                ),
              ),
            ),
            // Botones
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ActionButtons(
                      topic: [
                        'emotionpulse/record',
                        'emotionpulse/play',
                        'emotionpulse/resetPedometer',
                        'emotionpulse/led',
                      ],
                      client: client,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
