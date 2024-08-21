import 'package:emotion_pulse/services/mqtt_client.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomLineChart extends StatefulWidget {
  const CustomLineChart({super.key, required this.topic});
  final String topic;

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  final List<FlSpot> _spots = [];
  late MqttService mqttService;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    mqttService = MqttService(_onMessageReceived, widget.topic);
    mqttService.connect();
  }

  Future<void> _onMessageReceived(String message) async {
    final double newValue = double.parse(message);
    setState(() {
      _spots.add(FlSpot(_spots.length + 1.0, newValue));
    });

    await supabase
        .from('datossensores')
        .insert({'sensor_id': 3, 'valor': message}).onError(
      (error, stackTrace) {
        print('Error inserting data: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 1,
        minY: 50,
        maxY: 200,
        lineBarsData: [
          LineChartBarData(
            spots: _spots,
            isCurved: true,
            preventCurveOverShooting: true,
            isStrokeCapRound: true,
            color: Colors.redAccent,
          ),
        ],
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles:
                SideTitles(showTitles: true, interval: 10, reservedSize: 45),
            axisNameWidget: Text('BPM'),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }
}
