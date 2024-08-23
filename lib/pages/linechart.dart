import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomLineChart extends StatefulWidget {
  const CustomLineChart(
      {super.key,
      required this.sensorId,
      required this.minMaxY,
      required this.intervalo,
      required this.gradiente});
  final int sensorId;
  final List<double> minMaxY;
  final double intervalo;
  final LinearGradient gradiente;

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  final List<FlSpot> _spots = [];
  final supabase = Supabase.instance.client;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    getSpots();
  }

  void getSpots() async {
    final data = await supabase
        .from('datossensores')
        .select('''valor, timestamp''')
        .eq('sensor_id', widget.sensorId)
        .gte('timestamp', '2024-08-22 02:06:42.589879+00');

    var contador = 1;
    List<FlSpot> spots = [];

    for (var item in data) {
      final val = FlSpot(
          double.parse(contador.toString()), double.parse(item['valor']));
      spots.add(val);
      contador++;
    }

    if (mounted && !_isDisposed) {
      setState(() {
        _spots.addAll(spots);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        backgroundColor: const Color.fromARGB(255, 211, 211, 211),
        minY: widget.minMaxY[0],
        maxY: widget.minMaxY[1],
        lineBarsData: [
          LineChartBarData(
              spots: _spots,
              barWidth: 10.0,
              isCurved: true,
              preventCurveOverShooting: true,
              isStrokeCapRound: true,
              gradient: widget.gradiente),
        ],
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true, interval: widget.intervalo, reservedSize: 45),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
