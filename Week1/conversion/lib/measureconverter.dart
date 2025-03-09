import 'package:flutter/material.dart';



class MeasuresConverterPage extends StatefulWidget {
  const MeasuresConverterPage({Key? key}) : super(key: key);

  @override
  State<MeasuresConverterPage> createState() => _MeasuresConverterPageState();
}

class _MeasuresConverterPageState extends State<MeasuresConverterPage> {
  // Text editing controller for the numeric value
  final TextEditingController _valueController = TextEditingController(text: '100');

  // List of all supported measures (both distance & weight)
  final List<String> _measures = [
    'meters',
    'kilometers',
    'feet',
    'miles',
    'kilograms',
    'grams',
    'pounds',
    'ounces',
  ];

  // Maps for converting to/from a base unit within each category
  // Distance: base = meters
  final Map<String, double> _distanceMap = {
    'meters': 1.0,
    'kilometers': 1000.0,
    'feet': 0.3048,
    'miles': 1609.34,
  };

  // Weight: base = kilograms
  final Map<String, double> _weightMap = {
    'kilograms': 1.0,
    'grams': 0.001,
    'pounds': 0.45359237,
    'ounces': 0.0283495,
  };

  // Currently selected units
  String _fromMeasure = 'meters';
  String _toMeasure = 'feet';

  // Conversion result
  String _resultMessage = '';

  /// Identify if a measure is in the distance map or weight map
  bool _isDistance(String measure) => _distanceMap.containsKey(measure);
  bool _isWeight(String measure) => _weightMap.containsKey(measure);

  void _convert() {
    final inputValue = double.tryParse(_valueController.text);
    if (inputValue == null) {
      setState(() {
        _resultMessage = 'Please enter a valid number.';
      });
      return;
    }

    // Check if both measures belong to distance or weight
    final fromIsDistance = _isDistance(_fromMeasure);
    final toIsDistance = _isDistance(_toMeasure);
    final fromIsWeight = _isWeight(_fromMeasure);
    final toIsWeight = _isWeight(_toMeasure);

    // If user mixes distance and weight, show an error
    if ((fromIsDistance && toIsWeight) || (fromIsWeight && toIsDistance)) {
      setState(() {
        _resultMessage = 'Cannot convert between distance and weight.';
      });
      return;
    }

    double result = 0.0;

    // Distance → Distance
    if (fromIsDistance && toIsDistance) {
      // Convert from "fromMeasure" to base (meters), then base to "toMeasure"
      final valueInMeters = inputValue * _distanceMap[_fromMeasure]!;
      result = valueInMeters / _distanceMap[_toMeasure]!;
    }

    // Weight → Weight
    if (fromIsWeight && toIsWeight) {
      // Convert from "fromMeasure" to base (kilograms), then base to "toMeasure"
      final valueInKilograms = inputValue * _weightMap[_fromMeasure]!;
      result = valueInKilograms / _weightMap[_toMeasure]!;
    }

    setState(() {
      _resultMessage = '$inputValue $_fromMeasure = '
          '${result.toStringAsFixed(3)} $_toMeasure';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measures Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // VALUE INPUT
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Value',
              ),
            ),

            const SizedBox(height: 16),

            // FROM DROPDOWN
            Row(
              children: [
                const Text('From'),
                const SizedBox(width: 20),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _fromMeasure,
                    items: _measures.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _fromMeasure = val!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // TO DROPDOWN
            Row(
              children: [
                const Text('To'),
                const SizedBox(width: 35),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _toMeasure,
                    items: _measures.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _toMeasure = val!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // CONVERT BUTTON
            ElevatedButton(
              onPressed: _convert,
              child: const Text('Convert'),
            ),

            const SizedBox(height: 24),

            // RESULT DISPLAY
            Text(
              _resultMessage,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}