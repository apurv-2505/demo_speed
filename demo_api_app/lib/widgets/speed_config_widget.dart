import 'package:flutter/material.dart';
import '../models/api_call.dart';
import '../services/speed_service.dart';

class SpeedConfigWidget extends StatelessWidget {
  final SpeedUnit selectedUnit;
  final bool useManualInput;
  final double minSpeedThreshold;
  final TextEditingController manualSpeedController;
  final Function(SpeedUnit) onUnitChanged;
  final Function(bool) onManualInputChanged;
  final Function(double) onThresholdChanged;

  const SpeedConfigWidget({
    super.key,
    required this.selectedUnit,
    required this.useManualInput,
    required this.minSpeedThreshold,
    required this.manualSpeedController,
    required this.onUnitChanged,
    required this.onManualInputChanged,
    required this.onThresholdChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Speed Threshold Configuration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Text('Unit: ', style: Theme.of(context).textTheme.titleMedium),
                DropdownButton<SpeedUnit>(
                  value: selectedUnit,
                  onChanged: (SpeedUnit? newValue) {
                    if (newValue != null) {
                      onUnitChanged(newValue);
                    }
                  },
                  items: SpeedUnit.values.map((SpeedUnit unit) {
                    return DropdownMenuItem<SpeedUnit>(
                      value: unit,
                      child: Text(unit.name.toUpperCase()),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Checkbox(
                  value: useManualInput,
                  onChanged: (bool? value) {
                    onManualInputChanged(value ?? false);
                  },
                ),
                const Text('Use manual input'),
              ],
            ),

            const SizedBox(height: 16),

            if (useManualInput) ...[
              TextField(
                controller: manualSpeedController,
                decoration: InputDecoration(
                  labelText: 'Speed Threshold (${selectedUnit.name})',
                  border: const OutlineInputBorder(),
                  suffixText: selectedUnit.name.toUpperCase(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final parsedValue = double.tryParse(value) ?? 5.0;
                  onThresholdChanged(
                    SpeedService.convertToMbps(parsedValue, selectedUnit),
                  );
                },
              ),
            ] else ...[
              Text(
                'Threshold: ${SpeedService.formatSpeed(minSpeedThreshold, selectedUnit)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: SpeedService.convertFromMbps(
                  minSpeedThreshold,
                  selectedUnit,
                ),
                min: selectedUnit == SpeedUnit.kbps ? 100 : 0.1,
                max: selectedUnit == SpeedUnit.kbps ? 50000 : 50.0,
                divisions: selectedUnit == SpeedUnit.kbps ? 100 : 100,
                onChanged: (value) {
                  onThresholdChanged(
                    SpeedService.convertToMbps(value, selectedUnit),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
