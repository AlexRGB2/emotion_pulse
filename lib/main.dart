import 'package:emotion_pulse/pages/led.dart';
import 'package:emotion_pulse/pages/linechart.dart';
import 'package:emotion_pulse/pages/map.dart';
import 'package:emotion_pulse/pages/temperature.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://dfspaxkvnqlfeogzltbq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRmc3BheGt2bnFsZmVvZ3psdGJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQxMDQ5ODEsImV4cCI6MjAzOTY4MDk4MX0.4Cc3yE1iAiBmthJFjM5peJ__RftmrU4sTwpVYdDil14',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainAppBody(),
    );
  }
}

class MainAppBody extends StatefulWidget {
  const MainAppBody({super.key});

  @override
  _MainAppBodyState createState() => _MainAppBodyState();
}

class _MainAppBodyState extends State<MainAppBody> {
  Future<void> _refreshApp() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainAppBody()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('EmotionPulse'),
        backgroundColor: Colors.deepPurple[300],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshApp, // Llama a la función de refresco
        child: GridView.count(
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 20.0,
          crossAxisCount: 3,
          children: const <Widget>[
            Center(
              child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CustomLineChart(
                    topic: 'emotionpulse/heartRate',
                  )),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: MyMap(latitude: 21.1671346, longitude: -100.9317302),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: TemperatureChart(
                  topic: 'emotionpulse/temperature',
                ),
              ),
            ),
            Center(
              child: CustomColorPicker(
                topic: 'emotionpulse/led',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
