import 'package:emotion_pulse/services/mqtt_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class MaterialColorPickerExample extends StatefulWidget {
  const MaterialColorPickerExample({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  @override
  State<MaterialColorPickerExample> createState() =>
      _MaterialColorPickerExampleState();
}

class _MaterialColorPickerExampleState
    extends State<MaterialColorPickerExample> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      titlePadding: const EdgeInsets.all(0),
                      contentPadding: const EdgeInsets.all(0),
                      content: SingleChildScrollView(
                        child: MaterialPicker(
                          pickerColor: widget.pickerColor,
                          onColorChanged: widget.onColorChanged,
                        ),
                      ),
                    );
                  },
                ).then((color) => {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.pickerColor,
                shadowColor: widget.pickerColor.withOpacity(1),
                elevation: 10,
              ),
              child: Text(
                'Cambiar Color Led',
                style: TextStyle(
                    color: useWhiteForeground(widget.pickerColor)
                        ? Colors.white
                        : Colors.black),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ],
    );
  }
}

class CustomColorPicker extends StatefulWidget {
  const CustomColorPicker({super.key, required this.topic});
  final String topic;

  @override
  State<StatefulWidget> createState() => _CustomColorPicker();
}

class _CustomColorPicker extends State<CustomColorPicker> {
  Color currentColor = Colors.amber;
  late MqttService mqttService;

  @override
  void initState() {
    super.initState();
    mqttService = MqttService(_onMessageReceived, widget.topic);
    mqttService.connect();
  }

  void _onMessageReceived(String message) {}

  void changeColor(Color color) {
    setState(() => currentColor = color);
    mqttService.publishMessageWithRetry(
        widget.topic, color.toHexString().substring(2));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialColorPickerExample(
      pickerColor: currentColor,
      onColorChanged: changeColor,
    );
  }

  _reconnect() {
    mqttService.connect();
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }
}
